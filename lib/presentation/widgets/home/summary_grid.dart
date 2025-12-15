import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/summary_stat_card.dart';

class SummaryGrid extends ConsumerWidget {
  const SummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    String formatCurrency(double amount) {
      final isSDG = currency == 'SDG';
      return NumberFormat.currency(symbol: currency, decimalDigits: isSDG ? 0 : 2).format(amount);
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        SummaryStatCard(
          label: l10n.totalReceivable,
          value: formatCurrency(ref.watch(totalReceivableProvider)),
          icon: LucideIcons.arrowDownCircle,
          color: Colors.green,
          onTap: () => context.go('/ledger'), // Defaults to Customers tab
        ),
        SummaryStatCard(
          label: l10n.totalPayable,
          value: formatCurrency(ref.watch(totalPayableProvider)),
          icon: LucideIcons.arrowUpCircle,
          color: Colors.red,
          onTap: () => context.go('/ledger'), // Ideally switch to Suppliers tab
        ),
        SummaryStatCard(
          label: l10n.monthlyIncome,
          value: formatCurrency(ref.watch(monthlyIncomeProvider)),
          icon: LucideIcons.arrowDownCircle,
          color: Colors.green,
          onTap: () {
            // Set filters before navigating
            ref.read(cashFilterProvider.notifier).state = CashFilter.income;
            ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
            context.go('/cashbook');
          },
        ),
        SummaryStatCard(
          label: l10n.monthlyExpense,
          value: formatCurrency(ref.watch(monthlyExpenseProvider)),
          icon: LucideIcons.arrowUpCircle,
          color: Colors.red,
          onTap: () {
            // Set filters before navigating
            ref.read(cashFilterProvider.notifier).state = CashFilter.expense;
            ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
            context.go('/cashbook');
          },
        ),
      ],
    );
  }
}

