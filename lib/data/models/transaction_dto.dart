import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class TransactionDto {
  final String id;
  final String type;
  final String? personId;
  final double amount;
  final DateTime date;
  final String? category;
  final String? note;
  final DateTime? dueDate;
  final String? externalId;
  final String? status;
  final int? accountId;
  final String? goalId;
  final bool isOpeningBalance;

  TransactionDto({
    required this.id,
    required this.type,
    this.personId,
    required this.amount,
    required this.date,
    this.category,
    this.note,
    this.dueDate,
    this.externalId,
    this.status,
    this.accountId,
    this.goalId,
    this.isOpeningBalance = false,
  });

  Transaction toEntity() {
    return Transaction(
      id: id,
      type: TransactionType.values.firstWhere((e) => e.name == type, orElse: () => TransactionType.cashExpense),
      personId: personId,
      amount: amount,
      date: date,
      category: category,
      note: note,
      dueDate: dueDate,
      externalId: externalId,
      status: status,
      accountId: accountId,
      goalId: goalId,
      isOpeningBalance: isOpeningBalance,
    );
  }
}
