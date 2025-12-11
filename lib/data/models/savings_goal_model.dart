import 'package:realm/realm.dart';

part 'savings_goal_model.realm.dart';

@RealmModel()
class _SavingsGoalModel {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late double targetAmount;
  late double currentSaved;
  DateTime? deadline;
  String? icon;
  String? colorHex;
}
