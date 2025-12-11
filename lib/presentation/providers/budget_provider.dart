import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final realmAsync = ref.watch(realmProvider);
  return realmAsync.when(
    data: (realm) => BudgetNotifier(realm),
    loading: () => BudgetNotifier(null),
    error: (e, s) => BudgetNotifier(null),
  );
});

class BudgetState {
  final List<BudgetModel> budgets;
  final List<SavingsGoalModel> goals;
  final bool isLoading;

  BudgetState({this.budgets = const [], this.goals = const [], this.isLoading = false});

  BudgetState copyWith({List<BudgetModel>? budgets, List<SavingsGoalModel>? goals, bool? isLoading}) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final Realm? _realm;

  BudgetNotifier(this._realm) : super(BudgetState()) {
    if (_realm != null) {
      loadBudgets();
    }
  }

  void loadBudgets() {
    if (_realm == null) return;
    state = state.copyWith(isLoading: true);
    
    try {
      final budgets = _realm.all<BudgetModel>().toList();
      final goals = _realm.all<SavingsGoalModel>().toList();
      
      // Calculate spent amount for each budget
      final updatedBudgets = <BudgetModel>[];
      for (final budget in budgets) {
        _calculateSpent(budget).then((spent) {
           _realm.write(() {
             budget.currentSpent = spent;
           });
        });
        updatedBudgets.add(budget);
      }

      state = state.copyWith(
        budgets: updatedBudgets,
        goals: goals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<double> _calculateSpent(BudgetModel budget) async {
    final transactions = _realm!.query<TransactionModel>(
      'date >= \$0 AND date <= \$1 AND category == \$2',
      [budget.startDate, budget.endDate, budget.category]
    ).toList();

    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.cashExpense.name || t.type == TransactionType.paymentMade.name) {
        total += t.amount;
      }
    }
    return total;
  }

  void addBudget(BudgetModel budget) {
    if (_realm == null) return;
    _realm.write(() {
      _realm.add(budget);
    });
    loadBudgets();
  }

  void addGoal(SavingsGoalModel goal) {
    if (_realm == null) return;
    _realm.write(() {
      _realm.add(goal);
    });
    loadBudgets();
  }
  
  void updateGoal(SavingsGoalModel goal, double amountAdded) {
    if (_realm == null) return;
    _realm.write(() {
      goal.currentSaved += amountAdded;
    });
    loadBudgets();
  }
}
