import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

enum CashFilter { all, income, expense }

class CashbookScreen extends ConsumerStatefulWidget {
  const CashbookScreen({super.key});

  @override
  ConsumerState<CashbookScreen> createState() => _CashbookScreenState();
}

class _CashbookScreenState extends ConsumerState<CashbookScreen> {
  CashFilter _filter = CashFilter.all;
  bool _initialActionHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialActionHandled) {
      final action = GoRouterState.of(context).uri.queryParameters['action'];
      if (action == 'add') {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddCashEntryModal(context, ref);
        });
      }
    }
  }

  void _showAddCashEntryModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashEntryForm(
        onSave: (transaction) {
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Filter for cash-related transactions
    final allCashTransactions = ledgerState.transactions.where((t) {
      return t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.paymentMade ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome ||
          t.type == TransactionType.cashExpense;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Apply income/expense filter
    final filtered = allCashTransactions.where((t) {
      final isIncome = t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome;
      if (_filter == CashFilter.income) return isIncome;
      if (_filter == CashFilter.expense) return !isIncome;
      return true;
    }).toList();

    // Compute summary for filtered list
    double totalIn = 0;
    double totalOut = 0;
    for (final t in filtered) {
      final isIncome = t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome;
      if (isIncome) {
        totalIn += t.amount;
      } else {
        totalOut += t.amount;
      }
    }
    final net = totalIn - totalOut;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashbook),
      ),
      body: ledgerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.allTransactions),
                        selected: _filter == CashFilter.all,
                        onSelected: (_) {
                          setState(() => _filter = CashFilter.all);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.income),
                        selected: _filter == CashFilter.income,
                        onSelected: (_) {
                          setState(() => _filter = CashFilter.income);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.expense),
                        selected: _filter == CashFilter.expense,
                        onSelected: (_) {
                          setState(() => _filter = CashFilter.expense);
                        },
                      ),
                    ],
                  ),
                ),
                // Summary bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          context,
                          label: l10n.income,
                          value: totalIn,
                          color: Colors.green,
                        ),
                        _buildSummaryItem(
                          context,
                          label: l10n.expense,
                          value: totalOut,
                          color: Colors.red,
                        ),
                        _buildSummaryItem(
                          context,
                          label: 'Net',
                          value: net,
                          color: net >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // List of transactions
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          message: l10n.noEntriesYet,
                          icon: LucideIcons.history,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tx = filtered[index];
                            final isIncome = tx.type == TransactionType.paymentReceived ||
                                tx.type == TransactionType.cashSale ||
                                tx.type == TransactionType.cashIncome;
                            
                            String? personName;
                            if (tx.personId != null) {
                              try {
                                final person = ledgerState.persons.firstWhere((p) => p.id == tx.personId);
                                personName = person.name;
                              } catch (_) {}
                            }

                            return Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: theme.cardTheme.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isIncome
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isIncome
                                        ? LucideIcons.arrowDownLeft
                                        : LucideIcons.arrowUpRight,
                                    color: isIncome ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  _getTransactionLabel(tx.type, l10n),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(DateFormat.yMMMd().format(tx.date)),
                                        if (personName != null) ...[
                                          const SizedBox(width: 8),
                                          Icon(LucideIcons.user, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              personName,
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      tx.amount.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isIncome ? Colors.green : Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (tx.note != null && tx.note!.isNotEmpty)
                                      Text(
                                        tx.note!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCashEntryModal(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context,
      {required String label, required double value, required Color color}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: theme.textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }

  String _getTransactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.paymentReceived:
        return l10n.payment; // Or specific key if needed
      case TransactionType.paymentMade:
        return l10n.payment;
      case TransactionType.cashSale:
        return l10n.income; // Mapping to generic income/expense for now or add specific keys
      case TransactionType.cashIncome:
        return l10n.income;
      case TransactionType.cashExpense:
        return l10n.expense;
      default:
        return l10n.transaction;
    }
  }
}
