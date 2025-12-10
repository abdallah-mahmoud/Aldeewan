import 'package:isar/isar.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Enumerated(EnumType.name)
  late TransactionType type;

  @Index()
  String? personId; // Foreign key to Person UUID

  late double amount;
  late DateTime date;
  String? category;
  String? note;
  DateTime? dueDate;

  // Mapper: Model -> Entity
  Transaction toEntity() {
    return Transaction(
      id: uuid,
      type: type,
      personId: personId,
      amount: amount,
      date: date,
      category: category,
      note: note,
      dueDate: dueDate,
    );
  }

  // Mapper: Entity -> Model
  static TransactionModel fromEntity(Transaction transaction) {
    return TransactionModel()
      ..uuid = transaction.id
      ..type = transaction.type
      ..personId = transaction.personId
      ..amount = transaction.amount
      ..date = transaction.date
      ..category = transaction.category
      ..note = transaction.note
      ..dueDate = transaction.dueDate;
  }
}
