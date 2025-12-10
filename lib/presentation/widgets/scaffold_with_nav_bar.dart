import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/widgets/bottom_nav_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
      bottomNavigationBar: BottomNavBar(
        currentPath: GoRouterState.of(context).uri.toString(),
      ),
    );
  }
}
