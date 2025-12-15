import 'package:realm/realm.dart';

part 'category_model.realm.dart';

@RealmModel()
class _CategoryModel {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late String iconName; // Store the name of the Lucide icon (e.g., 'home')
  late String colorHex; // Store hex code (e.g., '0xFF2196F3')
  late String type; // 'income' or 'expense'
  late bool isCustom; // To distinguish default vs user-added
}
