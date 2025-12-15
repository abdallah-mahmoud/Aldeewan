import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';

class NotificationHistoryNotifier extends StateNotifier<List<NotificationItemModel>> {
  final Realm? _realm;

  NotificationHistoryNotifier(this._realm) : super([]) {
    _loadNotifications();
  }

  void _loadNotifications() {
    if (_realm == null) return;
    final notifications = _realm.all<NotificationItemModel>().toList();
    // Sort by date descending
    notifications.sort((a, b) => b.date.compareTo(a.date));
    state = notifications;
  }

  void addNotification({
    required String title,
    required String body,
    String type = 'info',
  }) {
    if (_realm == null) return;
    
    final notification = NotificationItemModel(
      const Uuid().v4(),
      title,
      body,
      DateTime.now(),
      false, // isRead
      type,
    );

    _realm.write(() {
      _realm.add(notification);
    });
    _loadNotifications();
  }

  void markAsRead(String id) {
    if (_realm == null) return;
    final notification = _realm.find<NotificationItemModel>(id);
    if (notification != null) {
      _realm.write(() {
        notification.isRead = true;
      });
      _loadNotifications();
    }
  }

  void markAllAsRead() {
    if (_realm == null) return;
    final unread = _realm.all<NotificationItemModel>().query('isRead == false');
    _realm.write(() {
      for (final n in unread) {
        n.isRead = true;
      }
    });
    _loadNotifications();
  }

  void deleteNotification(String id) {
    if (_realm == null) return;
    final notification = _realm.find<NotificationItemModel>(id);
    if (notification != null) {
      _realm.write(() {
        _realm.delete(notification);
      });
      _loadNotifications();
    }
  }

  void clearAll() {
    if (_realm == null) return;
    _realm.write(() {
      _realm.deleteAll<NotificationItemModel>();
    });
    _loadNotifications();
  }
}

final notificationHistoryProvider = StateNotifierProvider<NotificationHistoryNotifier, List<NotificationItemModel>>((ref) {
  final realmAsync = ref.watch(realmProvider);
  return realmAsync.when(
    data: (realm) => NotificationHistoryNotifier(realm),
    loading: () => NotificationHistoryNotifier(null),
    error: (e, s) => NotificationHistoryNotifier(null),
  );
});
