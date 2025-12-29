import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';

/// Provider that returns the count of unread notifications
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationHistoryProvider);
  return notifications.where((n) => !n.isRead).length;
});
