import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';

part 'person_model.g.dart';

@RealmModel()
class _PersonModel {
  @PrimaryKey()
  late String uuid;

  late String role; // Storing Enum as String
  late String name;
  String? phone;
  late DateTime createdAt;
}

extension PersonModelMapper on PersonModel {
  Person toEntity() {
    return Person(
      id: uuid,
      role: PersonRole.values.firstWhere((e) => e.name == role, orElse: () => PersonRole.debtor),
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
