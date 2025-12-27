import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';

part 'person_model.realm.dart';

/// Represents a person item stored in the Realm database.
///
/// This class defines the schema for a person, including their unique ID, role,
/// name, phone number, and creation timestamp.
@RealmModel()
class _PersonModel {
  /// The unique identifier for the person.
  /// This is the primary key in the Realm database.
  @PrimaryKey()
  late String id;

  /// The role of the person, stored as a String (e.g., 'customer', 'admin').
  late String role;
  /// The name of the person.
  late String name;
  /// The phone number of the person, which is optional.
  String? phone;
  /// The date and time when the person record was created.
  late DateTime createdAt;
}

/// Extension on [PersonModel] to facilitate mapping between the Realm model
/// and the domain entity [Person].
extension PersonModelMapper on PersonModel {
  /// Converts a [PersonModel] instance to a [Person] domain entity.
  ///
  /// This method maps the properties of the Realm model to the corresponding
  /// properties of the domain entity, including handling the conversion of
  /// the role string to a [PersonRole] enum.
  /// - Returns: A [Person] domain entity.
  Person toEntity() {
    return Person(
      id: id,
      role: PersonRole.values.firstWhere((e) => e.name == role, orElse: () => PersonRole.customer),
      name: name,
      phone: phone,
      createdAt: createdAt,
    );
  }

  /// Converts a [Person] domain entity to a [PersonModel] Realm instance.
  ///
  /// This static method is used to create a Realm-compatible model from a
  /// domain entity, converting the [PersonRole] enum back to its string representation.
  /// - Parameters:
  ///   - `person`: The [Person] domain entity to convert.
  /// - Returns: A [PersonModel] Realm instance.
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
