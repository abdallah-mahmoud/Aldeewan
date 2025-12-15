# Code Quality & Maintainability Implementation Plan

Based on the [Code Quality Audit Report](CODE_QUALITY_AUDIT_REPORT.md), this document tracks the implementation of architectural improvements.

## Phase 1: Reactive Architecture (High Priority)
**Goal:** Eliminate manual data reloading and ensure UI updates automatically when data changes.

- [x] **Step 1.1: Update Data Source**
    - Modify `LocalDatabaseSource` to expose `Stream<List<Transaction>>` and `Stream<List<Person>>` (using Realm's `.changes` or `.asStream()`).
- [x] **Step 1.2: Update Repository Layer**
    - Update `TransactionRepository` interface and implementation to return Streams.
    - Update `PersonRepository` interface and implementation to return Streams.
- [x] **Step 1.3: Refactor Ledger Provider**
    - Convert `LedgerNotifier` to use `StreamProvider` or subscribe to repository streams.
    - Remove manual `loadData()` calls from mutation methods (`addTransaction`, etc.).

## Phase 2: Performance Optimization (High Priority)
**Goal:** Prevent UI jank by moving expensive O(N*M) calculations off the main thread or caching them.

- [x] **Step 2.1: Optimize Balance Calculations**
    - Implement a caching mechanism for person balances (e.g., using `Provider` families that only recompute when specific transaction lists change).
    - Alternatively, implement Realm aggregation queries if supported to fetch balances directly from the DB.
- [x] **Step 2.2: Optimize Dashboard Totals**
    - Create separate providers for `totalReceivablesProvider` and `totalPayablesProvider` to avoid recomputing the entire ledger state for simple dashboard numbers.

## Phase 3: Robustness & Error Handling (Medium Priority)
**Goal:** Ensure users are informed of errors and the app recovers gracefully.

- [x] **Step 3.1: Adopt AsyncValue**
    - Refactor `LedgerState` to use Riverpod's `AsyncValue` instead of manual `isLoading` booleans.
    - Update UI consumers to handle `loading`, `error`, and `data` states explicitly.
- [x] **Step 3.2: Error Propagation**
    - Ensure repository exceptions are propagated to the provider and caught by `AsyncValue.error`.

## Phase 4: Code Hygiene & Boilerplate Reduction (Medium Priority)
**Goal:** Reduce maintenance burden and improve type safety.

- [x] **Step 4.1: Install Freezed**
    - Add `freezed` and `json_serializable` to `dev_dependencies`.
- [x] **Step 4.2: Refactor State Models**
    - Convert `LedgerState` and other manual state classes to Freezed unions.
    - Run `build_runner` to generate code.

## Phase 5: Architectural Decoupling (Low Priority)
**Goal:** Improve testability by isolating business logic.

- [x] **Step 5.1: Create Use Cases**
    - Extract calculation logic into `GetPersonBalanceUseCase` and `GetTotalReceivablesUseCase`.
    - Ensure these use cases are unit testable without Flutter dependencies.
