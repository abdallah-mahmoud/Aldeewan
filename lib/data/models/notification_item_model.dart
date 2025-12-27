import 'package:realm/realm.dart';

part 'notification_item_model.realm.dart';

/// Represents a notification item stored in the Realm database.
///
/// This class defines the schema for a notification, including its title, body,
/// date, read status, and type.
@RealmModel()
class _NotificationItemModel {
  /// The unique identifier for the notification item.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late String id;

  /// The title of the notification.
  late String title;
  /// The main content or message of the notification.
  late String body;
  /// The date and time when the notification was created.
  late DateTime date;
  /// A boolean flag indicating whether the notification has been read by the user.
  late bool isRead;
  /// The type of the notification (e.g., 'info', 'warning', 'success'),
  /// which can be used for styling or categorization.
  late String type;
}
