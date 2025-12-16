import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

/// Tip IDs for tracking dismissal
class TipIds {
  static const String quickActions = 'tip_quick_actions';
  static const String filterTransactions = 'tip_filter_transactions';
  static const String personBalance = 'tip_person_balance';
  static const String budgetAlert = 'tip_budget_alert';
  static const String goalProgress = 'tip_goal_progress';
  static const String exportReport = 'tip_export_report';
}

/// A dismissable tip card that shows helpful hints to users
class TipCard extends ConsumerWidget {
  final String tipId;
  final String message;
  final IconData icon;
  final Color? color;

  const TipCard({
    super.key,
    required this.tipId,
    required this.message,
    this.icon = LucideIcons.lightbulb,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Don't show if already dismissed
    if (onboarding.dismissedTips.contains(tipId)) {
      return const SizedBox.shrink();
    }

    final tipColor = color ?? AppColors.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: tipColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ref.read(onboardingProvider.notifier).dismissTip(tipId);
                  },
                  child: Text(
                    l10n.tipGotIt,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tipColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.x,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              ref.read(onboardingProvider.notifier).dismissTip(tipId);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Pre-built tip cards for common locations
class QuickActionsTip extends StatelessWidget {
  const QuickActionsTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.quickActions,
      message: l10n.tipQuickActions,
      icon: LucideIcons.zap,
    );
  }
}

class FilterTransactionsTip extends StatelessWidget {
  const FilterTransactionsTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.filterTransactions,
      message: l10n.tipFilterTransactions,
      icon: LucideIcons.filter,
    );
  }
}

class PersonBalanceTip extends StatelessWidget {
  const PersonBalanceTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.personBalance,
      message: l10n.tipPersonBalance,
      icon: LucideIcons.userCheck,
    );
  }
}

class BudgetAlertTip extends StatelessWidget {
  const BudgetAlertTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.budgetAlert,
      message: l10n.tipBudgetAlert,
      icon: LucideIcons.bellRing,
      color: AppColors.warning,
    );
  }
}

class GoalProgressTip extends StatelessWidget {
  const GoalProgressTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.goalProgress,
      message: l10n.tipGoalProgress,
      icon: LucideIcons.target,
      color: AppColors.success,
    );
  }
}

class ExportReportTip extends StatelessWidget {
  const ExportReportTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TipCard(
      tipId: TipIds.exportReport,
      message: l10n.tipExportReport,
      icon: LucideIcons.fileDown,
    );
  }
}
