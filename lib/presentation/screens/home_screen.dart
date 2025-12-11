import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/config/gradients.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/account_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:aldeewan_mobile/data/services/sync_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/hero_balance_card.dart';
import 'package:aldeewan_mobile/presentation/widgets/summary_stat_card.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

enum SummaryRange { all, month }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  SummaryRange _range = SummaryRange.all;
  bool _isSyncing = false;

  Future<void> _syncAccounts() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(syncServiceProvider).syncAllAccounts();
      // Refresh accounts list
      ref.read(accountProvider.notifier).loadAccounts();
      // Refresh ledger if needed (though ledger provider might need to be updated to fetch from DB again)
      await ref.read(ledgerProvider.notifier).loadData(); 
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerProvider);
    final accountState = ref.watch(accountProvider);
    final ledgerNotifier = ref.read(ledgerProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String formatCurrency(double amount) {
      final isSDG = currency == 'SDG';
      return NumberFormat.currency(symbol: currency, decimalDigits: isSDG ? 0 : 2).format(amount);
    }

    // Derive filtered transactions for the selected range.
    final transactions = ledgerState.transactions;
    final now = DateTime.now();
    final filteredTransactions = _range == SummaryRange.all
        ? transactions
        : transactions.where((t) => t.date.year == now.year && t.date.month == now.month).toList();

    // Compute simple filtered stats for hero + summary cards.
    double totalIncome = 0;
    double totalExpense = 0;
    for (final t in filteredTransactions) {
      if (t.type == TransactionType.cashSale ||
          t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashIncome) {
        totalIncome += t.amount;
      } else if (t.type == TransactionType.paymentMade ||
          t.type == TransactionType.cashExpense) {
        totalExpense += t.amount;
      }
    }
    final net = totalIncome - totalExpense;
    final netSubtitle = net >= 0 ? l10n.customersOweYouMore : l10n.youOweSuppliersMore;

    return Scaffold(
      body: ledgerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.tagline,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Icon(LucideIcons.bell, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Accounts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.myAccounts,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.comingSoon,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_isSyncing) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ] else ...[
                              IconButton(
                                icon: const Icon(LucideIcons.refreshCw, size: 16),
                                onPressed: _syncAccounts,
                                tooltip: 'Sync Accounts',
                              ),
                            ],
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/link-account'),
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: Text(l10n.link),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: ref.watch(realmProvider).when(
                        data: (_) {
                          final accounts = accountState;
                          if (accounts.isEmpty) {
                            return GestureDetector(
                              onTap: () => context.push('/link-account'),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.landmark, size: 32, color: theme.colorScheme.primary),
                                    const SizedBox(height: 8),
                                    Text(l10n.linkBankAccount, style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: accounts.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final account = accounts[index];
                              return Container(
                                width: 240,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.getAccountGradient(index),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(LucideIcons.wallet, color: Colors.white),
                                        Text(
                                          account.accountType,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatCurrency(account.balance),
                                          style: theme.textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text(l10n.errorLoadingAccounts)),
                      ),
                    ),
                    const SizedBox(height: 24),

                  // Range filter chips
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.all),
                        selected: _range == SummaryRange.all,
                        onSelected: (_) {
                          setState(() => _range = SummaryRange.all);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.thisMonth),
                        selected: _range == SummaryRange.month,
                        onSelected: (_) {
                          setState(() => _range = SummaryRange.month);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Hero net balance card
                  HeroBalanceCard(
                    title: l10n.netPosition,
                    subtitle: netSubtitle,
                    amount: formatCurrency(net),
                  ),
                  const SizedBox(height: 16),
                  // Summary stats grid (using global totals for now; can refine to range-based later)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      SummaryStatCard(
                        label: l10n.totalReceivable,
                        value: formatCurrency(ledgerNotifier.totalReceivable),
                        icon: LucideIcons.arrowDownCircle,
                        color: Colors.green,
                      ),
                      SummaryStatCard(
                        label: l10n.totalPayable,
                        value: formatCurrency(ledgerNotifier.totalPayable),
                        icon: LucideIcons.arrowUpCircle,
                        color: Colors.red,
                      ),
                      SummaryStatCard(
                        label: l10n.monthlyIncome,
                        value: formatCurrency(ledgerNotifier.monthlyIncome),
                        icon: LucideIcons.arrowDownCircle,
                        color: Colors.green,
                      ),
                      SummaryStatCard(
                        label: l10n.monthlyExpense,
                        value: formatCurrency(ledgerNotifier.monthlyExpense),
                        icon: LucideIcons.arrowUpCircle,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.quickActions,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickActions(context, l10n, isDark),
                  const SizedBox(height: 24),
                  Text(
                    l10n.allTransactions,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildRecentActivity(context, ledgerState.transactions, l10n, isDark, formatCurrency),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    List<dynamic> transactions,
    AppLocalizations l10n,
    bool isDark,
    String Function(double) formatCurrency,
  ) {
    if (transactions.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet,
        icon: LucideIcons.history,
      );
    }

    final recent = List.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final limited = recent.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limited.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = limited[index];

        final isPositive = tx.type.toString().toLowerCase().contains('sale') ||
            tx.type.toString().toLowerCase().contains('received') ||
            tx.type.toString().toLowerCase().contains('income');

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDark 
              ? BorderSide(color: Colors.white.withValues(alpha: 0.05))
              : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                color: isPositive ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              _getLocalizedTransactionType(tx.type, l10n),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              DateFormat.yMMMd().format(tx.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              '${isPositive ? '+' : '-'} ${formatCurrency(tx.amount)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLocalizedTransactionType(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.saleOnCredit:
        return l10n.saleOnCredit;
      case TransactionType.paymentReceived:
        return l10n.paymentReceived;
      case TransactionType.purchaseOnCredit:
        return l10n.purchaseOnCredit;
      case TransactionType.paymentMade:
        return l10n.paymentMade;
      case TransactionType.cashSale:
        return l10n.cashSale;
      case TransactionType.cashIncome:
        return l10n.cashIncome;
      case TransactionType.cashExpense:
        return l10n.cashExpense;
    }
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionButton(
          context,
          l10n.addDebt,
          LucideIcons.filePlus2,
          () {
             context.push('/ledger?action=debt');
          },
          isDark,
        ),
        _buildActionButton(
          context,
          l10n.recordPayment,
          LucideIcons.creditCard,
          () {
             context.push('/ledger?action=payment');
          },
          isDark,
        ),
        _buildActionButton(
          context,
          l10n.addCashEntry,
          LucideIcons.plusCircle,
          () {
             context.push('/cashbook?action=add');
          },
          isDark,
        ),
        _buildActionButton(
          context,
          l10n.viewBalances,
          LucideIcons.scale,
          () => context.go('/ledger'),
          isDark,
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
