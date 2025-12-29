import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';
import 'package:aldeewan_mobile/utils/notification_service.dart';

/// Centralized service for triggering notifications
/// Handles both OS notifications and in-app history
class NotificationTriggerService {
  final NotificationHistoryNotifier _historyNotifier;
  final NotificationService _notificationService;

  NotificationTriggerService(this._historyNotifier)
      : _notificationService = NotificationService();

  /// Trigger when budget is exceeded
  Future<void> triggerBudgetExceeded({
    required String budgetName,
    required String exceededByAmount,
    required String titleText,
    required String bodyText,
  }) async {
    // Add to in-app history
    _historyNotifier.addNotification(
      title: titleText,
      body: bodyText,
      type: 'warning',
    );

    // Show OS notification
    await _notificationService.showTestNotification(
      title: titleText,
      body: bodyText,
    );
  }

  /// Trigger when savings goal is reached
  Future<void> triggerGoalReached({
    required String goalName,
    required String titleText,
    required String bodyText,
  }) async {
    // Add to in-app history
    _historyNotifier.addNotification(
      title: titleText,
      body: bodyText,
      type: 'success',
    );

    // Show OS notification
    await _notificationService.showTestNotification(
      title: titleText,
      body: bodyText,
    );
  }

  /// Trigger payment reminder
  Future<void> triggerPaymentReminder({
    required String personName,
    required String amount,
    required String titleText,
    required String bodyText,
  }) async {
    _historyNotifier.addNotification(
      title: titleText,
      body: bodyText,
      type: 'info',
    );

    await _notificationService.showTestNotification(
      title: titleText,
      body: bodyText,
    );
  }

  /// Trigger weekly summary
  Future<void> triggerWeeklySummary({
    required String titleText,
    required String bodyText,
  }) async {
    _historyNotifier.addNotification(
      title: titleText,
      body: bodyText,
      type: 'info',
    );

    await _notificationService.showTestNotification(
      title: titleText,
      body: bodyText,
    );
  }

  /// Generic notification trigger
  Future<void> triggerNotification({
    required String title,
    required String body,
    String type = 'info',
    bool showOsNotification = true,
  }) async {
    _historyNotifier.addNotification(
      title: title,
      body: body,
      type: type,
    );

    if (showOsNotification) {
      await _notificationService.showTestNotification(
        title: title,
        body: body,
      );
    }
  }
}

/// Provider for NotificationTriggerService
final notificationTriggerServiceProvider = Provider<NotificationTriggerService?>((ref) {
  final historyNotifier = ref.watch(notificationHistoryProvider.notifier);
  return NotificationTriggerService(historyNotifier);
});
