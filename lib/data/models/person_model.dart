import 'package:isar/isar.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';

part 'person_model.g.dart';

@collection
class PersonModel {
  Id id = Isar.autoIncrement; // Isar requires an integer ID for auto-increment

  @Index(unique: true, replace: true)
  late String uuid; // We'll use a UUID to match the Domain Entity ID

  @Enumerated(EnumType.name)
  late PersonRole role;

  late String name;
  String? phone;
  late DateTime createdAt;

  // Mapper: Model -> Entity
  Person toEntity() {
    return Person(
      id: uuid,
      role: role,
      name: name,
      phone: phone,
      createdAt: createdAt,
    );
  }

  // Mapper: Entity -> Model
  static PersonModel fromEntity(Person person) {
    return PersonModel()
      ..uuid = person.id
      ..role = person.role
      ..name = person.name
      ..phone = person.phone
      ..createdAt = person.createdAt;
  }
}
