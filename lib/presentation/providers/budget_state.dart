import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';

part 'budget_state.freezed.dart';

@freezed
abstract class BudgetState with _$BudgetState {
  const factory BudgetState({
    @Default([]) List<BudgetModel> budgets,
    @Default([]) List<SavingsGoalModel> goals,
    @Default(false) bool isLoading,
  }) = _BudgetState;
}
