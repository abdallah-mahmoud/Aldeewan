import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/hero_balance_card.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final range = ref.watch(summaryRangeProvider);

    // Compute hero amount based on selected range
    final double heroAmount;
    final String heroSubtitle;

    if (range == SummaryRange.all) {
      // All-time cumulative cash in hand (persistent, never resets)
      heroAmount = ref.watch(totalCashBalanceProvider);
      heroSubtitle = l10n.allTime;
    } else {
      // This month's net cash flow
      final monthlyIncome = ref.watch(monthlyIncomeProvider);
      final monthlyExpense = ref.watch(monthlyExpenseProvider);
      heroAmount = monthlyIncome - monthlyExpense;
      heroSubtitle = heroAmount >= 0 ? l10n.profitThisMonth : l10n.lossThisMonth;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Range filter chips
        Row(
          children: [
            ChoiceChip(
              label: Text(l10n.all),
              selected: range == SummaryRange.all,
              onSelected: (_) {
                ref.read(summaryRangeProvider.notifier).state = SummaryRange.all;
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l10n.thisMonth),
              selected: range == SummaryRange.month,
              onSelected: (_) {
                ref.read(summaryRangeProvider.notifier).state = SummaryRange.month;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hero net balance card
        HeroBalanceCard(
          title: l10n.netPosition,
          subtitle: heroSubtitle,
          rawAmount: heroAmount,
          currencyCode: currency,
          isPositive: heroAmount >= 0,
        ),
      ],
    );
  }
}

