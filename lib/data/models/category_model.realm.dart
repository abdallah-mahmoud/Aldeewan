// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class CategoryModel extends _CategoryModel
    with RealmEntity, RealmObjectBase, RealmObject {
  CategoryModel(
    ObjectId id,
    String name,
    String iconName,
    String colorHex,
    String type,
    bool isCustom,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'iconName', iconName);
    RealmObjectBase.set(this, 'colorHex', colorHex);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'isCustom', isCustom);
  }

  CategoryModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get iconName =>
      RealmObjectBase.get<String>(this, 'iconName') as String;
  @override
  set iconName(String value) => RealmObjectBase.set(this, 'iconName', value);

  @override
  String get colorHex =>
      RealmObjectBase.get<String>(this, 'colorHex') as String;
  @override
  set colorHex(String value) => RealmObjectBase.set(this, 'colorHex', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  bool get isCustom => RealmObjectBase.get<bool>(this, 'isCustom') as bool;
  @override
  set isCustom(bool value) => RealmObjectBase.set(this, 'isCustom', value);

  @override
  Stream<RealmObjectChanges<CategoryModel>> get changes =>
      RealmObjectBase.getChanges<CategoryModel>(this);

  @override
  Stream<RealmObjectChanges<CategoryModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CategoryModel>(this, keyPaths);

  @override
  CategoryModel freeze() => RealmObjectBase.freezeObject<CategoryModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'iconName': iconName.toEJson(),
      'colorHex': colorHex.toEJson(),
      'type': type.toEJson(),
      'isCustom': isCustom.toEJson(),
    };
  }

  static EJsonValue _toEJson(CategoryModel value) => value.toEJson();
  static CategoryModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'iconName': EJsonValue iconName,
        'colorHex': EJsonValue colorHex,
        'type': EJsonValue type,
        'isCustom': EJsonValue isCustom,
      } =>
        CategoryModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(iconName),
          fromEJson(colorHex),
          fromEJson(type),
          fromEJson(isCustom),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CategoryModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CategoryModel,
      'CategoryModel',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('iconName', RealmPropertyType.string),
        SchemaProperty('colorHex', RealmPropertyType.string),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('isCustom', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
