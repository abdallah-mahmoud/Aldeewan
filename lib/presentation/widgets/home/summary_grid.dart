import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/true_income_expense_provider.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';

enum SummarySection { debts, monthly, all }

class SummaryGrid extends ConsumerWidget {
  final SummarySection section;
  const SummaryGrid({super.key, this.section = SummarySection.all});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ━━━ Debts Section ━━━
        if (section == SummarySection.all || section == SummarySection.debts) ...[
          _SectionHeader(title: l10n.debtsSection, icon: LucideIcons.users),
          SizedBox(height: 8.h),
          _CardRow(
            children: [
              _buildCard(
                context: context,
                label: l10n.totalReceivable,
                value: CurrencyFormatter.format(ref.watch(totalReceivableProvider), currency),
                icon: LucideIcons.arrowDownCircle,
                color: AppColors.success,
                style: _CardStyle.prominent,
                onTap: () => context.go('/ledger?tab=customers&filter=owes'),
              ),
              _buildCard(
                context: context,
                label: l10n.totalPayable,
                value: CurrencyFormatter.format(ref.watch(totalPayableProvider), currency),
                icon: LucideIcons.arrowUpCircle,
                color: AppColors.error,
                style: _CardStyle.prominent,
                onTap: () => context.go('/ledger?tab=suppliers&filter=owes'),
              ),
            ],
          ),
          if (section == SummarySection.all) SizedBox(height: 16.h),
        ],

        // ━━━ Monthly Section ━━━
        if (section == SummarySection.all || section == SummarySection.monthly) ...[
          _SectionHeader(title: l10n.monthlySection, icon: LucideIcons.calendar),
          SizedBox(height: 8.h),
          // Cash Flow Row (Money In/Out)
          _CardRow(
            children: [
              _buildCard(
                context: context,
                label: l10n.moneyIn,
                value: CurrencyFormatter.format(ref.watch(moneyInProvider), currency),
                icon: LucideIcons.arrowDownCircle,
                color: AppColors.success,
                style: _CardStyle.subtle,
                onTap: () {
                  ref.read(cashFilterProvider.notifier).state = CashFilter.income;
                  ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
                  context.go('/cashbook');
                },
              ),
              _buildCard(
                context: context,
                label: l10n.moneyOut,
                value: CurrencyFormatter.format(ref.watch(moneyOutProvider), currency),
                icon: LucideIcons.arrowUpCircle,
                color: AppColors.error,
                style: _CardStyle.subtle,
                onTap: () {
                  ref.read(cashFilterProvider.notifier).state = CashFilter.expense;
                  ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
                  context.go('/cashbook');
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Profit Row (True Income/Expense)
          _CardRow(
            children: [
              _buildCard(
                context: context,
                label: l10n.trueIncome,
                value: CurrencyFormatter.format(ref.watch(trueIncomeProvider), currency),
                icon: LucideIcons.trendingUp,
                color: AppColors.success,
                style: _CardStyle.accent,
                onTap: () {
                  ref.read(cashFilterProvider.notifier).state = CashFilter.income;
                  ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
                  context.go('/cashbook');
                },
              ),
              _buildCard(
                context: context,
                label: l10n.trueExpense,
                value: CurrencyFormatter.format(ref.watch(trueExpenseProvider), currency),
                icon: LucideIcons.trendingDown,
                color: AppColors.error,
                style: _CardStyle.accent,
                onTap: () {
                  ref.read(cashFilterProvider.notifier).state = CashFilter.expense;
                  ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.thisMonth;
                  context.go('/cashbook');
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required _CardStyle style,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    BoxDecoration decoration;
    TextStyle? valueStyle;
    double iconSize;
    
    switch (style) {
      case _CardStyle.prominent:
        decoration = BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        );
        valueStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        );
        iconSize = 22.sp;
        break;
      case _CardStyle.subtle:
        decoration = BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        );
        valueStyle = theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        );
        iconSize = 18.sp;
        break;
      case _CardStyle.accent:
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        );
        valueStyle = theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        );
        iconSize = 16.sp;
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(style == _CardStyle.prominent ? 16.r : 12.r),
        child: Container(
          padding: EdgeInsets.all(style == _CardStyle.prominent ? 14.w : 10.w),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: iconSize),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: valueStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CardStyle { prominent, subtle, accent }

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.colorScheme.primary),
        SizedBox(width: 6.w),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Divider(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _CardRow extends StatelessWidget {
  final List<Widget> children;

  const _CardRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(width: 10.w),
        ],
      ],
    );
  }
}
