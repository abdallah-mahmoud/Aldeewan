import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';

final localDatabaseSourceProvider = Provider<LocalDatabaseSource>((ref) {
  return LocalDatabaseSource();
});

final realmProvider = FutureProvider<Realm>((ref) async {
  final source = ref.watch(localDatabaseSourceProvider);
  return source.db;
});
