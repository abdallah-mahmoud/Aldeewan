# Architecture Improvement Plan

Based on the [Architecture Audit Report](../audits/ARCHITECTURE_AUDIT_REPORT.md), this document outlines the tasks required to improve the application's stability, maintainability, and test coverage.

## Phase 1: Dependency Hygiene (Immediate)
**Goal:** Clean up the project configuration and remove obsolete dependencies to ensure a stable build environment.

- [x] **Step 1.1: Remove Discontinued Dev Dependencies**
    - Remove `build_resolvers` from `pubspec.yaml`.
    - Remove `build_runner_core` from `pubspec.yaml`.
    - Remove `js` from `pubspec.yaml`.
    - Run `flutter pub get` and verify build.
- [x] **Step 1.2: Upgrade Linter**
    - Upgrade `flutter_lints` to the latest version (v6.0.0).
    - Run `dart fix --apply` to address any new lint rules.
    - Run `flutter analyze` and fix remaining issues.

## Phase 2: Testing Infrastructure (High Priority)
**Goal:** Establish a safety net for the application logic to prevent regressions during future updates.

- [x] **Step 2.1: Setup Test Environment**
    - Add `mockito` or `mocktail` to `dev_dependencies`.
    - Create `test/domain/usecases` directory.
    - Create `test/data/repositories` directory.
- [x] **Step 2.2: Unit Test Use Cases**
    - Write tests for `CalculateBalancesUseCase`.
    - Write tests for `GetTotalReceivablesUseCase`.
    - Write tests for `GetTotalPayablesUseCase`.
- [x] **Step 2.3: Unit Test Repositories**
    - Create a mock `LocalDatabaseSource`.
    - Write tests for `TransactionRepositoryImpl` (verifying mapping logic and stream emissions).

## Phase 3: Major Upgrades (Strategic)
**Goal:** Modernize the entire technology stack. **Order is critical:** Flutter first, then packages.

- [x] **Step 3.1: Upgrade Flutter SDK**
    - Run `flutter upgrade` in your terminal to get the latest stable version (3.38.5).
    - Update `pubspec.yaml` environment constraint: `sdk: '>=3.10.0 <4.0.0'`.
    - Run `flutter pub get`.
    - Fix any immediate breaking changes in the UI code (deprecations).
- [x] **Step 3.2: Upgrade Realm (v3.5.0 -> v20.2.0)**
    - **Risk:** High (Breaking changes in API and binary compatibility).
    - Read Realm migration guide.
    - Update `realm` dependency.
    - Update `realm_generator`.
    - Run `dart run build_runner build --delete-conflicting-outputs`.
    - Fix compilation errors in `LocalDatabaseSource` and Models.
    - Verify data persistence and migration.
- [x] **Step 3.3: Upgrade Riverpod (v2.6.1 -> v3.0.3)**
    - **Status:** Skipped / Deferred.
    - **Reason:** Riverpod 3.0 removes `StateNotifier` which is used extensively. Upgrading requires a full rewrite of all providers to `Notifier`. Decided to stick with v2.6.1 for stability.
- [x] **Step 3.4: Upgrade GoRouter (v13.2.5 -> v17.0.1)**
    - **Risk:** High (Routing API changes).
    - Update `go_router`.
    - Fix breaking changes in route definitions and navigation calls.
    - Verify all navigation flows (Deep linking, redirection, params).

## Phase 4: Widget Testing (Long Term)
**Goal:** Ensure critical UI flows work as expected.

- [x] **Step 4.1: Test Critical Screens**
    - Write widget test for `CashEntryForm` (Validation logic).
    - Write widget test for `HomeScreen` (Dashboard rendering).
