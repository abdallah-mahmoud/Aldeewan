import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';
import 'package:flutter/foundation.dart';

class PersonRepositoryImpl implements PersonRepository {
  final LocalDatabaseSource _dataSource;

  PersonRepositoryImpl(this._dataSource);

  @override
  Stream<List<Person>> watchPeople() {
    return _dataSource.watchPeople().map((models) => models.map((m) => m.toEntity()).toList());
  }

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
    try {
      final model = PersonModelMapper.fromEntity(person);
      await _dataSource.putPerson(model);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to add person: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updatePerson(Person person) async {
    try {
      final model = PersonModelMapper.fromEntity(person);
      await _dataSource.putPerson(model);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to update person: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> archivePerson(String id) async {
    await _dataSource.archivePerson(id);
  }

  @override
  Future<void> deletePerson(String id) async {
    await _dataSource.deletePerson(id);
  }

  @override
  Future<void> deletePersonWithTransactions(String id) async {
    await _dataSource.deletePersonWithTransactions(id);
  }

  @override
  Future<int> getTransactionCount(String id) async {
    return await _dataSource.getTransactionCountByPerson(id);
  }
}
