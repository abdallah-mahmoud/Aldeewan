# Budget & Goals Feature - Test Report & Analysis

**Date:** December 13, 2025
**Version:** 1.0
**Status:** Analysis Complete

## 1. Executive Summary
The **Budget** and **Goal Tracker** features provide essential financial planning tools. However, a static analysis of the codebase reveals significant integration gaps that affect the "Day-to-Day" user experience. The primary issue is the lack of real-time synchronization between the Transaction Ledger and the Budget Tracker. Additionally, the Goal Tracker operates in isolation from the user's actual cash balance, allowing for "virtual savings" that may not reflect reality.

## 2. Test Scenarios & Findings

### TC-01: Real-Time Budget Tracking
**Scenario:** User creates a budget for "Food" and immediately adds a "Food" expense in the Cashbook.
**Expected Behavior:** The "Spent" amount in the Budget screen updates immediately to reflect the new expense.
**Actual Behavior (Code Analysis):**
-   **Failure:** The `BudgetNotifier` calculates spent amounts only when `loadBudgets()` is called (on app start or screen init).
-   **Cause:** `BudgetNotifier` does not listen to the stream of `TransactionModel` changes in the Realm database.
-   **Impact:** Users will not see their budget progress update after adding a transaction until they restart the app or force a reload.

### TC-02: Goal Contribution vs. Cash Reality
**Scenario:** User has 0 Cash/Bank balance but adds 5,000 to a "New Laptop" goal.
**Expected Behavior:** The app should either prevent this (insufficient funds) or record a transaction (transfer to savings).
**Actual Behavior (Code Analysis):**
-   **Observation:** The "Add to Goal" feature simply increments a counter on the `SavingsGoalModel`. It does not check `LedgerProvider` for available funds, nor does it create a transaction record.
-   **Impact:** Users can have "Fully Funded" goals in the tracker while having negative actual cash flow, leading to a false sense of financial security.

### TC-03: Recurring Budget History
**Scenario:** A monthly budget for "Rent" ends on Jan 31st. User opens the app on Feb 1st.
**Expected Behavior:** The Jan budget is saved to history, and a new Feb budget is created.
**Actual Behavior (Code Analysis):**
-   **Observation:** The `_checkRecurringBudgets` function **mutates** the existing `BudgetModel`. It updates the `startDate` and `endDate` to the current month.
-   **Impact:** Historical budget performance is lost. The user cannot look back to see if they adhered to their budget in previous months.

### TC-04: Category Consistency
**Scenario:** User deletes a Category that has an active Budget.
**Expected Behavior:** The app should warn the user or cascade the delete/archive.
**Actual Behavior (Code Analysis):**
-   **Observation:** Budgets rely on a simple String match (`category` field). If a Category is deleted from `CategoryProvider`, the Budget remains active but becomes an "Orphan" (no new transactions can be easily tagged with that category).
-   **Impact:** "Zombie Budgets" that persist but are difficult to utilize.

## 3. Recommendations

### Immediate Fixes (Critical)
1.  **Make Budget Reactive:**
    -   Update `BudgetNotifier` to listen to `realm.all<TransactionModel>().changes`.
    -   Trigger `_calculateSpent` whenever a transaction is added, updated, or deleted.
    -   *Estimated Effort:* Low (Riverpod refactor).

### Strategic Improvements (High Value)
2.  **Link Goals to Ledger:**
    -   When adding to a goal, prompt to create a "Transfer" transaction (e.g., from "Cash" to "Savings Goal").
    -   Or, simply validate that `Total Cash > Total Goal Savings`.
3.  **Budget History:**
    -   Instead of mutating the date, clone the budget for the new month and mark the old one as `archived` or keep it in a `history` collection.
4.  **Robust Categorization:**
    -   Use `CategoryId` (UUID) instead of String names for linking Budgets to Transactions. This allows renaming categories without breaking links.

## 4. Conclusion
The current implementation serves as a functional "MVP" (Minimum Viable Product) but requires the **Reactive Fix (TC-01)** to be viable for daily use. Without it, the user feedback loop is broken.
