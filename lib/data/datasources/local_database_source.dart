import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';

class LocalDatabaseSource {
  late Future<Realm> db;
  final _storage = const FlutterSecureStorage();

  LocalDatabaseSource() {
    db = _initDb();
  }

  Future<Realm> _initDb() async {
    final key = await _getEncryptionKey();
    
    final config = Configuration.local(
      [
        PersonModel.schema, 
        TransactionModel.schema,
        FinancialAccountModel.schema,
        BudgetModel.schema,
        SavingsGoalModel.schema,
      ],
      encryptionKey: key,
      schemaVersion: 1,
    );
    
    return Realm(config);
  }

  Future<List<int>> _getEncryptionKey() async {
    String? keyString = await _storage.read(key: 'realm_db_key');
    
    if (keyString == null) {
      // Realm requires 64 bytes (512 bits)
      final key = List<int>.generate(64, (i) => Random.secure().nextInt(256));
      keyString = base64Url.encode(key);
      await _storage.write(key: 'realm_db_key', value: keyString);
      return key;
    } else {
      return base64Url.decode(keyString);
    }
  }

  // --- Person Operations ---
  Future<List<PersonModel>> getPeople() async {
    final realm = await db;
    return realm.all<PersonModel>().toList();
  }

  Future<PersonModel?> getPerson(String uuid) async {
    final realm = await db;
    return realm.find<PersonModel>(uuid);
  }

  Future<void> putPerson(PersonModel person) async {
    final realm = await db;
    realm.write(() {
      realm.add(person, update: true);
    });
  }

  Future<void> deletePerson(String uuid) async {
    final realm = await db;
    final person = realm.find<PersonModel>(uuid);
    if (person != null) {
      realm.write(() {
        realm.delete(person);
      });
    }
  }

  // --- Transaction Operations ---
  Future<List<TransactionModel>> getTransactions() async {
    final realm = await db;
    // Sort by date desc. Realm query syntax: "TRUEPREDICATE SORT(date DESC)"
    return realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").toList();
  }

  Future<List<TransactionModel>> getTransactionsByPerson(String personId) async {
    final realm = await db;
    return realm.query<TransactionModel>("personId == \$0 SORT(date DESC)", [personId]).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final realm = await db;
    return realm.query<TransactionModel>("date >= \$0 AND date <= \$1 SORT(date DESC)", [start, end]).toList();
  }

  Future<void> putTransaction(TransactionModel transaction) async {
    final realm = await db;
    realm.write(() {
      realm.add(transaction, update: true);
    });
  }

  Future<void> deleteTransaction(String uuid) async {
    final realm = await db;
    final transaction = realm.find<TransactionModel>(uuid);
    if (transaction != null) {
      realm.write(() {
        realm.delete(transaction);
      });
    }
  }
  
  // --- Backup/Restore ---
  Future<void> clearAll() async {
      final realm = await db;
      realm.write(() {
          realm.deleteAll<PersonModel>();
          realm.deleteAll<TransactionModel>();
          realm.deleteAll<FinancialAccountModel>();
          realm.deleteAll<BudgetModel>();
          realm.deleteAll<SavingsGoalModel>();
      });
  }
}
