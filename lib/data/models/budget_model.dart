import 'package:realm/realm.dart';

part 'budget_model.realm.dart';

/// Represents a budget item stored in the Realm database.
///
/// This class defines the schema for a budget, including its category, spending limits,
/// current spent amount, active dates, and recurrence status.
@RealmModel()
class _BudgetModel {
  /// The unique identifier for the budget.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late ObjectId id;

  /// The category to which this budget applies (e.g., "Groceries", "Entertainment").
  late String category;
  /// The maximum amount allowed to be spent for this budget within its period.
  late double amountLimit;
  /// The current amount spent against this budget.
  late double currentSpent;
  /// The starting date of the budget period.
  late DateTime startDate;
  /// The ending date of the budget period.
  late DateTime endDate;
  /// Indicates whether this budget is recurring (e.g., monthly) or a one-time budget.
  /// Defaults to `true`.
  bool isRecurring = true;
}
