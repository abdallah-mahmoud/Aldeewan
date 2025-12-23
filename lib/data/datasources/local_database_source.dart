import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';

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
        CategoryModel.schema,
        NotificationItemModel.schema,
      ],
      encryptionKey: key,
      schemaVersion: 4, // Incremented for goalId field
      migrationCallback: (migration, oldSchemaVersion) {
        const targetVersion = 4;
        debugPrint('🔄 Realm migration: v$oldSchemaVersion -> v$targetVersion');
        
        // Version-specific migrations (add as needed)
        if (oldSchemaVersion < 2) {
          debugPrint('  📦 Migrating v1 -> v2');
          // v1 -> v2: Initial person/transaction schema
        }
        if (oldSchemaVersion < 3) {
          debugPrint('  📦 Migrating v2 -> v3: Added budgets and goals');
          // v2 -> v3: Added budgets and savings goals
        }
        if (oldSchemaVersion < 4) {
          debugPrint('  📦 Migrating v3 -> v4: Added goalId to transactions');
          // v3 -> v4: Added goalId field to transactions
        }
        
        debugPrint('✅ Migration completed successfully');
      },
    );
    
    return Realm(config);
  }

  Future<List<int>> _getEncryptionKey() async {
    // 1. Check Secure Storage first (Runtime/Previous key)
    String? keyString = await _storage.read(key: 'realm_db_key');
    
    if (keyString != null) {
      try {
        return base64Url.decode(keyString);
      } catch (_) {
        // failed to decode, ignore and re-generate/read from env
      }
    }

    // 2. Check .env (Pre-provisioned key)
    final envKey = dotenv.env['REALM_ENCRYPTION_KEY'];
    List<int> key;

    if (envKey != null && envKey.length == 128) { // 64 bytes hex = 128 chars
       try {
         // Hex decode
         key = List<int>.generate(64, (i) => int.parse(envKey.substring(i * 2, i * 2 + 2), radix: 16));
         // Persist normalized base64 for consistency with reading logic above
         await _storage.write(key: 'realm_db_key', value: base64Url.encode(key));
         return key;
       } catch (e) {
         // Invalid hex in env, fallthrough to random
       }
    }

    // 3. Fallback: Generate Random Key
    key = List<int>.generate(64, (i) => Random.secure().nextInt(256));
    await _storage.write(key: 'realm_db_key', value: base64Url.encode(key));
    return key;
  }

  // --- Person Operations ---
  Stream<List<PersonModel>> watchPeople() async* {
    final realm = await db;
    yield* realm.all<PersonModel>().changes.map((results) => results.results.toList());
  }

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
  Stream<List<TransactionModel>> watchTransactions() async* {
    final realm = await db;
    yield* realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").changes.map((results) => results.results.toList());
  }

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
