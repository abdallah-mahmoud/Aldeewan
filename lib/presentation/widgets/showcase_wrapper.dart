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
    fabButton,
  ];
}

/// Mixin to add showcase tour functionality to screens
mixin ShowcaseTourMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _showcaseRegistered = false;

  /// Register the showcase tour
  void registerShowcase() {
    if (_showcaseRegistered) return;
    _showcaseRegistered = true;

    ShowcaseView.register(
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
      onComplete: (index, key) {
        // When tour completes on last key, mark as done
        if (key == ShowcaseKeys.fabButton) {
          ref.read(onboardingProvider.notifier).completeTour();
        }
      },
    );
  }

  /// Start the tour if not completed
  void startTourIfNeeded() {
    final onboarding = ref.read(onboardingProvider);
    if (!onboarding.tourCompleted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ShowcaseView.get().startShowCase(ShowcaseKeys.allKeys);
        }
      });
    }
  }

  /// Restart the tour
  void restartTour() {
    ref.read(onboardingProvider.notifier).restartTour();
    ShowcaseView.get().startShowCase(ShowcaseKeys.allKeys);
  }

  /// Unregister when done
  void unregisterShowcase() {
    if (_showcaseRegistered) {
      ShowcaseView.get().unregister();
      _showcaseRegistered = false;
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
