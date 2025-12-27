import 'package:realm/realm.dart' hide Transaction;
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

part 'transaction_model.realm.dart';

/// Represents a transaction item stored in the Realm database.
///
/// This class defines the schema for a transaction, including its unique ID (uuid),
/// type, associated person, amount, date, category, notes, due date, external ID,
/// status, associated financial account, and an optional link to a savings goal.
@RealmModel()
class _TransactionModel {
  /// The unique identifier for the transaction.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late String uuid;

  /// The type of the transaction, stored as a String (e.g., 'cashExpense', 'paymentReceived').
  late String type;

  /// The optional ID of the person associated with this transaction.
  /// This field is indexed for faster querying.
  @Indexed()
  String? personId;

  /// The monetary amount of the transaction.
  late double amount;
  /// The date and time when the transaction occurred.
  late DateTime date;
  /// The optional category of the transaction (e.g., 'Groceries', 'Salary').
  String? category;
  /// An optional note or description for the transaction.
  String? note;
  /// The optional due date for the transaction, relevant for payables/receivables.
  DateTime? dueDate;

  /// An optional external ID, typically from a bank or payment system.
  /// This field is indexed for faster querying.
  @Indexed()
  String? externalId;
  /// The optional status of the transaction (e.g., 'POSTED', 'PENDING').
  String? status;
  /// The optional ID of the financial account involved in the transaction.
  int? accountId;
  
  /// An optional ID that links this transaction to a specific savings goal.
  /// This field is indexed for faster querying.
  @Indexed()
  String? goalId;
}

/// Extension on [TransactionModel] to facilitate mapping between the Realm model
/// and the domain entity [Transaction].
extension TransactionModelMapper on TransactionModel {
  /// Converts a [TransactionModel] instance to a [Transaction] domain entity.
  ///
  /// This method maps the properties of the Realm model to the corresponding
  /// properties of the domain entity, including handling the conversion of
  /// the transaction type string to a [TransactionType] enum.
  /// - Returns: A [Transaction] domain entity.
  Transaction toEntity() {
    return Transaction(
      id: uuid,
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
    );
  }

  /// Converts a [Transaction] domain entity to a [TransactionModel] Realm instance.
  ///
  /// This static method is used to create a Realm-compatible model from a
  /// domain entity, converting the [TransactionType] enum back to its string representation.
  /// - Parameters:
  ///   - `transaction`: The [Transaction] domain entity to convert.
  /// - Returns: A [TransactionModel] Realm instance.
  static TransactionModel fromEntity(Transaction transaction) {
    return TransactionModel(
      transaction.id,
      transaction.type.name,
      transaction.amount,
      transaction.date,
      personId: transaction.personId,
      category: transaction.category,
      note: transaction.note,
      dueDate: transaction.dueDate,
      externalId: transaction.externalId,
      status: transaction.status,
      accountId: transaction.accountId,
      goalId: transaction.goalId,
    );
  }
}

