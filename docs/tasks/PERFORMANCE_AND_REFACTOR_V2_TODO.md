# Performance & Refactoring Task List (V2)

Based on `docs/audits/CODE_QUALITY_AND_PERFORMANCE_AUDIT_REPORT_V2.md`.

## Phase 1: Critical Performance Optimizations (Isolates)
- [x] **Offload Balance Calculation:**
    - [x] Modify `CalculateBalancesUseCase` or `LedgerNotifier` to run calculations in a background isolate using `compute()`.
    - [x] Ensure the calculation function is static or top-level to be compatible with `compute`.
- [x] **Optimize Report Generation:**
    - [x] Refactor `PersonStatementReport._generateReport` to use `compute()`.
    - [x] Extract report generation logic into a pure, static function.

## Phase 2: Architectural Refactoring
- [x] **Cashbook Provider:**
    - [x] Create `lib/presentation/providers/cashbook_provider.dart`.
    - [x] Move filtering and summary logic from `CashbookScreen` to this provider.
    - [x] Update `CashbookScreen` to watch the new provider.
- [x] **LedgerNotifier Refactor:**
    - [x] Refactor `LedgerNotifier` to use `StreamProvider` or improve stream subscription management.
    - [x] Ensure `_updateState` handles async balance calculation correctly.

## Phase 3: Minor Polish
- [x] **Memoization:**
    - [x] Review `ref.watch` usage in `LedgerScreen` and `CashbookScreen`.
    - [x] Implement `select` where appropriate to reduce rebuilds.
    - [x] Upgraded `cashbookProvider` to use `compute` for background calculation.
