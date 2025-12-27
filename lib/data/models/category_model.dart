import 'package:realm/realm.dart';

part 'category_model.realm.dart';

/// Represents a category item stored in the Realm database.
///
/// This class defines the schema for a category, including its name, icon, color,
/// type (income or expense), and whether it is a custom category.
@RealmModel()
class _CategoryModel {
  /// The unique identifier for the category.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late ObjectId id;

  /// The name of the category (e.g., "Groceries", "Salary").
  late String name;
  /// The name of the Lucide icon associated with this category (e.g., 'home').
  late String iconName;
  /// The hex code representation of the color associated with this category (e.g., '0xFF2196F3').
  late String colorHex;
  /// The type of the category, indicating if it's an 'income' or 'expense' category.
  late String type;
  /// A boolean flag indicating whether this category is a custom user-added category (`true`)
  /// or a default system category (`false`).
  late bool isCustom;
}
