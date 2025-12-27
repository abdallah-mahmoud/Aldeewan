import 'package:realm/realm.dart';

part 'savings_goal_model.realm.dart';

/// Represents a savings goal item stored in the Realm database.
///
/// This class defines the schema for a savings goal, including its name, target amount,
/// current saved amount, optional deadline, icon, and color.
@RealmModel()
class _SavingsGoalModel {
  /// The unique identifier for the savings goal.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late ObjectId id;

  /// The name of the savings goal (e.g., "New Car", "Down Payment").
  late String name;
  /// The target amount to be saved for this goal.
  late double targetAmount;
  /// The current amount that has been saved towards this goal.
  late double currentSaved;
  /// An optional deadline by which the savings goal is intended to be reached.
  DateTime? deadline;
  /// An optional icon name associated with the goal for visual representation.
  String? icon;
  /// An optional hex code representation of a color associated with this goal for UI purposes.
  String? colorHex;
}
