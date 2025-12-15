import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/utils/animation_extensions.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerState = ref.watch(ledgerProvider).value;
    final transactions = ledgerState?.transactions ?? [];
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String formatCurrency(double amount) {
      final isSDG = currency == 'SDG';
      return NumberFormat.currency(symbol: currency, decimalDigits: isSDG ? 0 : 2).format(amount);
    }

    if (transactions.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet,
        icon: LucideIcons.history,
        // TODO: Add 'assets/animations/empty_list.json'
        lottieAsset: 'assets/animations/empty_list.json',
      );
    }

    final recent = List<Transaction>.from(transactions)
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

        return RepaintBoundary(
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.cardTheme.color,
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
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                  color: isPositive ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ),
              title: Text(
                _getLocalizedTransactionType(tx.type, l10n),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                DateFormat.yMMMd().format(tx.date),
                style: theme.textTheme.bodySmall,
              ),
              trailing: Text(
                '${isPositive ? '+' : '-'} ${formatCurrency(tx.amount)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ),
        ).animateListItem(index);
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
      case TransactionType.debtGiven:
        return l10n.debtGiven;
      case TransactionType.debtTaken:
        return l10n.debtTaken;
    }
  }
}
