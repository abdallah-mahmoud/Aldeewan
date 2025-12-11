import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';

part 'person_model.realm.dart';

@RealmModel()
class _PersonModel {
  @PrimaryKey()
  late String id;

  late String role; // Storing Enum as String
  late String name;
  String? phone;
  late DateTime createdAt;
}

extension PersonModelMapper on PersonModel {
  Person toEntity() {
    return Person(
      id: id,
      role: PersonRole.values.firstWhere((e) => e.name == role, orElse: () => PersonRole.customer),
      name: name,
      phone: phone,
      createdAt: createdAt,
    );
  }

  static PersonModel fromEntity(Person person) {
    return PersonModel(
      person.id,
      person.role.name,
      person.name,
      person.createdAt,
      phone: person.phone,
    );
  }
}
