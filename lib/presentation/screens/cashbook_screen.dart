import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/category_provider.dart';
import 'package:aldeewan_mobile/presentation/screens/transaction_details_screen.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/presentation/widgets/debounced_search_bar.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';

class CashbookScreen extends ConsumerStatefulWidget {
  const CashbookScreen({super.key});

  @override
  ConsumerState<CashbookScreen> createState() => _CashbookScreenState();
}

class _CashbookScreenState extends ConsumerState<CashbookScreen> {
  bool _initialActionHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialActionHandled) {
      final uri = GoRouterState.of(context).uri;
      final action = uri.queryParameters['action'];
      final filterParam = uri.queryParameters['filter'];
      
      // Handle filter query parameter (from dashboard cards)
      if (filterParam != null) {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (filterParam == 'income') {
            ref.read(cashFilterProvider.notifier).state = CashFilter.income;
          } else if (filterParam == 'expense') {
            ref.read(cashFilterProvider.notifier).state = CashFilter.expense;
          }
        });
      }
      
      // Handle add action query parameter (from receipt scanner)
      if (action == 'add') {
        _initialActionHandled = true;
        
        double? initialAmount;
        DateTime? initialDate;
        String? initialNote;

        if (uri.queryParameters.containsKey('amount')) {
          initialAmount = double.tryParse(uri.queryParameters['amount']!);
        }
        if (uri.queryParameters.containsKey('date')) {
          initialDate = DateTime.tryParse(uri.queryParameters['date']!);
        }
        initialNote = uri.queryParameters['note'];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showAddCashEntryModal(context, ref, initialAmount, initialDate, initialNote);
        });
      }
    }
  }

  void _showAddCashEntryModal(
    BuildContext context, 
    WidgetRef ref, [
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashEntryForm(
        initialAmount: initialAmount,
        initialDate: initialDate,
        initialNote: initialNote,
        onSave: (transaction) {
          ref.read(soundServiceProvider).playMoneyIn();
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashbookAsync = ref.watch(cashbookProvider);
    final ledgerAsync = ref.watch(ledgerProvider); // Needed for person name lookup in list items
    final filter = ref.watch(cashFilterProvider);
    final datePreset = ref.watch(dateRangePresetProvider);
    final currency = ref.watch(currencyProvider);
    final categories = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,##0.##');
    final searchQuery = ref.watch(cashbookSearchProvider);
    final isSimpleMode = ref.watch(settingsProvider);

    return cashbookAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())))),
      data: (cashbookState) {
        // 1. Get filtered list from state (already filtered by date/type/filters)
        var filteredList = cashbookState.transactions;
        
        // 2. Apply Search Locally
        if (searchQuery.isNotEmpty) {
          final lowerQuery = searchQuery.toLowerCase();
          filteredList = filteredList.where((tx) {
            // Search by note
            if ((tx.note ?? '').toLowerCase().contains(lowerQuery)) return true;
            
            // Search by category (EN + AR localized)
            final categoryEN = (tx.category ?? '').toLowerCase();
            final categoryAR = CategoryHelper.getLocalizedCategory(tx.category ?? '', l10n).toLowerCase();
            if (categoryEN.contains(lowerQuery) || categoryAR.contains(lowerQuery)) return true;
            
            // Search by person name
            if (tx.personId != null) {
              try {
                final persons = ledgerAsync.value?.persons ?? [];
                final person = persons.firstWhere((p) => p.id == tx.personId);
                if (person.name.toLowerCase().contains(lowerQuery)) return true;
              } catch (_) {}
            }
            
            // Search by amount (raw + formatted)
            final amountStr = tx.amount.toString();
            final formattedAmount = numberFormat.format(tx.amount);
            if (amountStr.contains(lowerQuery) || formattedAmount.contains(lowerQuery)) return true;
            
            // Search by transaction type (bilingual EN/AR)
            final typeLabel = TransactionLabelMapper.getLabel(tx.type, isSimpleMode, l10n);
            if (typeLabel.toLowerCase().contains(lowerQuery)) return true;
            
            return false;
          }).toList();
        }

        // 3. Recalculate Totals Locally based on filtered list
        double totalIn = 0;
        double totalOut = 0;
        
        for (final t in filteredList) {
          final isIncome = t.type == TransactionType.paymentReceived ||
              t.type == TransactionType.cashSale ||
              t.type == TransactionType.cashIncome ||
              t.type == TransactionType.debtTaken;
              
          if (isIncome) {
            totalIn += t.amount;
          } else {
            totalOut += t.amount;
          }
        }
        final net = totalIn - totalOut;

        // Use filtered values for UI
        final filteredTransactions = filteredList;



        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.cashbook),
          ),
          resizeToAvoidBottomInset: false,
          body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: DebouncedSearchBar(
                    hintText: l10n.search,
                    onSearch: (query) {
                      ref.read(cashbookSearchProvider.notifier).state = query;
                    },
                  ),
                ),
                // Compact filter row with 2 dropdowns
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      // Type filter dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CashFilter>(
                              value: filter,
                              isExpanded: true,
                              icon: Icon(LucideIcons.chevronDown, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              items: [
                                DropdownMenuItem(
                                  value: CashFilter.all,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.list, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.allTransactions),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CashFilter.income,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.arrowDownLeft, size: 16, color: AppColors.success),
                                      const SizedBox(width: 8),
                                      Text(l10n.income),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CashFilter.expense,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.arrowUpRight, size: 16, color: AppColors.error),
                                      const SizedBox(width: 8),
                                      Text(l10n.expense),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(cashFilterProvider.notifier).state = value;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date filter dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateRangePreset>(
                              value: datePreset,
                              isExpanded: true,
                              icon: Icon(LucideIcons.chevronDown, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              items: [
                                DropdownMenuItem(
                                  value: DateRangePreset.all,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.infinity, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.all),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.today,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarCheck, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.today),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.thisWeek,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarDays, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.thisWeek),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.thisMonth,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.thisMonth),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.custom,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarRange, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(datePreset == DateRangePreset.custom 
                                          ? _formatDateRange(ref.watch(customDateRangeProvider))
                                          : l10n.custom),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == DateRangePreset.custom) {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: ref.read(customDateRangeProvider),
                                  );
                                  if (picked != null) {
                                    ref.read(customDateRangeProvider.notifier).state = picked;
                                    ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.custom;
                                  }
                                } else if (value != null) {
                                  ref.read(dateRangePresetProvider.notifier).state = value;
                                }
                              },
                            ),
                          ),
                        ),
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
                          color: AppColors.success,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                        _buildSummaryItem(
                          context,
                          label: l10n.expense,
                          value: totalOut,
                          color: AppColors.error,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                        _buildSummaryItem(
                          context,
                          label: 'Net',
                          value: net,
                          color: net >= 0 ? AppColors.success : AppColors.error,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter transactions tip
                const FilterTransactionsTip(),
                const Divider(height: 1),
                // List of transactions
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? EmptyState(
                          message: searchQuery.isNotEmpty ? l10n.noResults : l10n.noEntriesYet,
                          icon: LucideIcons.history,
                          lottieAsset: 'assets/animations/empty_list.json',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            // Income = cash came in (including borrowed money)
                            final isIncome = tx.type == TransactionType.paymentReceived ||
                                tx.type == TransactionType.cashSale ||
                                tx.type == TransactionType.cashIncome ||
                                tx.type == TransactionType.debtTaken; // Borrowed = cash in
                            
                            String? personName;
                            if (tx.personId != null) {
                              try {
                                final persons = ledgerAsync.value?.persons ?? [];
                                final person = persons.firstWhere((p) => p.id == tx.personId);
                                personName = person.name;
                              } catch (_) {}
                            }

                            // Find category
                            final category = categories.where((c) => c.name == tx.category).firstOrNull;

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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetailsScreen(transaction: tx),
                                    ),
                                  );
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: category != null 
                                        ? category.color.withValues(alpha: 0.1)
                                        : (isIncome ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    category != null ? category.icon : (isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight),
                                    color: category != null ? category.color : (isIncome ? AppColors.success : AppColors.error),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  category != null ? CategoryHelper.getLocalizedCategory(category.name, l10n) : _getTransactionLabel(tx.type, l10n),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat.yMMMd().format(tx.date),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        if (personName != null) ...[
                                          const SizedBox(width: 8),
                                          Icon(LucideIcons.user, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              personName,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.note!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Text(
                                  '$currency ${numberFormat.format(tx.amount)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isIncome ? AppColors.success : AppColors.error,
                                  ),
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
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required String currency,
    required NumberFormat formatter,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$currency ${formatter.format(value)}',
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  String _getTransactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.paymentReceived:
        return l10n.paymentReceived;
      case TransactionType.paymentMade:
        return l10n.paymentMade;
      case TransactionType.cashSale:
        return l10n.cashLabel; // نقد - Cash
      case TransactionType.cashIncome:
        return l10n.bankLabel; // بنك - Bank
      case TransactionType.cashExpense:
        return l10n.expense;
      case TransactionType.debtGiven:
        return l10n.debtGiven;
      case TransactionType.debtTaken:
        return l10n.debtTaken;
      default:
        return l10n.transaction;
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return '';
    final formatter = DateFormat.MMMd();
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }
}
