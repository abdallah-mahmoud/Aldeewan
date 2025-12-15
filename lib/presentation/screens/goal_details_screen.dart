import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';

import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/utils/icon_helper.dart';

class GoalDetailsScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final budgetState = ref.watch(budgetProvider);
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0.##');

    final goal = budgetState.goals.cast<SavingsGoalModel?>().firstWhere(
          (g) => g?.id.toString() == goalId,
          orElse: () => null,
        );

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.goalDetails)),
        body: EmptyState(
          message: l10n.goalNotFound,
          icon: LucideIcons.alertCircle,
        ),
      );
    }

    final progress = goal.targetAmount > 0 ? goal.currentSaved / goal.targetAmount : 0.0;
    final isCompleted = goal.currentSaved >= goal.targetAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalDetails),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () => _showEditGoalDialog(context, ref, goal),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _confirmDelete(context, ref, goal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (goal.deadline != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.deadline}: ${DateFormat.yMMMd().format(goal.deadline!)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? LucideIcons.checkCircle : IconHelper.getIcon(goal.icon ?? 'target'),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.saved,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$currency ${formatter.format(goal.currentSaved)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.target,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$currency ${formatter.format(goal.targetAmount)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Text(
              l10n.actions,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: LucideIcons.plus,
                    label: l10n.addFunds,
                    color: Colors.green,
                    onTap: () => _showUpdateFundsDialog(context, ref, goal, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    icon: LucideIcons.minus,
                    label: l10n.withdraw,
                    color: Colors.red,
                    onTap: () => _showUpdateFundsDialog(context, ref, goal, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toString());
    DateTime? deadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.editGoal),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.goalName),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    decoration: InputDecoration(labelText: l10n.targetAmount),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(l10n.endDate),
                    subtitle: Text(deadline != null ? DateFormat.yMMMd().format(deadline!) : l10n.noDate),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => deadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final target = double.tryParse(targetController.text) ?? 0.0;
                  
                  if (name.isEmpty || target <= 0) {
                    return;
                  }

                  ref.read(budgetProvider.notifier).editGoal(
                    goal,
                    name: name,
                    targetAmount: target,
                    deadline: deadline,
                  );
                  Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ],
          );
        }
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SavingsGoalModel goal) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteGoalConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteGoal(goal.id);
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to list
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showUpdateFundsDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal, bool isAdding) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? l10n.addFunds : l10n.withdraw),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsSeparatorInputFormatter(allowFraction: true)],
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixText: '${ref.read(currencyProvider)} ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(',', ''));
              if (amount != null && amount > 0) {
                if (isAdding && (goal.currentSaved + amount > goal.targetAmount)) {
                  final remaining = goal.targetAmount - goal.currentSaved;
                  final currency = ref.read(currencyProvider);
                  final formatter = NumberFormat('#,##0.##');
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.error),
                      content: Text(l10n.goalExceededErrorWithRemaining('$currency ${formatter.format(remaining)}')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                try {
                  if (isAdding) {
                    ref.read(budgetProvider.notifier).updateGoal(goal, amount);
                    
                    // Check if goal reached
                    if (goal.currentSaved >= goal.targetAmount) {
                      ref.read(notificationHistoryProvider.notifier).addNotification(
                        title: l10n.goalReachedTitle,
                        body: l10n.goalReachedBody(goal.name),
                        type: 'success',
                      );
                    }
                  } else {
                    if (goal.currentSaved - amount < 0) {
                      return; 
                    }
                    ref.read(budgetProvider.notifier).withdrawFromGoal(goal, amount);
                  }
                  Navigator.pop(context);
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.error),
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
