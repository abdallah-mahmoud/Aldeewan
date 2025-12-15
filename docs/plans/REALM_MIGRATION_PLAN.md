# Isar to Realm Migration Plan

## Objective
Replace Isar database with Realm to enable full database encryption (AES-256) while maintaining existing functionality and data structure.

## 1. Dependencies Update
**File:** `pubspec.yaml`

- **Remove:**
  - `isar`
  - `isar_flutter_libs`
  - `isar_generator` (dev_dependency)
- **Add:**
  - `realm`: ^1.8.0 (or latest)
  - `realm_generator`: ^1.8.0 (dev_dependency)

## 2. Model Migration strategy
Convert all Isar `@collection` classes to Realm `@RealmModel` classes.

### General Mapping Rule
| Isar Feature | Realm Equivalent | Notes |
| :--- | :--- | :--- |
| `@collection` | `@RealmModel()` | Realm classes are private `_Name` |
| `Id id = Isar.autoIncrement` | `ObjectId id = ObjectId();` | Realm uses ObjectId or Uuid as primary key |
| `@Index` | `@Indexed()` | |
| `@Enumerated` | Store as String or int | Realm supports Enums in newer versions, or map manually |
| `late String name` | `late String name;` | |
| `List<String>` | `List<String>` | |
| `DateTime` | `DateTime` | |

### Specific Model Changes

#### 1. `PersonModel` (`lib/data/models/person_model.dart`)
- Change `@collection` to `@RealmModel()`.
- Class name `_PersonModel`.
- Primary Key: `String uuid` (Keep UUID to match Domain Entity).
- Annotate `uuid` with `@PrimaryKey()`.
- Remove `Id id = Isar.autoIncrement`.

#### 2. `TransactionModel` (`lib/data/models/transaction_model.dart`)
- Primary Key: `String uuid`.
- Foreign Key `personId`: Keep as String (Indexed).
- `TransactionType`: Store as String (name) or int (index).

#### 3. `FinancialAccountModel` (`lib/data/models/financial_account_model.dart`)
- Primary Key: `String uuid`.

#### 4. `BudgetModel` (`lib/data/models/budget_model.dart`)
- Primary Key: `String uuid`.

#### 5. `SavingsGoalModel` (`lib/data/models/savings_goal_model.dart`)
- Primary Key: `String uuid`.

## 3. Database Source Implementation
**File:** `lib/data/datasources/local_database_source.dart`

### Initialization & Encryption
- Use `Configuration.local` with `encryptionKey`.
- Retrieve/Generate key using `FlutterSecureStorage` (reuse existing logic).
- **Key Format:** Realm requires a 64-byte key (512 bits), whereas Isar/Generic usually uses 32-byte. We must ensure we generate 64 bytes.

```dart
final config = Configuration.local(
  [PersonModel.schema, TransactionModel.schema, ...],
  encryptionKey: key, // 64 bytes
  schemaVersion: 1,
);
final realm = Realm(config);
```

### CRUD Operations Rewrite
- **Create/Update:** `realm.write(() { realm.add(item, update: true); });`
- **Read:** `realm.all<PersonModel>()` or `realm.query<PersonModel>(...)`.
- **Delete:** `realm.write(() { realm.delete(item); });`

## 4. Repository Updates
- Update `toEntity()` and `fromEntity()` mappers in Models to handle Realm types if necessary.
- Ensure Repositories await the `LocalDatabaseSource` methods (Realm is synchronous for reads, but we can keep the Future signature in DataSource to avoid breaking Repository interfaces).

## 5. Execution Steps

1.  **Backup:** Commit current state.
2.  **Clean:** `flutter clean`.
3.  **Update Pubspec:** Swap dependencies.
4.  **Refactor Models:**
    -   Modify `person_model.dart`
    -   Modify `transaction_model.dart`
    -   Modify `financial_account_model.dart`
    -   Modify `budget_model.dart`
    -   Modify `savings_goal_model.dart`
5.  **Generate Code:** Run `dart run realm generate`.
6.  **Refactor DataSource:** Rewrite `LocalDatabaseSource`.
7.  **Fix Compilation Errors:** Update any broken references in Repositories.
8.  **Test:** Verify CRUD and Encryption.

## 6. Migration Note (Data Loss)
**Important:** This migration will **wipe existing Isar data** on the device because the database file format is completely different. Since the app is in development/V1.2 phase, this is assumed acceptable. If not, a migration script to read Isar -> Memory -> Realm is needed (complex).

## 7. Key Generation Logic Update
Update `_getEncryptionKey` to generate 64 bytes (512 bits) instead of 32 bytes.

```dart
// Realm requires 64 bytes
final key = List<int>.generate(64, (i) => Random.secure().nextInt(256));
```
