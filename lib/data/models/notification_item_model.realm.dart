// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class NotificationItemModel extends _NotificationItemModel
    with RealmEntity, RealmObjectBase, RealmObject {
  NotificationItemModel(
    String id,
    String title,
    String body,
    DateTime date,
    bool isRead,
    String type,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'body', body);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'isRead', isRead);
    RealmObjectBase.set(this, 'type', type);
  }

  NotificationItemModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get body => RealmObjectBase.get<String>(this, 'body') as String;
  @override
  set body(String value) => RealmObjectBase.set(this, 'body', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  bool get isRead => RealmObjectBase.get<bool>(this, 'isRead') as bool;
  @override
  set isRead(bool value) => RealmObjectBase.set(this, 'isRead', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  Stream<RealmObjectChanges<NotificationItemModel>> get changes =>
      RealmObjectBase.getChanges<NotificationItemModel>(this);

  @override
  Stream<RealmObjectChanges<NotificationItemModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<NotificationItemModel>(this, keyPaths);

  @override
  NotificationItemModel freeze() =>
      RealmObjectBase.freezeObject<NotificationItemModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'body': body.toEJson(),
      'date': date.toEJson(),
      'isRead': isRead.toEJson(),
      'type': type.toEJson(),
    };
  }

  static EJsonValue _toEJson(NotificationItemModel value) => value.toEJson();
  static NotificationItemModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'body': EJsonValue body,
        'date': EJsonValue date,
        'isRead': EJsonValue isRead,
        'type': EJsonValue type,
      } =>
        NotificationItemModel(
          fromEJson(id),
          fromEJson(title),
          fromEJson(body),
          fromEJson(date),
          fromEJson(isRead),
          fromEJson(type),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NotificationItemModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      NotificationItemModel,
      'NotificationItemModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('title', RealmPropertyType.string),
        SchemaProperty('body', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('isRead', RealmPropertyType.bool),
        SchemaProperty('type', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
