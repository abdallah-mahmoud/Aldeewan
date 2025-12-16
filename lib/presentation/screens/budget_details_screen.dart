import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';

class BudgetDetailsScreen extends ConsumerWidget {
  final String budgetId;

  const BudgetDetailsScreen({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final budgetState = ref.watch(budgetProvider);
    // Use select to only watch transactions, not entire ledger state
    final transactions = ref.watch(ledgerProvider.select((s) => s.value?.transactions ?? <Transaction>[]));
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0.##');

    final budget = budgetState.budgets.cast<BudgetModel?>().firstWhere(
          (b) => b?.id.toString() == budgetId,
          orElse: () => null,
        );

    if (budget == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.budgetDetails)),
        body: EmptyState(
          message: l10n.budgetNotFound,
          icon: LucideIcons.alertCircle,
        ),
      );
    }

    final progress = budget.amountLimit > 0 ? budget.currentSpent / budget.amountLimit : 0.0;
    final isOverBudget = budget.currentSpent > budget.amountLimit;
    final remaining = budget.amountLimit - budget.currentSpent;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetDetails),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () => _showEditBudgetDialog(context, ref, budget),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _confirmDelete(context, ref, budget),
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
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CategoryHelper.getIcon(budget.category),
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CategoryHelper.getLocalizedCategory(budget.category, l10n),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat.yMMMd().format(budget.startDate)} - ${DateFormat.yMMMd().format(budget.endDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
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
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.spent,
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '$currency ${formatter.format(budget.currentSpent)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? theme.colorScheme.error : null,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.limit,
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '$currency ${formatter.format(budget.amountLimit)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOverBudget 
                    ? theme.colorScheme.errorContainer 
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverBudget ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                    color: isOverBudget 
                        ? theme.colorScheme.onErrorContainer 
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isOverBudget 
                          ? l10n.budgetExceededMessage(currency, formatter.format(budget.currentSpent - budget.amountLimit))
                          : l10n.budgetRemainingMessage(currency, formatter.format(remaining)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isOverBudget 
                            ? theme.colorScheme.onErrorContainer 
                            : theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    label: l10n.addTransaction,
                    color: theme.colorScheme.primary,
                    onTap: () => _showAddExpenseSheet(context, ref, budget),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transactions List
            Text(
              l10n.recentTransactions,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTransactionList(context, budget, transactions, currency, formatter),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    BudgetModel budget,
    List<Transaction> allTransactions,
    String currency,
    NumberFormat formatter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Filter transactions
    final transactions = allTransactions.where((t) {
      // Check if transaction date is within budget period
      final isWithinDate = t.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) && 
                           t.date.isBefore(budget.endDate.add(const Duration(days: 1)));
      
      // Check if category matches (assuming transaction has category field or we infer it)
      // Note: Transaction entity might not have category directly if it's a debt/payment.
      // But Cashbook entries do. If this budget is for Cashbook categories, we need to check that.
      // If it's for Ledger categories (which don't really exist in the same way), it's tricky.
      // Assuming Budget is for Cashbook categories for now.
      // Wait, Transaction entity has 'type' but not 'category' unless it's a cash entry?
      // Let's check Transaction entity.
      return isWithinDate && (t.category == budget.category);
    }).toList();

    if (transactions.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet,
        icon: LucideIcons.history,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryHelper.getIcon(tx.category),
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              (tx.note ?? '').isNotEmpty ? tx.note! : CategoryHelper.getLocalizedCategory(tx.category ?? '', l10n),
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(DateFormat.yMMMd().format(tx.date)),
            trailing: Text(
              '$currency ${formatter.format(tx.amount)}',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;
    final limitController = TextEditingController(text: budget.amountLimit.toString());
    DateTime startDate = budget.startDate;
    DateTime endDate = budget.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.editBudget),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: limitController,
                    decoration: InputDecoration(labelText: l10n.limit),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(l10n.startDate),
                    subtitle: Text(DateFormat.yMMMd().format(startDate)),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(l10n.endDate),
                    subtitle: Text(DateFormat.yMMMd().format(endDate)),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
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
                  final limit = double.tryParse(limitController.text) ?? 0.0;
                  
                  if (limit <= 0) {
                    return;
                  }

                  ref.read(budgetProvider.notifier).editBudget(
                    budget,
                    amountLimit: limit,
                    startDate: startDate,
                    endDate: endDate,
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

  void _confirmDelete(BuildContext context, WidgetRef ref, BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.deleteBudgetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
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

  void _showAddExpenseSheet(BuildContext context, WidgetRef ref, BudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashEntryForm(
        initialCategory: budget.category,
        initialType: TransactionType.cashExpense,
        onSave: (transaction) {
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
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
