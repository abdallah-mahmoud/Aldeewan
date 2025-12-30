import 'package:aldeewan_mobile/data/services/backup_service.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return BackupService(dataSource);
});
