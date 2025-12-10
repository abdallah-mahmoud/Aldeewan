# Aldeewan Mobile

Aldeewan Mobile is a Flutter application for managing small-business ledgers and cashbooks. It helps you track customers and suppliers, record receivables and payables, manage cash transactions, and generate basic financial reports. The app supports English and Arabic and persists data locally using Isar.

## Features

- **Dashboard (Home)**
  - High-level summary cards for total receivable, total payable, monthly income, and monthly expense.
  - Recent activity list showing the latest transactions.
  - Quick actions to add debts, record payments, add cash entries, and jump directly to ledger balances.

- **Ledger Management**
  - Maintain customers and suppliers with names and optional phone numbers.
  - Separate tabs for customers and suppliers.
  - Per-person balance calculation with color-coded amounts.
  - Navigate to detailed person statements.

- **Cashbook**
  - Filtered view of cash-related transactions (payments, cash sales, income, expenses).
  - Simple list UI with icons indicating income vs expense.
  - Add new cash entries via a bottom sheet form.

- **Reports**
  - Person statement reports.
  - Cash flow reports.
  - CSV export for persons and transactions using the built-in CSV exporter.

- **Settings & Data Management**
  - Theme selection: System / Light / Dark.
  - Language selection: English (en) and Arabic (ar).
  - Currency selection (USD, EUR, SAR, EGP, AED).
  - Backup data to a JSON file and restore from JSON.
  - Export persons and transactions as CSV files.
  - About developer screen with contact links and GitHub repo.

## Architecture & Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod`
- **Routing**: `go_router` with a shell route and bottom navigation (`ScaffoldWithNavBar`).
- **Persistence**:
  - Isar database (`isar`, `isar_flutter_libs`) for persons and transactions.
  - `shared_preferences` and `path_provider` for preferences and file paths.
- **Localization**:
  - `flutter_localizations` and `intl`.
  - Localizations generated under `lib/l10n` (configured via `l10n.yaml`).
- **Other Packages**:
  - `file_picker` for selecting backup files.
  - `share_plus` for sharing backups and CSV exports.
  - `url_launcher` for opening external links.
  - `lucide_icons` for icons.

### Project Structure

- `lib/main.dart` – App entry point, wraps the app in `ProviderScope` and configures `MaterialApp.router`.
- `lib/config/` – Routing (`router.dart`) and theming (`theme.dart`).
- `lib/domain/` – Business entities and repository interfaces.
- `lib/data/` – Isar models, data sources, and repository implementations.
- `lib/presentation/` – Screens, widgets, and Riverpod providers for UI and state.
- `lib/utils/` – Utilities such as CSV export helpers.
- `lib/l10n/` – Localization files.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured.
- A supported IDE (VS Code, Android Studio, IntelliJ, etc.).
- For mobile builds, Android SDK / Xcode set up as usual.

### Setup

From a terminal on Windows:

```powershell
cd D:\Motaasl\Website\app-aldeewan\Aldeewan-Mobile
flutter pub get
```

### Run the App

Connect a device or start an emulator, then run:

```powershell
flutter run
```

### Run Static Analysis

To run Dart analysis and check for issues:

```powershell
dart analyze
```

(You can also run `flutter analyze` if desired.)

### Run Tests

If you add tests, run:

```powershell
flutter test
```

## Localization

Localizations are generated via `l10n.yaml` and ARB files under `lib/l10n`. To update localizations after editing ARB files, run:

```powershell
flutter gen-l10n
```

## Building for Release

Build a release APK for Android:

```powershell
flutter build apk --release
```

Build for iOS (on macOS with Xcode installed):

```bash
flutter build ios --release
```

## Changelog

See [`CHANGELOG.md`](./CHANGELOG.md) for a history of notable changes.
