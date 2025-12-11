import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyBlur extends StatelessWidget {
  final Widget child;
  final bool isLocked;

  const PrivacyBlur({
    super.key,
    required this.child,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLocked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
