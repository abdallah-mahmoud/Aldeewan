import 'package:aldeewan_mobile/config/gradients.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/expense_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final ledgerState = ref.watch(ledgerProvider);
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Budget'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Budgets'),
            Tab(text: 'Goals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expenses by Category', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                ExpensePieChart(transactions: ledgerState.transactions),
                const SizedBox(height: 32),
                Text('Budget Summary', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                if (budgetState.budgets.isEmpty)
                  const Text('No budgets set. Go to Budgets tab to add one.')
                else
                  ...budgetState.budgets.map((budget) {
                    final progress = (budget.currentSpent / budget.amountLimit).clamp(0.0, 1.0);
                    final isOverBudget = budget.currentSpent > budget.amountLimit;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(budget.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${NumberFormat.compact().format(budget.currentSpent)} / ${NumberFormat.compact().format(budget.amountLimit)} $currency',
                                  style: TextStyle(
                                    color: isOverBudget ? Colors.red : null,
                                    fontWeight: isOverBudget ? FontWeight.bold : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: isOverBudget 
                                        ? AppGradients.budgetDanger 
                                        : (progress > 0.8 ? AppGradients.budgetWarning : AppGradients.budgetSafe),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),

          // Budgets Tab
          Scaffold(
            body: budgetState.budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.wallet, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No budgets yet'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _showAddBudgetDialog(context),
                          child: const Text('Create Budget'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: budgetState.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgetState.budgets[index];
                      return ListTile(
                        title: Text(budget.category),
                        subtitle: Text('Limit: ${budget.amountLimit} $currency'),
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.trash2, color: Colors.red),
                          onPressed: () => ref.read(budgetProvider.notifier).deleteBudget(budget.id),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddBudgetDialog(context),
              child: const Icon(LucideIcons.plus),
            ),
          ),

          // Goals Tab
          Scaffold(
            body: budgetState.goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.target, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No savings goals yet'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _showAddGoalDialog(context),
                          child: const Text('Create Goal'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: budgetState.goals.length,
                    itemBuilder: (context, index) {
                      final goal = budgetState.goals[index];
                      final progress = (goal.currentSaved / goal.targetAmount).clamp(0.0, 1.0);
                      
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 8),
                              Text('${(progress * 100).toInt()}%'),
                              Text(
                                '${NumberFormat.compact().format(goal.currentSaved)} / ${NumberFormat.compact().format(goal.targetAmount)} $currency',
                                style: theme.textTheme.bodySmall,
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.plusCircle),
                                onPressed: () => _showAddMoneyToGoalDialog(context, goal),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddGoalDialog(context),
              child: const Icon(LucideIcons.plus),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category (e.g. Food)'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Monthly Limit'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final budget = BudgetModel()
                ..category = categoryController.text
                ..amountLimit = double.tryParse(amountController.text) ?? 0
                ..currentSpent = 0
                ..startDate = DateTime(DateTime.now().year, DateTime.now().month, 1)
                ..endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
                ..isRecurring = true;
              
              ref.read(budgetProvider.notifier).addBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final goal = SavingsGoalModel()
                ..name = nameController.text
                ..targetAmount = double.tryParse(targetController.text) ?? 0
                ..currentSaved = 0;
              
              ref.read(budgetProvider.notifier).addGoal(goal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMoneyToGoalDialog(BuildContext context, SavingsGoalModel goal) async {
    final amountController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${goal.name}'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount to Add'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              ref.read(budgetProvider.notifier).updateGoalAmount(goal.id, amount);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
