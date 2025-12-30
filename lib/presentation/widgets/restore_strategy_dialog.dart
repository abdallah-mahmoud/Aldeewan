import 'package:aldeewan_mobile/data/services/backup_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RestoreStrategyDialog extends StatelessWidget {
  const RestoreStrategyDialog({super.key});

  static Future<RestoreStrategy?> show(BuildContext context) {
    return showDialog<RestoreStrategy>(
      context: context,
      builder: (context) => const RestoreStrategyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        l10n.restoreStrategyTitle,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.restoreStrategyDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 24.h),
          _buildOption(
            context,
            icon: LucideIcons.merge,
            color: theme.colorScheme.primary,
            title: l10n.restoreMerge,
            description: l10n.restoreMergeDesc,
            onTap: () => Navigator.pop(context, RestoreStrategy.merge),
          ),
          SizedBox(height: 12.h),
          _buildOption(
            context,
            icon: LucideIcons.trash2,
            color: theme.colorScheme.error,
            title: l10n.restoreReplace,
            description: l10n.restoreReplaceDesc,
            isDestructive: true,
            onTap: () {
              // Confirm destructive action
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.restoreReplace),
                  content: Text(l10n.restoreReplaceWarning),
                  actions: [
                    TextButton(
                      child: Text(l10n.cancel),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      child: Text(l10n.delete),
                      onPressed: () {
                        Navigator.pop(ctx); // Close confirm
                        Navigator.pop(context, RestoreStrategy.replace); // Close strategy
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDestructive ? color.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDestructive ? color.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
