import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';

/// Provider for TRUE income (only cashSale + cashIncome)
/// This excludes payments received and borrowed money
final trueIncomeProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  
  final now = DateTime.now();
  return s.transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .where((t) => !t.isOpeningBalance) // Exclude opening balances
      .where((t) =>
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provider for TRUE expense (only cashExpense)
/// This excludes payments to suppliers and debt given
final trueExpenseProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  
  final now = DateTime.now();
  return s.transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .where((t) => !t.isOpeningBalance) // Exclude opening balances
      .where((t) => t.type == TransactionType.cashExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provider for Money In (all inflows including payments received and borrowed)
final moneyInProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  
  final now = DateTime.now();
  return s.transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .where((t) => !t.isOpeningBalance)
      .where((t) =>
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome ||
          t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.debtTaken)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Provider for Money Out (all outflows including payments made and debt given)
final moneyOutProvider = Provider<double>((ref) {
  final s = ref.watch(ledgerProvider).value;
  if (s == null) return 0.0;
  
  final now = DateTime.now();
  return s.transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .where((t) => !t.isOpeningBalance)
      .where((t) =>
          t.type == TransactionType.cashExpense ||
          t.type == TransactionType.paymentMade ||
          t.type == TransactionType.debtGiven)
      .fold(0.0, (sum, t) => sum + t.amount);
});
