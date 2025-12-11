import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';

class LocalDatabaseSource {
  late Future<Isar> db;
  final _storage = const FlutterSecureStorage();

  LocalDatabaseSource() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          PersonModelSchema, 
          TransactionModelSchema,
          FinancialAccountModelSchema,
          BudgetModelSchema,
          SavingsGoalModelSchema,
        ],
        directory: dir.path,
        inspector: true,
        // encryptionKey: encryptionKey, // TODO: Re-enable when Isar supports it or upgrade
      );
    }
    return Future.value(Isar.getInstance());
  }

  /*
  Future<List<int>> _getEncryptionKey() async {
    String? keyString = await _storage.read(key: 'isar_db_key');
    
    if (keyString == null) {
      final key = List<int>.generate(32, (i) => Random.secure().nextInt(256));
      keyString = base64Url.encode(key);
      await _storage.write(key: 'isar_db_key', value: keyString);
      return key;
    } else {
      return base64Url.decode(keyString);
    }
  }
  */

  // --- Person Operations ---
  Future<List<PersonModel>> getPeople() async {
    final isar = await db;
    return await isar.personModels.where().findAll();
  }

  Future<PersonModel?> getPerson(String uuid) async {
    final isar = await db;
    return await isar.personModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> putPerson(PersonModel person) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // Check if exists to preserve ID if needed, but uuid is unique index so put works for insert/update
      // However, Isar requires the Id field to be set for updates if we want to overwrite the same object in DB efficiently
      // For now, we rely on the unique index on 'uuid' with replace: true
      await isar.personModels.put(person);
    });
  }

  Future<void> deletePerson(String uuid) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.personModels.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  // --- Transaction Operations ---
  Future<List<TransactionModel>> getTransactions() async {
    final isar = await db;
    return await isar.transactionModels.where().sortByDateDesc().findAll();
  }

  Future<List<TransactionModel>> getTransactionsByPerson(String personId) async {
    final isar = await db;
    return await isar.transactionModels.filter().personIdEqualTo(personId).sortByDateDesc().findAll();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final isar = await db;
    return await isar.transactionModels.filter().dateBetween(start, end).sortByDateDesc().findAll();
  }

  Future<void> putTransaction(TransactionModel transaction) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  Future<void> deleteTransaction(String uuid) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactionModels.filter().uuidEqualTo(uuid).deleteAll();
    });
  }
  
  // --- Backup/Restore ---
  Future<void> clearAll() async {
      final isar = await db;
      await isar.writeTxn(() async {
          await isar.clear();
      });
  }
}
