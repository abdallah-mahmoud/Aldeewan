import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/screens/home_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/ledger_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/cashbook_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/budget_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/settings_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/person_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/about_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/splash_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/link_account_screen.dart';
import 'package:aldeewan_mobile/presentation/widgets/scaffold_with_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/link-account',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LinkAccountScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/ledger',
            builder: (context, state) => const LedgerScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey, // Open details above the shell (hides nav bar) - usually better for details
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PersonDetailsScreen(personId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/cashbook',
            builder: (context, state) => const CashbookScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'about',
                parentNavigatorKey: rootNavigatorKey, // Open about above the shell
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
