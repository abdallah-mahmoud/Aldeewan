import 'package:flutter/material.dart';
import 'package:aldeewan_mobile/config/gradients.dart';
import 'package:aldeewan_mobile/presentation/widgets/common/rolling_balance.dart';

class HeroBalanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rawAmount;
  final String currencyCode;
  final bool isPositive;

  const HeroBalanceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rawAmount,
    required this.currencyCode,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isPositive
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.error.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: isPositive ? AppGradients.primaryCard : AppGradients.budgetDanger,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RollingBalance(
              balance: rawAmount,
              currencySymbol: currencyCode,
              style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
              showSign: false, // Or true if we want +/-
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
