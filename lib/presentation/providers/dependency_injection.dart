import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/repositories/person_repository_impl.dart';
import 'package:aldeewan_mobile/data/repositories/transaction_repository_impl.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';

// Data Source
final localDatabaseSourceProvider = Provider<LocalDatabaseSource>((ref) {
  return LocalDatabaseSource();
});

// Repositories
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return PersonRepositoryImpl(dataSource);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});
