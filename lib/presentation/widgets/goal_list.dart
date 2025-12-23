import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';

class GoalList extends ConsumerWidget {
  const GoalList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;

    if (budgetState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (budgetState.goals.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet, // "No savings goals"
        icon: LucideIcons.target,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: budgetState.goals.length,
      itemBuilder: (context, index) {
        final goal = budgetState.goals[index];
        final progress = goal.targetAmount > 0 ? goal.currentSaved / goal.targetAmount : 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(goal.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text('${CurrencyFormatter.format(goal.currentSaved, currency)} / ${CurrencyFormatter.format(goal.targetAmount, currency)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(LucideIcons.plusCircle),
              onPressed: () => _showAddSavingsDialog(context, ref, goal),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddSavingsDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal) async {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.addToGoal} ${goal.name}'), // "Add to {goal}"
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: l10n.amount),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: amountFormatters(allowFraction: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
              if (amount > 0) {
                try {
                  ref.read(budgetProvider.notifier).updateGoal(goal, amount);
                  Navigator.pop(context);
                } catch (e) {
                  // Close dialog first so error message is visible
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
