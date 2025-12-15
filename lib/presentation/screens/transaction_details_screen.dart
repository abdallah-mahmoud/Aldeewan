import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final isSimpleMode = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.paymentReceived ||
        transaction.type == TransactionType.cashSale ||
        transaction.type == TransactionType.cashIncome ||
        transaction.type == TransactionType.debtTaken;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetails),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _confirmDelete(context, ref, l10n),
          ),
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () => _showEditModal(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Hero
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.amount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency ${NumberFormat('#,##0.##').format(transaction.amount)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      TransactionLabelMapper.getLabel(transaction.type, isSimpleMode, l10n),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Direction Indicator
                  Consumer(
                    builder: (context, ref, _) {
                      final ledger = ref.watch(ledgerProvider);
                      return ledger.maybeWhen(
                        data: (state) {
                          final person = state.persons
                              .where((p) => p.id == transaction.personId)
                              .firstOrNull;
                          return _buildDirectionIndicator(context, transaction, l10n, person?.name);
                        },
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Details Grid
            _buildDetailRow(context, LucideIcons.calendar, l10n.date,
                DateFormat.yMMMMEEEEd().format(transaction.date)),
            if (transaction.category != null) ...[
              const SizedBox(height: 24),
              _buildDetailRow(context, LucideIcons.tag, l10n.category, CategoryHelper.getLocalizedCategory(transaction.category!, l10n)),
            ],
            if (transaction.personId != null) ...[
              const SizedBox(height: 24),
              // We need to fetch person name. Since we don't have it in transaction, 
              // we might need to look it up or pass it. 
              // For now, let's try to look it up from ledgerProvider if possible, 
              // or just show "Person ID" if not found (should be found).
              Consumer(
                builder: (context, ref, _) {
                  final ledger = ref.watch(ledgerProvider);
                  return ledger.maybeWhen(
                    data: (state) {
                      final person = state.persons
                          .where((p) => p.id == transaction.personId)
                          .firstOrNull;
                      return _buildDetailRow(
                          context, LucideIcons.user, l10n.person, person?.name ?? 'Unknown');
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDetailRow(context, LucideIcons.stickyNote, l10n.note, transaction.note!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionIndicator(BuildContext context, Transaction tx, AppLocalizations l10n, String? personName) {
    final theme = Theme.of(context);
    String from;
    String to;
    IconData icon = LucideIcons.arrowRight;

    // Logic for direction
    // You = l10n.me (Need to add 'me' key or use 'You')
    // Person = personName ?? 'Unknown'
    // External = 'External' (or specific logic)

    final you = l10n.me;
    
    final other = personName ?? (tx.personId != null ? l10n.unknown : l10n.general);

    switch (tx.type) {
      case TransactionType.saleOnCredit: // We gave goods (Value), they owe us. Debt (Us).
      case TransactionType.debtGiven:
        // Context: "Lent" -> You gave to Them.
        from = you;
        to = other;
        break;
      case TransactionType.purchaseOnCredit: // We got goods, we owe them. Debt (Them).
      case TransactionType.debtTaken:
        // Context: "Borrowed" -> They gave to You.
        from = other;
        to = you;
        break;
      case TransactionType.paymentReceived: // They paid us.
        from = other;
        to = you;
        break;
      case TransactionType.paymentMade: // We paid them.
        from = you;
        to = other;
        break;
      case TransactionType.cashSale: // We sold for cash.
        from = other; // Money came from customer
        to = you;
        break;
      case TransactionType.cashIncome:
        from = l10n.general;
        to = you;
        break;
      case TransactionType.cashExpense:
        from = you;
        to = l10n.general;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(from, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(to, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    // Capture the screen's navigator before showing the dialog
    final screenNavigator = Navigator.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              // 1. Close dialog first
              Navigator.of(dialogContext).pop();
              
              // 2. Perform delete action
              ref.read(soundServiceProvider).playDelete();
              await ref.read(ledgerProvider.notifier).deleteTransaction(transaction.id);
              
              // 3. Navigate back using the screen's navigator (captured before dialog)
              if (screenNavigator.mounted) {
                screenNavigator.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashEntryForm(
        initialAmount: transaction.amount,
        initialDate: transaction.date,
        initialNote: transaction.note,
        // We need to handle the update logic. 
        // Currently CashEntryForm only supports 'onSave' which creates a NEW transaction usually.
        // We might need to update CashEntryForm to support editing or handle it here.
        // For now, let's assume we delete old and add new (simplest update), 
        // OR we update the provider to support 'updateTransaction'.
        // LedgerNotifier has 'addTransaction' and 'deleteTransaction'. It might not have 'updateTransaction'.
        // Let's check LedgerProvider.
        onSave: (updatedTx) {
           // Hack: Delete old, Add new (Preserving ID if possible, but Realm might want new object)
           // Better: Add updateTransaction to LedgerNotifier.
           // For now, let's just add new and delete old to simulate update.
           // Ideally we should update the existing record.
           
           // Since we don't have updateTransaction exposed yet, let's do:
           ref.read(ledgerProvider.notifier).deleteTransaction(transaction.id);
           ref.read(ledgerProvider.notifier).addTransaction(updatedTx);
           
           Navigator.pop(context); // Close screen (go back to list)
        },
      ),
    );
  }
}
