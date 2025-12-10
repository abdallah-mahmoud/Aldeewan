import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  final LocalDatabaseSource _dataSource;

  PersonRepositoryImpl(this._dataSource);

  @override
  Future<List<Person>> getPeople() async {
    final models = await _dataSource.getPeople();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Person?> getPerson(String id) async {
    final model = await _dataSource.getPerson(id);
    return model?.toEntity();
  }

  @override
  Future<void> addPerson(Person person) async {
    final model = PersonModel.fromEntity(person);
    await _dataSource.putPerson(model);
  }

  @override
  Future<void> updatePerson(Person person) async {
    final model = PersonModel.fromEntity(person);
    // We need to ensure the Isar Id is preserved if we want to be efficient, 
    // but since we use UUID index with replace=true, putPerson handles it.
    // However, to be safe and correct with Isar's internal ID:
    final existing = await _dataSource.getPerson(person.id);
    if (existing != null) {
      model.id = existing.id;
    }
    await _dataSource.putPerson(model);
  }

  @override
  Future<void> deletePerson(String id) async {
    await _dataSource.deletePerson(id);
  }
}
