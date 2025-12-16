// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';

/// Global keys for showcase targets
class ShowcaseKeys {
  static final GlobalKey dashboardCards = GlobalKey();
  static final GlobalKey fabButton = GlobalKey();
  static final GlobalKey ledgerList = GlobalKey();
  static final GlobalKey cashbookFilter = GlobalKey();
  static final GlobalKey searchBar = GlobalKey();
  static final GlobalKey helpButton = GlobalKey();

  /// Get all keys for the full tour
  static List<GlobalKey> get allKeys => [
    dashboardCards,
  ];
}

/// Wrapper widget to provide Showcase context to the app
class GlobalShowcaseWrapper extends ConsumerWidget {
  final Widget child;

  const GlobalShowcaseWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowCaseWidget(
      builder: (context) => child,
      onFinish: () {
        // When tour completes
        ref.read(onboardingProvider.notifier).completeTour();
      },
    );
  }
}

/// Mixin to add showcase tour functionality to screens
mixin ShowcaseTourMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTourIfNeeded();
    });
  }

  /// Start the tour if not completed
  void startTourIfNeeded() {
    // Check if widget is mounted and context is valid
    if (!mounted) return;

    final onboarding = ref.read(onboardingProvider);
    if (!onboarding.tourCompleted) {
      // Small delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.allKeys);
          } catch (e) {
            debugPrint('Showcase error: $e');
          }
        }
      });
    }
  }

  /// Restart the tour
  void restartTour() {
    ref.read(onboardingProvider.notifier).restartTour();
    if (mounted) {
       try {
         ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.allKeys);
       } catch (e) {
         debugPrint('Showcase restart error: $e');
       }
    }
  }
}

/// Helper widget to wrap showcase targets
class ShowcaseTarget extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;

  const ShowcaseTarget({
    super.key,
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      descTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      tooltipBackgroundColor: theme.cardColor,
      targetPadding: const EdgeInsets.all(8),
      showArrow: true,
      child: child,
    );
  }
}
