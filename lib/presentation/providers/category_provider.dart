import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:realm/realm.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  final realmAsync = ref.watch(realmProvider);
  return realmAsync.when(
    data: (realm) => CategoryNotifier(realm),
    loading: () => CategoryNotifier(null),
    error: (e, s) => CategoryNotifier(null),
  );
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  final Realm? _realm;

  CategoryNotifier(this._realm) : super([]) {
    if (_realm != null) {
      _loadCategories();
    }
  }

  void _loadCategories() {
    final realm = _realm;
    if (realm == null) return;

    final results = realm.all<CategoryModel>();
    if (results.isEmpty) {
      _seedDefaults();
    } else {
      state = results.map((m) => Category.fromModel(m)).toList();
    }
  }

  void _seedDefaults() {
    final realm = _realm;
    if (realm == null) return;

    final defaults = [
      _createModel('Housing', 'home', Colors.blue, 'expense'),
      _createModel('Food & Dining', 'utensils', Colors.orange, 'expense'),
      _createModel('Transportation', 'car', Colors.teal, 'expense'),
      _createModel('Health', 'heartPulse', Colors.red, 'expense'),
      _createModel('Entertainment', 'clapperboard', Colors.purple, 'expense'),
      _createModel('Shopping', 'shoppingBag', Colors.pink, 'expense'),
      _createModel('Utilities', 'lightbulb', Colors.yellow, 'expense'),
      _createModel('Income', 'wallet', Colors.green, 'income'),
    ];
    
    realm.write(() {
      realm.addAll(defaults);
    });
    _loadCategories();
  }

  CategoryModel _createModel(String name, String icon, Color color, String type) {
    return CategoryModel(
      ObjectId(),
      name,
      icon,
      '0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      type,
      false,
    );
  }

  void addCategory(String name, String iconName, Color color, String type) {
    final realm = _realm;
    if (realm == null) return;

    final model = CategoryModel(
      ObjectId(),
      name,
      iconName,
      '0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      type,
      true,
    );
    realm.write(() {
      realm.add(model);
    });
    _loadCategories();
  }
  
  void deleteCategory(String id) {
     final realm = _realm;
     if (realm == null) return;

     final objectId = ObjectId.fromHexString(id);
     final model = realm.find<CategoryModel>(objectId);
     if (model != null) {
       // Check for active budgets using this category
       final activeBudgets = realm.all<BudgetModel>().query('category == \$0', [model.name]);
       if (activeBudgets.isNotEmpty) {
         throw Exception('Cannot delete category "${model.name}" because it is used in active budgets.');
       }

       realm.write(() {
         realm.delete(model);
       });
       _loadCategories();
     }
  }
}
