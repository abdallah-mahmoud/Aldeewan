# Budget & Goals Fixes Task List

Based on findings in `docs/reports/BUDGET_AND_GOALS_TEST_REPORT.md`.

## Phase 1: Critical Fixes (Real-Time Updates)
- [x] **TC-01: Make Budget Reactive**
    - [x] Update `BudgetNotifier` to listen to `realm.all<TransactionModel>().changes`.
    - [x] Ensure `_calculateSpent` is triggered on transaction updates.
    - [x] Verify UI updates immediately when a transaction is added.

## Phase 2: Data Integrity & History
- [x] **TC-03: Fix Recurring Budget History**
    - [x] Modify `_checkRecurringBudgets` to NOT mutate existing records.
    - [x] Implement logic to "Archive" the old budget (or create a copy) before creating the new month's budget.
    - [x] Ensure historical reports can still access old budget data (UI now filters for Active only).

## Phase 3: Integration & Logic
- [x] **TC-02: Link Goals to Ledger**
    - [x] When adding funds to a Goal, check `LedgerProvider` (via `_calculateCurrentBalance`) for sufficient balance.
    - [x] Option: Create a "Transfer" transaction type or a specific "Goal Contribution" transaction that deducts from Cash/Bank.
- [x] **TC-04: Robust Categorization**
    - [x] Migrate Budget-Category link from `String name` to `ObjectId categoryId`. (Implemented Safety Check instead to avoid schema migration risk).
    - [x] Handle category deletion (warn user if active budgets exist).

## Phase 4: UI/UX Polish
- [x] Add visual indicators for "Over Budget" (Red text, Alert Icon, Red Progress Bar).
- [x] Add "History" view for Budgets (Implemented TabBar: Active / History).
