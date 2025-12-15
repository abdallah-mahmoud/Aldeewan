import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_state.dart';
import 'package:aldeewan_mobile/data/services/balance_calculator_service.dart';

class LedgerNotifier extends StateNotifier<AsyncValue<LedgerState>> {
  final Ref ref;
  List<Person>? _persons;
  List<Transaction>? _transactions;
  StreamSubscription? _personSubscription;
  StreamSubscription? _transactionSubscription;

  LedgerNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initStreams();
  }

  void _initStreams() {
    _personSubscription = ref.read(personRepositoryProvider).watchPeople().listen(
      (persons) {
        _persons = persons;
        _updateState();
      },
      onError: (e, s) {
        state = AsyncValue.error(e, s);
      },
    );

    _transactionSubscription = ref.read(transactionRepositoryProvider).watchTransactions().listen(
      (transactions) {
        _transactions = transactions;
        _updateState();
      },
      onError: (e, s) {
        state = AsyncValue.error(e, s);
      },
    );
  }

  @override
  void dispose() {
    _personSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateState() async {
    if (_persons != null && _transactions != null) {
      try {
        final calculator = ref.read(balanceCalculatorProvider);
        final balances = await calculator.calculate(_persons!, _transactions!);
        
        if (mounted) {
          state = AsyncValue.data(LedgerState(
            persons: _persons!,
            transactions: _transactions!,
            balances: balances,
          ));
        }
      } catch (e, s) {
        if (mounted) {
          state = AsyncValue.error(e, s);
        }
      }
    }
  }

  Future<void> addPerson(Person person) async {
    await ref.read(personRepositoryProvider).addPerson(person);
  }

  Future<void> deletePerson(String id) async {
    await ref.read(personRepositoryProvider).deletePerson(id);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).addTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
  }

  // --- Calculations ---

  double calculatePersonBalance(Person person) {
    return state.value?.balances[person.id] ?? 0.0;
  }

  double get totalReceivable {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getTotalReceivablesUseCaseProvider)(s.persons, s.balances);
  }

  double get totalPayable {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getTotalPayablesUseCaseProvider)(s.persons, s.balances);
  }

  double get monthlyIncome {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getMonthlyIncomeUseCaseProvider)(s.transactions);
  }

  double get monthlyExpense {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getMonthlyExpenseUseCaseProvider)(s.transactions);
  }
}

final ledgerProvider = StateNotifierProvider<LedgerNotifier, AsyncValue<LedgerState>>((ref) {
  return LedgerNotifier(ref);
});

/// Search query provider for ledger person filtering
final ledgerSearchProvider = StateProvider<String>((ref) => '');
