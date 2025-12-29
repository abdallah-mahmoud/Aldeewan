import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:showcaseview/showcaseview.dart';

/// Enum for guided tour screens in order
enum TourScreen {
  home,
  ledger,
  cashbook,
  settings,
}

/// State class for the guided tour
class GuidedTourState {
  final bool isActive;
  final TourScreen currentScreen;
  final bool screenTourStarted;
  final bool dialogShown;  // Prevent dialog from re-appearing

  const GuidedTourState({
    this.isActive = false,
    this.currentScreen = TourScreen.home,
    this.screenTourStarted = false,
    this.dialogShown = false,
  });

  GuidedTourState copyWith({
    bool? isActive,
    TourScreen? currentScreen,
    bool? screenTourStarted,
    bool? dialogShown,
  }) {
    return GuidedTourState(
      isActive: isActive ?? this.isActive,
      currentScreen: currentScreen ?? this.currentScreen,
      screenTourStarted: screenTourStarted ?? this.screenTourStarted,
      dialogShown: dialogShown ?? this.dialogShown,
    );
  }
}

/// Notifier for managing the guided tour across screens
class GuidedTourNotifier extends StateNotifier<GuidedTourState> {
  final Ref _ref;

  GuidedTourNotifier(this._ref) : super(const GuidedTourState());

  /// Screen routes in tour order
  static const Map<TourScreen, String> _screenRoutes = {
    TourScreen.home: '/home',
    TourScreen.ledger: '/ledger',
    TourScreen.cashbook: '/cashbook',
    TourScreen.settings: '/settings',
  };

  /// Get showcase keys for a screen
  List<GlobalKey> _getKeysForScreen(TourScreen screen) {
    switch (screen) {
      case TourScreen.home:
        return ShowcaseKeys.homeKeys;
      case TourScreen.ledger:
        return ShowcaseKeys.ledgerKeys;
      case TourScreen.cashbook:
        return ShowcaseKeys.cashbookKeys;
      case TourScreen.settings:
        return ShowcaseKeys.settingsKeys;
    }
  }

  /// Mark that dialog has been shown (prevent re-appearance)
  void markDialogShown() {
    state = state.copyWith(dialogShown: true);
  }

  /// Check if dialog should be shown
  bool get shouldShowDialog => !state.dialogShown;

  /// Start the guided tour from the beginning
  /// Called when user taps "Start Tour" in the dialog
  void startTour(BuildContext context) {
    // Mark tour as active with home as current screen
    // Mark screenTourStarted as TRUE immediately to prevent race conditions
    state = const GuidedTourState(
      isActive: true,
      currentScreen: TourScreen.home,
      screenTourStarted: true,  // Already started - we'll trigger showcase now
      dialogShown: true,
    );
    
    // DON'T navigate - we're already on home screen
    // Instead, trigger the showcase directly after a small delay
    _triggerShowcaseForCurrentScreen(context);
  }

  /// Internal method to trigger showcase for current screen
  void _triggerShowcaseForCurrentScreen(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (context.mounted && state.isActive) {
        try {
          final keys = _getKeysForScreen(state.currentScreen);
          // ignore: deprecated_member_use
          ShowCaseWidget.of(context).startShowCase(keys);
        } catch (e) {
          debugPrint('Tour showcase error: $e');
        }
      }
    });
  }

  /// Check if tour can start for a specific screen (NO SIDE EFFECTS)
  /// Use this to check, then call markScreenTourStarted() if proceeding
  bool canStartTourForScreen(TourScreen screen) {
    if (!state.isActive) return false;
    if (state.currentScreen != screen) return false;
    if (state.screenTourStarted) return false;
    return true;
  }

  /// Mark that a screen's tour has started (SEPARATE from check)
  void markScreenTourStarted() {
    state = state.copyWith(screenTourStarted: true);
  }

  /// Called when a screen's tour finishes - navigate to next screen
  void onScreenTourComplete(BuildContext context) {
    if (!state.isActive) return;
    
    final currentIndex = TourScreen.values.indexOf(state.currentScreen);
    
    // Check if there are more screens
    if (currentIndex < TourScreen.values.length - 1) {
      final nextScreen = TourScreen.values[currentIndex + 1];
      final nextRoute = _screenRoutes[nextScreen]!;
      
      // Update state for next screen - NOT started yet
      state = GuidedTourState(
        isActive: true,
        currentScreen: nextScreen,
        screenTourStarted: false,
        dialogShown: true,
      );
      
      // Navigate to next screen
      if (context.mounted) {
        context.go(nextRoute);
      }
    } else {
      // Tour complete - all screens done
      _completeTour(context);
    }
  }

  /// Complete the tour
  Future<void> _completeTour(BuildContext context) async {
    state = const GuidedTourState(isActive: false, dialogShown: true);
    await _ref.read(onboardingProvider.notifier).completeTour();
    
    // Navigate back to home
    if (context.mounted) {
      context.go('/home');
    }
  }

  /// Skip the tour
  void skipTour() {
    state = const GuidedTourState(isActive: false, dialogShown: true);
    _ref.read(onboardingProvider.notifier).completeTour();
  }

  /// Check if tour is currently active
  bool get isActive => state.isActive;
  
  /// Get current tour screen
  TourScreen get currentScreen => state.currentScreen;
  
  /// Reset dialog shown state (for testing/restart)
  void resetDialogState() {
    state = state.copyWith(dialogShown: false);
  }
}

/// Provider for the guided tour
final guidedTourProvider =
    StateNotifierProvider<GuidedTourNotifier, GuidedTourState>((ref) {
  return GuidedTourNotifier(ref);
});
