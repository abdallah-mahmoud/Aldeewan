import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';

class BudgetList extends ConsumerWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;

    if (budgetState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (budgetState.budgets.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet, // "No budgets set"
        icon: LucideIcons.wallet,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: budgetState.budgets.length,
      itemBuilder: (context, index) {
        final budget = budgetState.budgets[index];
        final progress = budget.amountLimit > 0 ? budget.currentSpent / budget.amountLimit : 0.0;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CategoryHelper.getLocalizedCategory(budget.category, l10n), style: Theme.of(context).textTheme.titleMedium),
                    Text('${CurrencyFormatter.format(budget.currentSpent, currency)} / ${CurrencyFormatter.format(budget.amountLimit, currency)}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: progress > 1.0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
