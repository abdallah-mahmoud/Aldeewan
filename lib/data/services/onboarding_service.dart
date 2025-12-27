import 'package:shared_preferences/shared_preferences.dart';

/// A service class for managing the onboarding state of the application.
///
/// This includes tracking whether the initial tour has been completed, managing
/// dismissed tips, and tracking if the initial balance prompt has been shown.
/// It uses `shared_preferences` for persisting these states.
class OnboardingService {
  /// Key used to store the completion status of the initial tour.
  static const String _tourCompletedKey = 'tour_completed';
  /// Key used to store a list of IDs for dismissed tips.
  static const String _dismissedTipsKey = 'dismissed_tips';

  /// The `SharedPreferences` instance used for persistent storage.
  final SharedPreferences _prefs;

  /// Constructs an [OnboardingService] with the provided `SharedPreferences` instance.
  OnboardingService(this._prefs);

  /// Returns `true` if the initial onboarding tour has been completed, `false` otherwise.
  bool get isTourCompleted => _prefs.getBool(_tourCompletedKey) ?? false;

  /// Marks the initial onboarding tour as completed in persistent storage.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> completeTour() async {
    await _prefs.setBool(_tourCompletedKey, true);
  }

  /// Resets the tour completion status, making the tour available again.
  /// This is typically used for a "Restart Tour" feature.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> resetTour() async {
    await _prefs.setBool(_tourCompletedKey, false);
  }

  /// Retrieves a list of IDs for all tips that have been dismissed by the user.
  /// - Returns: A `List<String>` containing the IDs of dismissed tips. Returns an empty list if none are dismissed.
  List<String> get dismissedTips {
    return _prefs.getStringList(_dismissedTipsKey) ?? [];
  }

  /// Checks if a specific tip has been dismissed.
  /// - Parameters:
  ///   - `tipId`: The unique identifier of the tip to check.
  /// - Returns: `true` if the tip has been dismissed, `false` otherwise.
  bool isTipDismissed(String tipId) {
    return dismissedTips.contains(tipId);
  }

  /// Marks a specific tip as dismissed, preventing it from being shown again.
  /// - Parameters:
  ///   - `tipId`: The unique identifier of the tip to dismiss.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> dismissTip(String tipId) async {
    final tips = dismissedTips;
    if (!tips.contains(tipId)) {
      tips.add(tipId);
      await _prefs.setStringList(_dismissedTipsKey, tips);
    }
  }

  /// Resets all dismissed tips, making them eligible to be shown again.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> resetAllTips() async {
    await _prefs.setStringList(_dismissedTipsKey, []);
  }

  /// Resets all onboarding-related states, including tour completion and dismissed tips.
  /// - Returns: A `Future<void>` that completes when both tour and tips are reset.
  Future<void> resetAll() async {
    await resetTour();
    await resetAllTips();
  }

  /// Key used to track whether the initial balance prompt has been shown.
  static const String _initialBalancePromptShownKey = 'initial_balance_prompt_shown';

  /// Returns `true` if the initial balance prompt has been shown, `false` otherwise.
  bool get isInitialBalancePromptShown => _prefs.getBool(_initialBalancePromptShownKey) ?? false;

  /// Marks the initial balance prompt as shown in persistent storage.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> markInitialBalancePromptShown() async {
    await _prefs.setBool(_initialBalancePromptShownKey, true);
  }
}
