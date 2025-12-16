import 'dart:async';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final realmAsync = ref.watch(realmProvider);
  final notifier = realmAsync.when(
    data: (realm) => BudgetNotifier(realm),
    loading: () => BudgetNotifier(null),
    error: (e, s) => BudgetNotifier(null),
  );
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  final Realm? _realm;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _goalSubscription;
  Timer? _recalculateDebounceTimer;

  BudgetNotifier(this._realm) : super(const BudgetState()) {
    if (_realm != null) {
      _init();
    }
  }

  void _init() {
    final realm = _realm;
    if (realm == null) return;

    state = state.copyWith(isLoading: true);
    _checkRecurringBudgets();
    
    // Initial Load
    _recalculateAllBudgets();
    _updateState();

    // Listen to Transaction changes -> Recalculate Spent & Saved (debounced)
    _transactionSubscription = realm.all<TransactionModel>().changes.listen((changes) {
      _recalculateDebounceTimer?.cancel();
      _recalculateDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _recalculateAllBudgets();
        _recalculateAllGoals();
      });
    });

    // Listen to Budget changes -> Update UI
    _budgetSubscription = realm.all<BudgetModel>().changes.listen((changes) {
      _updateState();
    });

    // Listen to Goal changes -> Update UI
    _goalSubscription = realm.all<SavingsGoalModel>().changes.listen((changes) {
      _updateState();
    });
  }

  @override
  void dispose() {
    _recalculateDebounceTimer?.cancel();
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }

  void _updateState() {
    final realm = _realm;
    if (realm == null) return;
    final budgets = realm.all<BudgetModel>().toList();
    final goals = realm.all<SavingsGoalModel>().toList();
    state = state.copyWith(
      budgets: budgets,
      goals: goals,
      isLoading: false,
    );
  }

  void _recalculateAllBudgets() {
    final realm = _realm;
    if (realm == null) return;
    final budgets = realm.all<BudgetModel>().toList();
    
    realm.write(() {
      for (final budget in budgets) {
        final spent = _calculateSpent(budget);
        if (budget.currentSpent != spent) {
          budget.currentSpent = spent;
        }
      }
    });
  }

  void _recalculateAllGoals() {
    final realm = _realm;
    if (realm == null) return;
    final goals = realm.all<SavingsGoalModel>().toList();
    
    realm.write(() {
      for (final goal in goals) {
        final saved = _calculateSaved(goal);
        if (goal.currentSaved != saved) {
          goal.currentSaved = saved;
        }
      }
    });
  }

  double _calculateSaved(SavingsGoalModel goal) {
    final realm = _realm;
    if (realm == null) return 0.0;
    
    // Query transactions linked to this goal via goalId field
    final transactions = realm.all<TransactionModel>().query(
      'goalId == \$0', [goal.id.toString()]
    );
    
    double total = 0.0;
    for (var t in transactions) {
      if (t.type == TransactionType.cashExpense.name) {
        // Expense to goal = money saved
        total += t.amount;
      } else if (t.type == TransactionType.cashIncome.name) {
        // Withdrawal from goal = money taken out
        total -= t.amount;
      }
    }
    return total < 0 ? 0 : total;
  }

  void _checkRecurringBudgets() {
    final realm = _realm;
    if (realm == null) return;

    final now = DateTime.now();
    final budgets = realm.all<BudgetModel>().toList();
    final newBudgets = <BudgetModel>[];
    final budgetsToArchive = <BudgetModel>[];
    
    for (final budget in budgets) {
      if (budget.isRecurring && budget.endDate.isBefore(now)) {
        budgetsToArchive.add(budget);
        
        // Create new budget for the CURRENT month
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final newBudget = BudgetModel(
          ObjectId(),
          budget.category,
          budget.amountLimit,
          0.0, // Reset spent
          startOfMonth,
          endOfMonth,
          isRecurring: true, // New one is recurring
        );
        newBudgets.add(newBudget);
      }
    }

    if (budgetsToArchive.isEmpty && newBudgets.isEmpty) return;

    realm.write(() {
      for (final b in budgetsToArchive) {
        b.isRecurring = false; // Archive the old one
      }
      realm.addAll(newBudgets);
    });
  }

  double _calculateSpent(BudgetModel budget) {
    final realm = _realm;
    if (realm == null) return 0;

    final transactions = realm.query<TransactionModel>(
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
    final realm = _realm;
    if (realm == null) return;
    realm.write(() {
      realm.add(budget);
    });
    // No need to call loadBudgets(), subscription will handle it
  }

  void addGoal(SavingsGoalModel goal) {
    final realm = _realm;
    if (realm == null) return;
    realm.write(() {
      realm.add(goal);
    });
  }

  void deleteBudget(ObjectId id) {
    final realm = _realm;
    if (realm == null) return;
    final budget = realm.find<BudgetModel>(id);
    if (budget != null) {
      realm.write(() {
        realm.delete(budget);
      });
    }
  }

  void deleteGoal(ObjectId id) {
    final realm = _realm;
    if (realm == null) return;
    final goal = realm.find<SavingsGoalModel>(id);
    if (goal != null) {
      realm.write(() {
        realm.delete(goal);
      });
    }
  }

  void editGoal(SavingsGoalModel goal, {String? name, double? targetAmount, String? icon, DateTime? deadline}) {
    final realm = _realm;
    if (realm == null) return;
    
    realm.write(() {
      if (name != null) goal.name = name;
      if (targetAmount != null) goal.targetAmount = targetAmount;
      if (icon != null) goal.icon = icon;
      if (deadline != null) goal.deadline = deadline;
    });
  }

  void editBudget(BudgetModel budget, {double? amountLimit, DateTime? startDate, DateTime? endDate}) {
    final realm = _realm;
    if (realm == null) return;

    realm.write(() {
      if (amountLimit != null) budget.amountLimit = amountLimit;
      if (startDate != null) budget.startDate = startDate;
      if (endDate != null) budget.endDate = endDate;
    });
  }

  void updateGoalAmount(ObjectId id, double newAmount) {
    final realm = _realm;
    if (realm == null) return;
    final goal = realm.find<SavingsGoalModel>(id);
    if (goal != null) {
      realm.write(() {
        goal.currentSaved = newAmount;
      });
    }
  }
  
  /// Adds funds to a goal and records a corresponding expense transaction.
  /// Throws [Exception] if funds are insufficient.
  void updateGoal(SavingsGoalModel goal, double amountAdded) {
    final realm = _realm;
    if (realm == null) return;
    
    // 1. Check Balance
    final currentBalance = _calculateCurrentBalance();
    if (currentBalance < amountAdded) {
      throw Exception('Insufficient funds. Current balance: $currentBalance');
    }

    realm.write(() {
      // 2. Update Goal
      goal.currentSaved += amountAdded;

      // 3. Create Transaction (Expense) linked to goal
      final transaction = TransactionModel(
        const Uuid().v4(),
        TransactionType.cashExpense.name,
        amountAdded,
        DateTime.now(),
        category: 'Savings',
        note: 'Contribution to goal: ${goal.name}',
        goalId: goal.id.toString(), // Link to goal
      );
      realm.add(transaction);
    });
  }

  void withdrawFromGoal(SavingsGoalModel goal, double amountWithdrawn) {
    final realm = _realm;
    if (realm == null) return;
    
    if (goal.currentSaved < amountWithdrawn) {
       throw Exception('Insufficient savings in goal.');
    }

    realm.write(() {
      goal.currentSaved -= amountWithdrawn;

      // Create Transaction (Income - money back to cash)
      final transaction = TransactionModel(
        const Uuid().v4(),
        TransactionType.cashIncome.name,
        amountWithdrawn,
        DateTime.now(),
        category: 'Savings', 
        note: 'Withdrawal from goal: ${goal.name}',
        goalId: goal.id.toString(), // Link to goal
      );
      realm.add(transaction);
    });
  }

  double _calculateCurrentBalance() {
    final realm = _realm;
    if (realm == null) return 0;
    final transactions = realm.all<TransactionModel>();
    
    double balance = 0;
    for (final t in transactions) {
      final type = t.type;
      if (type == TransactionType.paymentReceived.name || 
          type == TransactionType.cashSale.name || 
          type == TransactionType.cashIncome.name) {
        balance += t.amount;
      } else if (type == TransactionType.paymentMade.name || 
                 type == TransactionType.cashExpense.name) {
        balance -= t.amount;
      }
    }
    return balance;
  }
}
