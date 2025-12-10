# Aldeewan Mobile – App Status Report

Date: 2025-12-10
App Version: 1.1.0+1

## 1. Overview

**Aldeewan Mobile** is a small-business ledger and cashbook application built with Flutter. It helps users track customers and suppliers, manage receivables and payables, record cash transactions, and generate basic financial reports. The app targets mobile platforms (Android/iOS) and supports both English and Arabic.

## 2. Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod`
- **Routing**: `go_router`
- **Persistence**:
  - Isar database (`isar`, `isar_flutter_libs`) for local storage of persons and transactions
  - `shared_preferences` and `path_provider` for simple key-value and path access
- **Localization & Formatting**:
  - Flutter localization (`flutter_localizations`)
  - `intl` for date/number formatting and generated localizations in `lib/l10n`
- **Platform Features & Utilities**:
  - `file_picker` for loading backup JSON files
  - `share_plus` for exporting backups and CSVs
  - `url_launcher` for opening external links (developer contact, GitHub)
- **UI & Icons**:
  - Material 3 theming via `lib/config/theme.dart`
  - `lucide_icons` package

## 3. Architecture Overview

The project follows a layered architecture:

- `lib/domain/`
  - Core business models and enums, e.g.:
    - `Transaction` and `TransactionType` (`lib/domain/entities/transaction.dart`)
    - `Person` and `PersonRole` (`lib/domain/entities/person.dart`)
  - Repository interfaces:
    - `TransactionRepository`
    - `PersonRepository`

- `lib/data/`
  - **Models**: Isar-backed persistence models with generated schemas
    - `person_model.dart`, `person_model.g.dart`
    - `transaction_model.dart`, `transaction_model.g.dart`
  - **Data Sources**:
    - `local_database_source.dart` – wraps Isar open/close and basic CRUD operations for persons and transactions, including a `clearAll()` helper for backup/restore.
  - **Repository Implementations**:
    - `person_repository_impl.dart`
    - `transaction_repository_impl.dart`
  - These bridge domain entities and Isar models.

- `lib/presentation/`
  - **Screens** (`lib/presentation/screens/`):
    - `HomeScreen` – dashboard, statistics, quick actions, and recent transactions.
    - `LedgerScreen` – customer/supplier lists with balances and navigation to detailed statements.
    - `CashbookScreen` – filtered view of cash-related transactions with ability to add new entries.
    - `ReportsScreen` – person statement and cash flow reports with CSV export.
    - `SettingsScreen` – appearance, language, currency options, backup/restore, exports, and about screen.
    - `PersonDetailsScreen` – detailed ledger/statement for a specific person (customers/suppliers).
    - `AboutScreen` – developer contact and open-source link info.
  - **Widgets** (`lib/presentation/widgets/`):
    - `ScaffoldWithNavBar` and `bottom_nav_bar.dart` – shell layout and navigation.
    - `cash_entry_form.dart`, `transaction_form.dart` – forms for adding/editing transactions.
    - `person_form.dart` – form for adding/editing persons.
    - `person_statement_report.dart`, `cash_flow_report.dart` – report UIs.
  - **Providers** (`lib/presentation/providers/`):
    - `ledger_provider.dart` – exposes ledger state (persons, transactions, summary totals and balances).
    - `theme_provider.dart` – controls `ThemeMode`.
    - `locale_provider.dart` – controls the current `Locale`.
    - `currency_provider.dart` – controls selected currency.
    - `dependency_injection.dart` – bootstraps repositories and the ledger provider.

- `lib/config/`
  - `router.dart` – central GoRouter configuration with a shell route and bottom navigation.
  - `theme.dart` – light and dark `ThemeData` definitions used by `MaterialApp.router`.

- `lib/utils/`
  - Utilities like `csv_exporter.dart` to generate and share CSV exports.

- `lib/l10n/`
  - Generated localization files (`app_localizations.dart`) based on `l10n.yaml` and ARB files.

## 4. App Features

### 4.1 Home / Dashboard

