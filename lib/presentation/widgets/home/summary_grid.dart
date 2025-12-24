import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/summary_stat_card.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';

class SummaryGrid extends ConsumerWidget {
  const SummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    // Use LayoutBuilder for responsive aspect ratio on different screen densities
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic aspect ratio based on available width
        // This prevents overflow on low DPI/small screens
        final cardWidth = (constraints.maxWidth - 12.w) / 2;
        final cardHeight = cardWidth / 1.4;
        final aspectRatio = (cardWidth / cardHeight).clamp(1.2, 1.8);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: aspectRatio,
          children: [
            SummaryStatCard(
              label: l10n.totalReceivable,
              value: CurrencyFormatter.format(ref.watch(totalReceivableProvider), currency),
              icon: LucideIcons.arrowDownCircle,
              color: Colors.green,
              onTap: () => context.go('/ledger'), // Defaults to Customers tab
            ),
            SummaryStatCard(
              label: l10n.totalPayable,
              value: CurrencyFormatter.format(ref.watch(totalPayableProvider), currency),
              icon: LucideIcons.arrowUpCircle,
              color: Colors.red,
              onTap: () => context.go('/ledger'), // Ideally switch to Suppliers tab
            ),
            SummaryStatCard(
              label: l10n.monthlyIncome,
              value: CurrencyFormatter.format(ref.watch(monthlyIncomeProvider), currency),
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
              value: CurrencyFormatter.format(ref.watch(monthlyExpenseProvider), currency),
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
      },
    );
  }
}

