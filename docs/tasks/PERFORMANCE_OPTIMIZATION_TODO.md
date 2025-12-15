# Performance Optimization Implementation Plan

Based on the [Performance Audit Report](PERFORMANCE_AUDIT_REPORT.md), this document tracks the implementation of performance improvements.

## Phase 1: Critical Algorithmic Fixes (High Priority)
**Goal:** Eliminate O(N*M) complexity on the main thread to prevent frame drops during data processing.

- [x] **Step 1.1: Optimize Balance Calculation**
    - Refactor `CalculateBalancesUseCase` to use a `Map<String, Person>` for O(1) lookups instead of `firstWhere`.
    - Target complexity reduction from O(N*M) to O(N).

## Phase 2: Background Processing (High Priority)
**Goal:** Offload heavy serialization and mapping tasks to background threads to keep the UI responsive.

- [x] **Step 2.1: Offload Data Mapping**
    - Modify `TransactionRepositoryImpl` to use `compute` (or `Isolate.run`) for mapping Realm models to Domain entities in `watchTransactions`.

## Phase 3: Widget Tree Optimization (Medium Priority)
**Goal:** Reduce unnecessary widget rebuilds and CPU usage during the render phase.

- [x] **Step 3.1: Scope HomeScreen Rebuilds**
    - Split `HomeScreen` into smaller, isolated widgets (e.g., `SummaryCards`, `RecentTransactions`).
    - Use `ref.watch(provider.select(...))` to ensure widgets only rebuild when their specific data changes.
- [x] **Step 3.2: Memoize Dashboard Calculations**
    - Move synchronous calculations (income/expense totals, filtering) out of the `HomeScreen` `build` method.
    - Implement derived providers or memoized getters in the Notifier to cache these values.

## Phase 4: Rendering Optimization (Low Priority)
**Goal:** Minimize rasterization costs for complex UI elements.

- [x] **Step 4.1: Add RepaintBoundaries**
    - Wrap complex list items (e.g., Account Cards in `HomeScreen`, Transaction items in `LedgerScreen`) with `RepaintBoundary` to isolate their painting layers.
