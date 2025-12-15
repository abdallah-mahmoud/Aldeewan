import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/utils/icon_helper.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required String type,
    @Default(false) bool isCustom,
  }) = _Category;

  factory Category.fromModel(CategoryModel model) {
    return Category(
      id: model.id.hexString,
      name: model.name,
      icon: IconHelper.getIcon(model.iconName),
      color: Color(int.parse(model.colorHex)),
      type: model.type,
      isCustom: model.isCustom,
    );
  }
}
