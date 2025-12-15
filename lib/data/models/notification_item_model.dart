import 'package:realm/realm.dart';

part 'notification_item_model.realm.dart';

@RealmModel()
class _NotificationItemModel {
  @PrimaryKey()
  late String id;

  late String title;
  late String body;
  late DateTime date;
  late bool isRead;
  late String type; // 'info', 'warning', 'success'
}
