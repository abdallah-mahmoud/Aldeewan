// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SavingsGoalModel extends _SavingsGoalModel
    with RealmEntity, RealmObjectBase, RealmObject {
  SavingsGoalModel(
    ObjectId id,
    String name,
    double targetAmount,
    double currentSaved, {
    DateTime? deadline,
    String? icon,
    String? colorHex,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'targetAmount', targetAmount);
    RealmObjectBase.set(this, 'currentSaved', currentSaved);
    RealmObjectBase.set(this, 'deadline', deadline);
    RealmObjectBase.set(this, 'icon', icon);
    RealmObjectBase.set(this, 'colorHex', colorHex);
  }

  SavingsGoalModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  double get targetAmount =>
      RealmObjectBase.get<double>(this, 'targetAmount') as double;
  @override
  set targetAmount(double value) =>
      RealmObjectBase.set(this, 'targetAmount', value);

  @override
  double get currentSaved =>
      RealmObjectBase.get<double>(this, 'currentSaved') as double;
  @override
  set currentSaved(double value) =>
      RealmObjectBase.set(this, 'currentSaved', value);

  @override
  DateTime? get deadline =>
      RealmObjectBase.get<DateTime>(this, 'deadline') as DateTime?;
  @override
  set deadline(DateTime? value) => RealmObjectBase.set(this, 'deadline', value);

  @override
  String? get icon => RealmObjectBase.get<String>(this, 'icon') as String?;
  @override
  set icon(String? value) => RealmObjectBase.set(this, 'icon', value);

  @override
  String? get colorHex =>
      RealmObjectBase.get<String>(this, 'colorHex') as String?;
  @override
  set colorHex(String? value) => RealmObjectBase.set(this, 'colorHex', value);

  @override
  Stream<RealmObjectChanges<SavingsGoalModel>> get changes =>
      RealmObjectBase.getChanges<SavingsGoalModel>(this);

  @override
  Stream<RealmObjectChanges<SavingsGoalModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<SavingsGoalModel>(this, keyPaths);

  @override
  SavingsGoalModel freeze() =>
      RealmObjectBase.freezeObject<SavingsGoalModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'targetAmount': targetAmount.toEJson(),
      'currentSaved': currentSaved.toEJson(),
      'deadline': deadline.toEJson(),
      'icon': icon.toEJson(),
      'colorHex': colorHex.toEJson(),
    };
  }

  static EJsonValue _toEJson(SavingsGoalModel value) => value.toEJson();
  static SavingsGoalModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'targetAmount': EJsonValue targetAmount,
        'currentSaved': EJsonValue currentSaved,
      } =>
        SavingsGoalModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(targetAmount),
          fromEJson(currentSaved),
          deadline: fromEJson(ejson['deadline']),
          icon: fromEJson(ejson['icon']),
          colorHex: fromEJson(ejson['colorHex']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SavingsGoalModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, SavingsGoalModel, 'SavingsGoalModel', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('targetAmount', RealmPropertyType.double),
      SchemaProperty('currentSaved', RealmPropertyType.double),
      SchemaProperty('deadline', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('icon', RealmPropertyType.string, optional: true),
      SchemaProperty('colorHex', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
