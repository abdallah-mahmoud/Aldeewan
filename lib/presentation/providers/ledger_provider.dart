import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

// State class for Ledger
class LedgerState {
  final List<Person> persons;
  final List<Transaction> transactions;
  final bool isLoading;

  LedgerState({
    this.persons = const [],
    this.transactions = const [],
    this.isLoading = false,
  });

  LedgerState copyWith({
    List<Person>? persons,
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return LedgerState(
      persons: persons ?? this.persons,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LedgerNotifier extends StateNotifier<LedgerState> {
  final Ref ref;

  LedgerNotifier(this.ref) : super(LedgerState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final persons = await ref.read(personRepositoryProvider).getPeople();
      final transactions = await ref.read(transactionRepositoryProvider).getTransactions();
      state = state.copyWith(persons: persons, transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> addPerson(Person person) async {
    await ref.read(personRepositoryProvider).addPerson(person);
    await loadData();
  }

  Future<void> deletePerson(String id) async {
    await ref.read(personRepositoryProvider).deletePerson(id);
    await loadData();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).addTransaction(transaction);
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await loadData();
  }

  // --- Calculations ---

  double calculatePersonBalance(Person person) {
    return state.transactions
        .where((t) => t.personId == person.id)
        .fold(0.0, (balance, t) {
      if (person.role == PersonRole.customer) {
        if (t.type == TransactionType.saleOnCredit) return balance + t.amount;
        if (t.type == TransactionType.paymentReceived) return balance - t.amount;
      } else { // Supplier
        if (t.type == TransactionType.purchaseOnCredit) return balance + t.amount;
        if (t.type == TransactionType.paymentMade) return balance - t.amount;
      }
      return balance;
    });
  }

  double get totalReceivable {
    return state.persons
        .where((p) => p.role == PersonRole.customer)
        .map((p) => calculatePersonBalance(p))
        .where((b) => b > 0)
        .fold(0.0, (sum, b) => sum + b);
  }

  double get totalPayable {
    return state.persons
        .where((p) => p.role == PersonRole.supplier)
        .map((p) => calculatePersonBalance(p))
        .where((b) => b > 0)
        .fold(0.0, (sum, b) => sum + b);
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return state.transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .where((t) =>
            t.type == TransactionType.cashSale ||
            t.type == TransactionType.paymentReceived ||
            t.type == TransactionType.cashIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return state.transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .where((t) =>
            t.type == TransactionType.paymentMade ||
            t.type == TransactionType.cashExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

final ledgerProvider = StateNotifierProvider<LedgerNotifier, LedgerState>((ref) {
  return LedgerNotifier(ref);
});
