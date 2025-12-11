import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';

final localDatabaseSourceProvider = Provider<LocalDatabaseSource>((ref) {
  return LocalDatabaseSource();
});

final isarProvider = FutureProvider<Isar>((ref) async {
  final source = ref.watch(localDatabaseSourceProvider);
  return source.db;
});
