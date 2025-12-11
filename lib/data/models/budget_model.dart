import 'package:realm/realm.dart';

part 'budget_model.g.dart';

@RealmModel()
class _BudgetModel {
  @PrimaryKey()
  late ObjectId id;

  late String category;
  late double amountLimit;
  late double currentSpent;
  late DateTime startDate;
  late DateTime endDate;
  bool isRecurring = true;
}
