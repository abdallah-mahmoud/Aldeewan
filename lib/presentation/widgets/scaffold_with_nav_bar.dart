import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/widgets/bottom_nav_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isOnHome = currentPath == '/home' || currentPath.startsWith('/home?');
    
    return PopScope(
      canPop: isOnHome, // Only allow pop (exit) if on home screen
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // If pop was blocked (not on home), navigate to home instead
          context.go('/home');
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        bottomNavigationBar: BottomNavBar(
          currentPath: currentPath,
        ),
      ),
    );
  }
}
