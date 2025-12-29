import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class GetMonthlyExpenseUseCase {
  double call(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions
        .where((t) => !t.isOpeningBalance) // Exclude old debts / opening balances
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .where((t) =>
            t.type == TransactionType.paymentMade ||
            t.type == TransactionType.cashExpense ||
            t.type == TransactionType.debtGiven) // Lent money = cash went out
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

