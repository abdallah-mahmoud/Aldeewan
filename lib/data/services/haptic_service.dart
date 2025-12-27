import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Riverpod provider that exposes an instance of [HapticService].
///
/// This allows other parts of the application to easily access and use the service
/// for providing haptic feedback.
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

/// A service class responsible for providing haptic (vibration) feedback.
///
/// This service wraps Flutter's `HapticFeedback` functionality and allows for
/// enabling or disabling haptic feedback globally within the application.
class HapticService {
  /// A private flag indicating whether haptic feedback is currently enabled.
  bool _isEnabled = true;

  /// Sets the enabled state of haptic feedback.
  ///
  /// - Parameters:
  ///   - `enabled`: A boolean value where `true` enables haptic feedback
  ///     and `false` disables it.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Triggers a light haptic impact feedback.
  ///
  /// This method will only trigger feedback if haptics are currently enabled.
  /// - Returns: A `Future<void>` that completes when the haptic feedback is triggered.
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Triggers a medium haptic impact feedback.
  ///
  /// This method will only trigger feedback if haptics are currently enabled.
  /// - Returns: A `Future<void>` that completes when the haptic feedback is triggered.
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Triggers a heavy haptic impact feedback.
  ///
  /// This method will only trigger feedback if haptics are currently enabled.
  /// - Returns: A `Future<void>` that completes when the haptic feedback is triggered.
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Triggers a selection click haptic feedback, typically used for selection changes.
  ///
  /// This method will only trigger feedback if haptics are currently enabled.
  /// - Returns: A `Future<void>` that completes when the haptic feedback is triggered.
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Triggers a generic vibration haptic feedback.
  ///
  /// This method will only trigger feedback if haptics are currently enabled.
  /// - Returns: A `Future<void>` that completes when the haptic feedback is triggered.
  Future<void> vibrate() async {
    if (!_isEnabled) return;
    await HapticFeedback.vibrate();
  }
}
