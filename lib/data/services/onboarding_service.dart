import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting onboarding state (tour completion, dismissed tips)
class OnboardingService {
  static const String _tourCompletedKey = 'tour_completed';
  static const String _dismissedTipsKey = 'dismissed_tips';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Check if the tour has been completed
  bool get isTourCompleted => _prefs.getBool(_tourCompletedKey) ?? false;

  /// Mark the tour as completed
  Future<void> completeTour() async {
    await _prefs.setBool(_tourCompletedKey, true);
  }

  /// Reset tour (for "Restart Tour" feature)
  Future<void> resetTour() async {
    await _prefs.setBool(_tourCompletedKey, false);
  }

  /// Get list of dismissed tip IDs
  List<String> get dismissedTips {
    return _prefs.getStringList(_dismissedTipsKey) ?? [];
  }

  /// Check if a specific tip has been dismissed
  bool isTipDismissed(String tipId) {
    return dismissedTips.contains(tipId);
  }

  /// Dismiss a tip (won't show again)
  Future<void> dismissTip(String tipId) async {
    final tips = dismissedTips;
    if (!tips.contains(tipId)) {
      tips.add(tipId);
      await _prefs.setStringList(_dismissedTipsKey, tips);
    }
  }

  /// Reset all dismissed tips
  Future<void> resetAllTips() async {
    await _prefs.setStringList(_dismissedTipsKey, []);
  }

  /// Reset everything (tour + tips)
  Future<void> resetAll() async {
    await resetTour();
    await resetAllTips();
  }

  // Initial balance prompt tracking
  static const String _initialBalancePromptShownKey = 'initial_balance_prompt_shown';

  /// Check if initial balance prompt has been shown
  bool get isInitialBalancePromptShown => _prefs.getBool(_initialBalancePromptShownKey) ?? false;

  /// Mark initial balance prompt as shown
  Future<void> markInitialBalancePromptShown() async {
    await _prefs.setBool(_initialBalancePromptShownKey, true);
  }
}
