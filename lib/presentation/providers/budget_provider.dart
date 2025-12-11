import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class BudgetState {
  final List<BudgetModel> budgets;
  final List<SavingsGoalModel> goals;
  final bool isLoading;

  BudgetState({
    this.budgets = const [],
    this.goals = const [],
    this.isLoading = false,
  });

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    List<SavingsGoalModel>? goals,
    bool? isLoading,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(ref);
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  final Ref ref;
  late final Isar _isar;

  BudgetNotifier(this.ref) : super(BudgetState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _isar = await ref.read(isarProvider.future);
    await loadData();
  }

  Future<void> loadData() async {
    try {
      final budgets = await _isar.budgetModels.where().findAll();
      final goals = await _isar.savingsGoalModels.where().findAll();

      // Recalculate spent amounts for budgets
      final updatedBudgets = <BudgetModel>[];
      for (final budget in budgets) {
        final spent = await _calculateSpent(budget);
        // We don't necessarily need to save this to DB every time, but updating the object for UI is good.
        // If we want to cache it, we would writeTxn. For now, let's just return the calculated value in the object.
        budget.currentSpent = spent;
        updatedBudgets.push(budget);
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
    final transactions = await _isar.transactionModels
        .filter()
        .dateBetween(budget.startDate, budget.endDate)
        .categoryEqualTo(budget.category)
        .findAll();

    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.cashExpense || t.type == TransactionType.paymentMade) {
        total += t.amount;
      }
    }
    return total;
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _isar.writeTxn(() async {
      await _isar.budgetModels.put(budget);
    });
    await loadData();
  }

  Future<void> deleteBudget(int id) async {
    await _isar.writeTxn(() async {
      await _isar.budgetModels.delete(id);
    });
    await loadData();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _isar.writeTxn(() async {
      await _isar.savingsGoalModels.put(goal);
    });
    await loadData();
  }
  
  Future<void> updateGoalAmount(int id, double amount) async {
     final goal = await _isar.savingsGoalModels.get(id);
     if (goal != null) {
       goal.currentSaved += amount;
       await _isar.writeTxn(() async {
         await _isar.savingsGoalModels.put(goal);
       });
       await loadData();
     }
  }
}

extension ListPush<T> on List<T> {
  void push(T element) => add(element);
}
