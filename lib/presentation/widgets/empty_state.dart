import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final String? lottieAsset;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.lottieAsset,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
              )
            else
              Icon(
                icon ?? LucideIcons.inbox,
                size: 64.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            SizedBox(height: 16.h),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
