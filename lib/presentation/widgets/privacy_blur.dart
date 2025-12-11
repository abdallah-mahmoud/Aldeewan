import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';

import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class PrivacyBlur extends ConsumerWidget {
  final Widget child;
  final bool isLocked;
  final VoidCallback? onUnlock;

  const PrivacyBlur({
    super.key,
    required this.child,
    required this.isLocked,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAppLockEnabled = ref.watch(securityProvider);
    final shouldBlur = isLocked && isAppLockEnabled;
    final l10n = AppLocalizations.of(context); // Might be null if context not ready, but usually fine here

    return Stack(
      children: [
        child,
        if (shouldBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4), // Darker for better contrast
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 24),
                    const Icon(Icons.lock, color: Colors.white, size: 32),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.appLocked ?? 'App Locked',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    if (onUnlock != null)
                      ElevatedButton.icon(
                        onPressed: onUnlock,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n?.unlock ?? 'Unlock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