- Displays app name and localized tagline (via `AppLocalizations`).
- Shows high-level financial stats using `LedgerNotifier` from `ledgerProvider`:
  - Total receivable
  - Total payable
  - Monthly income
  - Monthly expense
- Renders **recent activity** (last transactions ordered by date) with color-coded icons and amounts.
- Provides **quick actions**:
  - Add debt (navigates to ledger with `action=debt`)
  - Record payment (navigates to ledger with `action=payment`)
  - Add cash entry (navigates to cashbook with `action=add`)
  - View balances (navigates directly to the ledger screen)

### 4.2 Ledger Management

- Separate tabs for **customers** and **suppliers** using a `TabController`.
- Person list for each role:
  - Name and optional phone number
  - Calculated balance per person (positive/negative and colored based on role and sign)
- Tapping a person navigates to `/ledger/:id` (person details screen).
- Floating action button opens a bottom sheet with `PersonForm` to add new customers or suppliers.

### 4.3 Cashbook

- Cashbook screen filters ledger transactions for cash-only types:
  - `paymentReceived`
  - `paymentMade`
  - `cashSale`
  - `cashIncome`
  - `cashExpense`
- Transactions are sorted by date (newest first) and shown in a list with:
  - Icon and color indicating income vs expense.
  - Formatted date, optional linked person indicator placeholder, and optional note.
  - Amount styled in green (income) or red (expense).
- Floating action button opens a modal `CashEntryForm` allowing users to add cash transactions, which are then persisted via `ledgerProvider`.

### 4.4 Reports

- **Person Statement Report** tab:
  - Shows a statement per person, backed by ledger state (persons and their transactions).
- **Cash Flow Report** tab:
  - Displays aggregated cash in/out over time.
- **CSV Export for Persons**:
  - Generates a CSV with columns: ID, Name, Role, Phone, Created At.
  - Uses `CsvExporter.exportToCsv` to share or save the file with a generated filename (e.g., `persons_YYYYMMDD.csv`).

### 4.5 Settings & Data Management

- **Appearance**:
  - Theme selection (System / Light / Dark) using `themeProvider` and `ThemeMode`.
- **Language**:
  - Locale selection between English (`en`) and Arabic (`ar`) using `localeProvider`.
- **Currency Options**:
  - Dropdown to select one of several currency codes (USD, EUR, SAR, EGP, AED); controlled by `currencyProvider`.
- **Data Management**:
  - **Backup Data**:
    - Serializes persons and transactions to a JSON structure with a `version` field and timestamp.
    - Writes the JSON to a temporary file.
    - Uses `Share.shareXFiles` to share the backup file.
  - **Restore Data**:
    - Opens a file picker for JSON files.
    - Validates backup `version`.
    - Reconstructs `Person` and `Transaction` entities and re-inserts them via `ledgerProvider`.
    - Shows localized success/failure messages.
  - **CSV Exports**:
    - Persons export (similar to Reports export).
    - Transactions export with columns for Date, Type, Person, Amount, Note, Category, resolving person names from IDs.
- **About Developer**:
  - Navigates to `/settings/about` which shows an about screen with developer avatar, bio, and links (Facebook, Instagram, email, phone, GitHub repo).

## 5. Routing & Navigation

Configured in `lib/config/router.dart` using `GoRouter` and a shell route:

- **ShellRoute** with `ScaffoldWithNavBar` as a shared layout and bottom navigation bar.
- Routes:
  - `/` – `HomeScreen`
  - `/ledger` – `LedgerScreen`
    - `/ledger/:id` – `PersonDetailsScreen` (opened above shell using the root navigator key)
  - `/cashbook` – `CashbookScreen`
  - `/reports` – `ReportsScreen`
  - `/settings` – `SettingsScreen`
    - `/settings/about` – `AboutScreen` (opened above shell)

Routing is provided to the app tree via `routerProvider` (a Riverpod `Provider<GoRouter>`) and passed into `MaterialApp.router` in `main.dart`.

## 6. State Management

- Global provider scope is created in `main.dart` using `ProviderScope`.
- `MyApp` is a `ConsumerWidget`, reading:
  - `themeProvider` (for `ThemeMode`)
  - `localeProvider` (for `Locale`)
  - `routerProvider` (for `GoRouter`)
