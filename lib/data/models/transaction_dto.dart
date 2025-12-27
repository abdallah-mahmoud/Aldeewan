import 'package:aldeewan_mobile/domain/entities/transaction.dart';

/// A Data Transfer Object (DTO) for representing transaction data.
///
/// This class is used to transfer transaction information, often between different
/// layers of the application or when receiving data from external sources.
/// It provides a flattened structure for transaction details and a method to
/// convert to a domain entity.
class TransactionDto {
  /// The unique identifier for the transaction.
  final String id;
  /// The type of the transaction, represented as a string (e.g., 'cashExpense', 'paymentReceived').
  final String type;
  /// The optional ID of the person associated with this transaction.
  final String? personId;
  /// The monetary amount of the transaction.
  final double amount;
  /// The date when the transaction occurred.
  final DateTime date;
  /// The optional category of the transaction (e.g., 'Groceries', 'Salary').
  final String? category;
  /// An optional note or description for the transaction.
  final String? note;
  /// The optional due date for the transaction, relevant for payables/receivables.
  final DateTime? dueDate;
  /// An optional external ID, typically from a bank or payment system.
  final String? externalId;
  /// The optional status of the transaction (e.g., 'POSTED', 'PENDING').
  final String? status;
  /// The optional ID of the financial account involved in the transaction.
  final int? accountId;

  /// Creates a [TransactionDto] instance with the given details.
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
  });

  /// Converts this [TransactionDto] into a [Transaction] domain entity.
  ///
  /// This method maps the DTO properties to the corresponding domain entity
  /// properties, including converting the `type` string to a [TransactionType] enum.
  /// - Returns: A [Transaction] domain entity.
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
    );
  }
}
