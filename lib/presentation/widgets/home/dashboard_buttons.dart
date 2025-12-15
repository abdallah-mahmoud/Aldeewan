import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/elegant_dashboard_button.dart';

class DashboardButtons extends StatelessWidget {
  const DashboardButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        ElegantDashboardButton(
          title: l10n.budgets,
          icon: LucideIcons.pieChart,
          color: Colors.teal,
          onTap: () => context.push('/budgets'),
          subtitle: l10n.budgetSummary,
        ),
        const SizedBox(width: 16),
        ElegantDashboardButton(
          title: l10n.goals,
          icon: LucideIcons.trophy,
          color: Colors.amber,
          onTap: () => context.push('/goals'),
          subtitle: l10n.currentSaved,
        ),
      ],
    );
  }
}