- `ledgerProvider` acts as a facade over domain repositories and holds:
  - List of persons and transactions
  - Loading flag
  - Summary metrics (totals and monthly aggregates)
  - Operations like `addPerson`, `addTransaction`, balance calculations, and queries
- Additional providers manage app-level settings (theme, locale, currency).

## 7. Localization

- Uses Flutter localization and generated localizations (`lib/l10n/generated/app_localizations.dart`).
- `l10n.yaml` config is present and `flutter generate` is enabled in `pubspec.yaml`.
- `MaterialApp.router` is configured with:
  - `supportedLocales: AppLocalizations.supportedLocales`
  - `localizationsDelegates: AppLocalizations.localizationsDelegates`
- UI text uses `AppLocalizations.of(context)!` throughout the presentation layer.

## 8. Analysis & Quality Checks

### 8.1 Dart & Flutter Analysis

Commands executed from project root:

- `flutter pub get`
- `dart analyze`

Current results:

- `dart analyze`: **No issues found**.
- `flutter analyze`: Tool invocation had an environment error in this session, but given `dart analyze` is clean and the codebase builds and runs under Flutter, the project is considered **analysis-clean** from a Dart/Flutter code perspective.

Recent fixes performed as part of this review:

- Removed unused theme fields and references in `lib/config/theme.dart` that were triggering `unused_field` warnings:
  - `_lightOnSurfaceSecondary`
  - `_darkOnSurfaceSecondary`
  - `_brandGreen`
- Updated the `ColorScheme.light` configuration to no longer reference the removed `onSurfaceVariant` color.

### 8.2 Tests

- No custom tests were run in this session and there appear to be no substantial test files beyond boilerplate.
- Recommendation: introduce unit tests for:
  - `ledgerProvider` (ledger calculations, add/delete logic).
  - Repository implementations (Isar integration, backup/restore flows).

## 9. Known Issues & Technical Debt

Based on the current inspection:

- **Testing**:
  - Minimal or no automated tests. Increases risk of regressions for business rules (e.g., balances, cash flow calculations, backup/restore).
- **Backup & Restore**:
  - Restore implementation currently re-inserts persons and transactions via `ledgerProvider` and relies on Isar `put` semantics to handle updates.
  - There is no explicit confirmation dialog before replacing data.
  - `LocalDatabaseSource.clearAll()` exists but is not yet integrated into the restore flow to ensure a full replace vs. merge.
- **Reports UX & Localization**:
  - Some labels (e.g., mapping of transaction types such as `cashSale`, `cashIncome`) are mapped to generic l10n keys like `income` and `expense`. More granular localization keys could improve clarity.
  - Recent activity and person labels sometimes use raw enum names split by `.`; localized names would be preferable.
- **Theming**:
  - Some previously defined colors were unused and removed; if the design spec needs them later, they should be reintroduced in a way that is referenced by the theme.

## 10. Recommendations & Next Steps

1. **Add Tests**
   - Introduce unit tests for `ledgerProvider` to validate:
     - Per-person balance calculation.
     - Total receivable/payable and monthly income/expense aggregation.
     - Behavior of add/remove operations.
   - Add tests for backup/restore logic to ensure JSON format stability and compatibility.

2. **Harden Backup/Restore**
   - Use `LocalDatabaseSource.clearAll()` as part of a full-restore option, gated behind a user confirmation dialog.
   - Add support for backup format versioning and graceful migration if schemas change.

3. **Improve Reporting & Localization**
   - Replace enum `toString().split('.')` usage with explicit, localized labels.
   - Add ARB keys for each `TransactionType` and common financial terms.

4. **Polish UX**
   - Enhance person and transaction detail views (e.g., richer filtering, paging for long histories).
   - Add validation and more descriptive field-level errors in forms.

5. **Continuous Quality Checks**
   - Adopt a standard pre-commit routine:
     - `dart format .`
     - `dart analyze`
     - `flutter test`
   - Optionally add CI with the same steps to keep the project analysis-clean.

