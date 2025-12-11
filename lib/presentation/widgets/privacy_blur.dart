import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';

class PrivacyBlur extends ConsumerWidget {
  final Widget child;
  final bool isLocked;

  const PrivacyBlur({
    super.key,
    required this.child,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAppLockEnabled = ref.watch(securityProvider);
    final shouldBlur = isLocked && isAppLockEnabled;

    return Stack(
      children: [
        child,
        if (shouldBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
