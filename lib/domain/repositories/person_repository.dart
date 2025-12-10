import 'package:aldeewan_mobile/domain/entities/person.dart';

abstract class PersonRepository {
  Future<List<Person>> getPeople();
  Future<Person?> getPerson(String id);
  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> deletePerson(String id);
}
