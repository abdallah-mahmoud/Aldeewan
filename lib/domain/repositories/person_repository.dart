import 'package:aldeewan_mobile/domain/entities/person.dart';

abstract class PersonRepository {
  Stream<List<Person>> watchPeople();
  Future<List<Person>> getPeople();
  Future<Person?> getPerson(String id);
  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> archivePerson(String id);
  Future<void> deletePerson(String id);
  Future<void> deletePersonWithTransactions(String id);
  Future<int> getTransactionCount(String id);
}
