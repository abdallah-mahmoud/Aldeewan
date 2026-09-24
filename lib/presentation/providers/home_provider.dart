import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';

import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

enum SummaryRange { all, month }

final summaryRangeProvider = StateProvider<SummaryRange>((ref) => SummaryRange.all);

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final ledgerState = ref.watch(ledgerProvider).value;
  if (ledgerState == null) return [];

  final range = ref.watch(summaryRangeProvider);
  final transactions = ledgerState.transactions;

  if (range == SummaryRange.all) {
    return transactions;
  } else {
    final now = DateTime.now();
    return transactions.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
  }
});

final totalReceivableProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  return ref.read(getTotalReceivablesUseCaseProvider)(s.persons, s.balances);
});

final totalPayableProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  return ref.read(getTotalPayablesUseCaseProvider)(s.persons, s.balances);
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  return ref.read(getMonthlyIncomeUseCaseProvider)(s.transactions);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  return ref.read(getMonthlyExpenseUseCaseProvider)(s.transactions);
});

/// All-time cumulative cash balance (filter-independent).
///
/// Computes total cash physically in hand across all history.
/// - Excludes [isOpeningBalance] transactions (old debts don't affect cash).
/// - Includes [debtGiven] (cash out) and [debtTaken] (cash in).
/// - Never resets at month rollover.
///
/// Used by: Hero Card ("All" filter), form validation (expense/payment guards).
final totalCashBalanceProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;

  double balance = 0.0;
  for (final t in s.transactions) {
    // Opening balances record historical debt — they never moved actual cash
    if (t.isOpeningBalance) continue;

    // Cash inflows
    if (t.type == TransactionType.cashSale ||
        t.type == TransactionType.cashIncome ||
        t.type == TransactionType.paymentReceived ||
        t.type == TransactionType.debtTaken) {
      balance += t.amount;
    }
    // Cash outflows
    else if (t.type == TransactionType.cashExpense ||
             t.type == TransactionType.paymentMade ||
             t.type == TransactionType.debtGiven) {
      balance -= t.amount;
    }
  }
  return balance;
});

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double net;

  DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  double totalIncome = 0;
  double totalExpense = 0;

  for (final t in transactions) {
    if (t.type == TransactionType.cashSale ||
        t.type == TransactionType.paymentReceived ||
        t.type == TransactionType.cashIncome) {
      totalIncome += t.amount;
    } else if (t.type == TransactionType.paymentMade ||
        t.type == TransactionType.cashExpense) {
      totalExpense += t.amount;
    }
  }

  return DashboardStats(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    net: totalIncome - totalExpense,
  );
});
