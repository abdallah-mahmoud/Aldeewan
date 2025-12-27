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

/// A data source class that manages local database operations using Realm.
///
/// This class provides methods for initializing the Realm database, handling encryption,
/// performing migrations, and executing CRUD (Create, Read, Update, Delete) operations
/// for various data models such as PersonModel, TransactionModel, and others.
class LocalDatabaseSource {
  /// A Future that holds the initialized Realm database instance.
  /// It's late-initialized in the constructor.
  late Future<Realm> db;

  /// Secure storage instance used to store and retrieve the Realm encryption key.
  final _storage = const FlutterSecureStorage();

  /// Constructs a [LocalDatabaseSource] and initializes the database.
  LocalDatabaseSource() {
    db = _initDb();
  }

  /// Initializes the Realm database with the defined schema and encryption.
  ///
  /// This method retrieves an encryption key, configures the Realm with all
  /// necessary schema classes, and sets up a migration callback for schema evolution.
  /// - Returns: A `Future<Realm>` instance of the initialized database.
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

  /// Retrieves or generates the encryption key for the Realm database.
  ///
  /// The method prioritizes:
  /// 1. An existing key from `FlutterSecureStorage`.
  /// 2. A pre-provisioned key from environment variables (`REALM_ENCRYPTION_KEY`).
  /// 3. A newly generated random key if neither of the above is available, which is then securely stored.
  /// - Returns: A `Future<List<int>>` representing the 64-byte encryption key.
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
  /// Watches for changes in the collection of [PersonModel] objects.
  ///
  /// - Returns: A `Stream<List<PersonModel>>` that emits a new list of people
  ///   whenever there are changes in the database.
  Stream<List<PersonModel>> watchPeople() async* {
    final realm = await db;
    yield* realm.all<PersonModel>().changes.map((results) => results.results.toList());
  }

  /// Retrieves all [PersonModel] objects currently stored in the database.
  ///
  /// - Returns: A `Future<List<PersonModel>>` containing all people.
  Future<List<PersonModel>> getPeople() async {
    final realm = await db;
    return realm.all<PersonModel>().toList();
  }

  /// Retrieves a single [PersonModel] object by its unique identifier.
  ///
  /// - Parameters:
  ///   - `uuid`: The unique ID of the person to retrieve.
  /// - Returns: A `Future<PersonModel?>` containing the found person, or `null` if not found.
  Future<PersonModel?> getPerson(String uuid) async {
    final realm = await db;
    return realm.find<PersonModel>(uuid);
  }

  /// Adds a new [PersonModel] or updates an existing one in the database.
  ///
  /// If a person with the same primary key (`id`) already exists, it will be updated.
  /// Otherwise, a new person will be added.
  /// - Parameters:
  ///   - `person`: The [PersonModel] object to be added or updated.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> putPerson(PersonModel person) async {
    final realm = await db;
    realm.write(() {
      realm.add(person, update: true);
    });
  }

  /// Deletes a [PersonModel] object from the database by its unique identifier.
  ///
  /// If the person is found, it will be removed from the database.
  /// - Parameters:
  ///   - `uuid`: The unique ID of the person to delete.
  /// - Returns: A `Future<void>` that completes when the operation is done.
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
  /// Watches for changes in the collection of [TransactionModel] objects, sorted by date in descending order.
  ///
  /// - Returns: A `Stream<List<TransactionModel>>` that emits a new list of transactions
  ///   whenever there are changes in the database.
  Stream<List<TransactionModel>> watchTransactions() async* {
    final realm = await db;
    yield* realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").changes.map((results) => results.results.toList());
  }

  /// Retrieves all [TransactionModel] objects from the database, sorted by date in descending order.
  ///
  /// - Returns: A `Future<List<TransactionModel>>` containing all transactions.
  Future<List<TransactionModel>> getTransactions() async {
    final realm = await db;
    // Sort by date desc. Realm query syntax: "TRUEPREDICATE SORT(date DESC)"
    return realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").toList();
  }

  /// Retrieves a list of [TransactionModel] objects associated with a specific person, sorted by date in descending order.
  ///
  /// - Parameters:
  ///   - `personId`: The ID of the person whose transactions are to be retrieved.
  /// - Returns: A `Future<List<TransactionModel>>` containing transactions by the specified person.
  Future<List<TransactionModel>> getTransactionsByPerson(String personId) async {
    final realm = await db;
    return realm.query<TransactionModel>("personId == \$0 SORT(date DESC)", [personId]).toList();
  }

  /// Retrieves a list of [TransactionModel] objects within a specified date range, sorted by date in descending order.
  ///
  /// - Parameters:
  ///   - `start`: The start `DateTime` of the range (inclusive).
  ///   - `end`: The end `DateTime` of the range (inclusive).
  /// - Returns: A `Future<List<TransactionModel>>` containing transactions within the date range.
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final realm = await db;
    return realm.query<TransactionModel>("date >= \$0 AND date <= \$1 SORT(date DESC)", [start, end]).toList();
  }

  /// Adds a new [TransactionModel] or updates an existing one in the database.
  ///
  /// If a transaction with the same primary key (`id`) already exists, it will be updated.
  /// Otherwise, a new transaction will be added.
  /// - Parameters:
  ///   - `transaction`: The [TransactionModel] object to be added or updated.
  /// - Returns: A `Future<void>` that completes when the operation is done.
  Future<void> putTransaction(TransactionModel transaction) async {
    final realm = await db;
    realm.write(() {
      realm.add(transaction, update: true);
    });
  }

  /// Deletes a [TransactionModel] object from the database by its unique identifier.
  ///
  /// If the transaction is found, it will be removed from the database.
  /// - Parameters:
  ///   - `uuid`: The unique ID of the transaction to delete.
  /// - Returns: A `Future<void>` that completes when the operation is done.
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
  /// Clears all data for specific Realm models from the database.
  ///
  /// This operation deletes all instances of `PersonModel`, `TransactionModel`,
  /// `FinancialAccountModel`, `BudgetModel`, and `SavingsGoalModel`.
  /// - Returns: A `Future<void>` that completes when all specified data has been deleted.
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
