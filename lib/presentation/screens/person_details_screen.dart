import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';

class PersonDetailsScreen extends ConsumerWidget {
  final String personId;

  const PersonDetailsScreen({super.key, required this.personId});

  void _showAddTransactionModal(BuildContext context, WidgetRef ref, Person person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        personId: person.id,
        initialType: person.role == PersonRole.customer
            ? TransactionType.saleOnCredit
            : TransactionType.purchaseOnCredit,
        onSave: (transaction) {
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerState = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);

    final person = ledgerState.persons.firstWhere(
      (p) => p.id == personId,
      orElse: () => Person(
        id: 'not-found',
        role: PersonRole.customer,
        name: 'Not Found',
        createdAt: DateTime.now(),
      ),
    );

    if (person.id == 'not-found') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.personNotFound)),
        body: Center(child: Text(l10n.personNotFound)),
      );
    }

    final transactions = ledgerState.transactions
        .where((t) => t.personId == personId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final balance = notifier.calculatePersonBalance(person);
    
    // Determine balance color
    final isAsset = (person.role == PersonRole.customer && balance > 0) || 
                    (person.role == PersonRole.supplier && balance < 0);
    final isLiability = (person.role == PersonRole.supplier && balance > 0) || 
                        (person.role == PersonRole.customer && balance < 0);
    
    Color balanceColor = Theme.of(context).colorScheme.onSurface;
    if (balance != 0) {
      balanceColor = isAsset ? Colors.green : (isLiability ? Colors.red : Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // TODO: Edit Person
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () {
              // TODO: Confirm Delete
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentBalance,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance.abs().toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: balanceColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          balance == 0 
                              ? l10n.settled 
                              : (person.role == PersonRole.customer 
                                  ? (balance > 0 ? l10n.receivable : l10n.advance) 
                                  : (balance > 0 ? l10n.payable : l10n.advance)),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? EmptyState(
                    message: l10n.noEntriesYet,
                    icon: LucideIcons.history,
                    actionLabel: l10n.addTransaction,
                    onAction: () => _showAddTransactionModal(context, ref, person),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      // Logic for icon/color:
                      // Sale/Purchase (Debt increases) -> Arrow Up? Or specific icon.
                      // Payment (Debt decreases) -> Arrow Down?
                      
                      final isDebtIncrease = tx.type == TransactionType.saleOnCredit || 
                                             tx.type == TransactionType.purchaseOnCredit;
                      
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: Theme.of(context).cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDebtIncrease
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDebtIncrease
                                  ? LucideIcons.fileText
                                  : LucideIcons.banknote,
                              color: isDebtIncrease ? Colors.orange : Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _getTransactionLabel(tx.type, l10n),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tx.amount.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDebtIncrease ? Colors.orange : Colors.blue,
                                ),
                              ),
                              if (tx.note != null && tx.note!.isNotEmpty)
                                Text(
                                  tx.note!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionModal(context, ref, person),
        label: Text(l10n.addTransaction),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }

  String _getTransactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.saleOnCredit: return l10n.saleOnCredit;
      case TransactionType.paymentReceived: return l10n.paymentReceived;
      case TransactionType.purchaseOnCredit: return l10n.purchaseOnCredit;
      case TransactionType.paymentMade: return l10n.paymentMade;
      case TransactionType.cashSale: return l10n.cashSale;
      case TransactionType.cashIncome: return l10n.cashIncome;
      case TransactionType.cashExpense: return l10n.cashExpense;
    }
  }
}
