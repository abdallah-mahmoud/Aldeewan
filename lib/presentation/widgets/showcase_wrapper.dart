// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';

/// Global keys for showcase targets
class ShowcaseKeys {
  // Home Screen (Steps 1-2)
  static final GlobalKey dashboardCards = GlobalKey();
  static final GlobalKey quickActions = GlobalKey();
  
  // Ledger Screen (Step 3)
  static final GlobalKey ledgerList = GlobalKey();
  
  // Cashbook Screen (Steps 4-5)
  static final GlobalKey cashbookFilter = GlobalKey();
  static final GlobalKey searchBar = GlobalKey();
  
  // Settings Screen (Step 6)
  static final GlobalKey helpButton = GlobalKey();

  /// Keys for Home Screen tour
  static List<GlobalKey> get homeKeys => [
    dashboardCards,
    quickActions,
  ];
  
  /// Keys for Ledger Screen tour
  static List<GlobalKey> get ledgerKeys => [
    ledgerList,
  ];
  
  /// Keys for Cashbook Screen tour
  static List<GlobalKey> get cashbookKeys => [
    cashbookFilter,
    searchBar,
  ];
  
  /// Keys for Settings Screen tour
  static List<GlobalKey> get settingsKeys => [
    helpButton,
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
        // Mark current screen's tour as complete
        // The full tour completion is handled by individual screens
      },
    );
  }
}

/// Mixin to add showcase tour functionality to screens
mixin ShowcaseTourMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Override this in each screen to provide screen-specific keys
  List<GlobalKey> get showcaseKeys => [];
  
  /// Override this to provide a unique ID for this screen's tour
  String get screenTourId => 'default';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTourIfNeeded();
    });
  }

  /// Start the tour if not completed for this screen
  void startTourIfNeeded() {
    if (!mounted) return;
    if (showcaseKeys.isEmpty) return;

    final onboarding = ref.read(onboardingProvider);
    final tourKey = 'tour_$screenTourId';
    
    // Check if this specific screen's tour was shown
    if (!onboarding.dismissedTips.contains(tourKey)) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          try {
            ShowCaseWidget.of(context).startShowCase(showcaseKeys);
            // Mark this screen's tour as shown
            ref.read(onboardingProvider.notifier).dismissTip(tourKey);
          } catch (e) {
            debugPrint('Showcase error: $e');
          }
        }
      });
    }
  }

  /// Restart the tour for this screen
  void restartScreenTour() {
    if (showcaseKeys.isEmpty) return;
    if (mounted) {
      try {
        ShowCaseWidget.of(context).startShowCase(showcaseKeys);
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
      enableAutoScroll: true,
      child: child,
    );
  }
}
