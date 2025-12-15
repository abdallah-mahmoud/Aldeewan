// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class BudgetModel extends _BudgetModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  BudgetModel(
    ObjectId id,
    String category,
    double amountLimit,
    double currentSpent,
    DateTime startDate,
    DateTime endDate, {
    bool isRecurring = true,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<BudgetModel>({
        'isRecurring': true,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'amountLimit', amountLimit);
    RealmObjectBase.set(this, 'currentSpent', currentSpent);
    RealmObjectBase.set(this, 'startDate', startDate);
    RealmObjectBase.set(this, 'endDate', endDate);
    RealmObjectBase.set(this, 'isRecurring', isRecurring);
  }

  BudgetModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  double get amountLimit =>
      RealmObjectBase.get<double>(this, 'amountLimit') as double;
  @override
  set amountLimit(double value) =>
      RealmObjectBase.set(this, 'amountLimit', value);

  @override
  double get currentSpent =>
      RealmObjectBase.get<double>(this, 'currentSpent') as double;
  @override
  set currentSpent(double value) =>
      RealmObjectBase.set(this, 'currentSpent', value);

  @override
  DateTime get startDate =>
      RealmObjectBase.get<DateTime>(this, 'startDate') as DateTime;
  @override
  set startDate(DateTime value) =>
      RealmObjectBase.set(this, 'startDate', value);

  @override
  DateTime get endDate =>
      RealmObjectBase.get<DateTime>(this, 'endDate') as DateTime;
  @override
  set endDate(DateTime value) => RealmObjectBase.set(this, 'endDate', value);

  @override
  bool get isRecurring =>
      RealmObjectBase.get<bool>(this, 'isRecurring') as bool;
  @override
  set isRecurring(bool value) =>
      RealmObjectBase.set(this, 'isRecurring', value);

  @override
  Stream<RealmObjectChanges<BudgetModel>> get changes =>
      RealmObjectBase.getChanges<BudgetModel>(this);

  @override
  Stream<RealmObjectChanges<BudgetModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<BudgetModel>(this, keyPaths);

  @override
  BudgetModel freeze() => RealmObjectBase.freezeObject<BudgetModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'category': category.toEJson(),
      'amountLimit': amountLimit.toEJson(),
      'currentSpent': currentSpent.toEJson(),
      'startDate': startDate.toEJson(),
      'endDate': endDate.toEJson(),
      'isRecurring': isRecurring.toEJson(),
    };
  }

  static EJsonValue _toEJson(BudgetModel value) => value.toEJson();
  static BudgetModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'category': EJsonValue category,
        'amountLimit': EJsonValue amountLimit,
        'currentSpent': EJsonValue currentSpent,
        'startDate': EJsonValue startDate,
        'endDate': EJsonValue endDate,
      } =>
        BudgetModel(
          fromEJson(id),
          fromEJson(category),
          fromEJson(amountLimit),
          fromEJson(currentSpent),
          fromEJson(startDate),
          fromEJson(endDate),
          isRecurring: fromEJson(ejson['isRecurring'], defaultValue: true),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(BudgetModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      BudgetModel,
      'BudgetModel',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('category', RealmPropertyType.string),
        SchemaProperty('amountLimit', RealmPropertyType.double),
        SchemaProperty('currentSpent', RealmPropertyType.double),
        SchemaProperty('startDate', RealmPropertyType.timestamp),
        SchemaProperty('endDate', RealmPropertyType.timestamp),
        SchemaProperty('isRecurring', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
