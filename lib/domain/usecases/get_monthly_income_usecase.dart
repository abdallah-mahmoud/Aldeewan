import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class GetMonthlyIncomeUseCase {
  double call(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions
        .where((t) => !t.isOpeningBalance) // Exclude old debts / opening balances
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .where((t) =>
            t.type == TransactionType.cashSale ||
            t.type == TransactionType.paymentReceived ||
            t.type == TransactionType.cashIncome ||
            t.type == TransactionType.debtTaken) // Borrowed money = cash came in
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

