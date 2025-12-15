# Cashbook & UI Improvements Report

**Date:** December 13, 2025
**Status:** Draft
**Focus:** Cashbook, Transaction Details, Categories, and UI Robustness.

## 1. Issue Analysis

### 1.1. Cashbook Transaction Overflow
**Observation:** Users report overflow errors in the transaction list, specifically related to long notes.
**Current Implementation:**
-   The `CashbookScreen` uses a `ListTile`.
-   The `trailing` property contains a `Column` with the Amount and the Note.
-   The Note `Text` widget has `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
**Root Cause:**
-   Placing a `Column` inside `ListTile.trailing` is risky because `trailing` does not constrain its height, but the `ListTile` itself has a fixed height (unless `isThreeLine` is true, but even then).
-   If the font size increases or the content is too tall, it overflows vertically.
-   Also, `trailing` does not constrain width effectively against the `title`/`subtitle`, leading to potential horizontal overflows if the layout engine can't calculate the split.
**Recommendation:**
-   **Move Note to Subtitle:** The standard Material Design pattern is to put secondary text (like notes) in the `subtitle`.
-   **Keep Amount in Trailing:** The `trailing` slot should be reserved for the most important numerical value (Amount).
-   **Truncation:** Ensure the subtitle uses `maxLines: 1` or `2` with `TextOverflow.ellipsis`.

### 1.2. Missing Transaction Details
**Observation:** Users cannot view full details of a transaction, nor can they easily edit or delete specific entries from a detail view.
**Recommendation:**
-   **Create `TransactionDetailsScreen`:** A dedicated screen to view all fields (Amount, Date, Category, Full Note, Person).
-   **Actions:** Include "Edit" and "Delete" buttons.
-   **Navigation:** Tapping a list item in `CashbookScreen` should navigate to this details screen instead of doing nothing or expanding inline.

### 1.3. Category Localization
**Observation:** Category names (e.g., "Housing", "Food") are stored and displayed as hardcoded English strings.
**Recommendation:**
-   **Mapping Layer:** Create a utility function `getLocalizedCategory(String dbName, AppLocalizations l10n)`.
-   **Logic:** If the database name matches a known key (e.g., "Housing" -> `l10n.catHousing`), display the localized string. If not (custom category), display the database name as-is.
-   **ARB Update:** Add keys for all default categories to `app_en.arb` and `app_ar.arb`.

### 1.4. Category Filtering by Type
**Observation:** When adding an "Expense", the category selector shows "Income" categories, and vice versa.
**Recommendation:**
-   **Update `CategorySelector`:** Add a `type` parameter (e.g., `TransactionType` or `String`).
-   **Filter Logic:** Only display categories where `category.type` matches the transaction type (or "both" if applicable).

### 1.5. Category Management Access
**Observation:** Users can only manage categories while adding a transaction.
**Recommendation:**
-   **Settings Entry:** Add a "Categories" or "Manage Categories" item in the `SettingsScreen`.
-   **Dedicated Screen:** Create `CategoriesManagementScreen` (reusing the grid layout from `CategorySelector` but focused on management).

### 1.6. Text Overflow & UI Robustness
**Observation:** General risk of text overflow in titles, labels, and buttons, especially in Arabic (RTL) or with large text settings.
**Recommendation:**
-   **Audit:** Systematically check all `Text` widgets.
-   **Safe Widgets:** Use `Flexible` or `Expanded` inside Rows/Columns.
-   **MaxLines:** Enforce `maxLines` limits on list items.
-   **Scrollables:** Ensure forms are wrapped in `SingleChildScrollView`.

### 1.7. Enhanced Tracking & Visualization
**Observation:** 
-   Transactions in the list do not show their category, making it hard to identify spending at a glance.
-   Budgets and Goals show progress but lack a detailed history of contributing transactions.
**Recommendation:**
-   **Cashbook List:** Add a small category icon or text label to the transaction list item.
-   **Budget Drill-down:** Clicking a Budget card should open a `BudgetDetailsScreen` listing all transactions filtered by that budget's category and date range.
-   **Goal Drill-down:** Clicking a Goal card should open a `GoalDetailsScreen` listing all "Savings" transactions linked to that goal.

### 1.8. Goal Customization
**Observation:** Goals lack visual distinction. Users want more personalization.
**Recommendation:**
-   **Icons & Emojis:** Update the Goal Form to allow selecting from a preset list of icons (Lucide) or entering a custom Emoji.
-   **UI Integration:** Display this icon/emoji prominently on the Goal card and in the details screen.

### 1.9. UI Refinements
**Observation:** The Quick Action button "Add Cash Transaction" (Arabic: "اضافة معاملة نقدية") is too long and causes layout issues or looks cluttered.
**Recommendation:**
-   **Shorten Label:** Change to "Add Transaction" (Arabic: "اضافة معاملة").

---

## 2. Proposed Action Plan

### Phase 1: Cashbook UI Fixes
1.  Refactor `CashbookScreen` list item: Move Note to `subtitle`, Add Category indicator.
2.  Implement `TransactionDetailsScreen`.
3.  Wire up navigation from list item to details screen.

### Phase 2: Category Enhancements
1.  Add category keys to ARB files.
2.  Implement localization mapping helper.
3.  Update `CategorySelector` to support filtering by type.
4.  Update `CashEntryForm` to pass the current transaction type to the selector.

### Phase 3: Settings & Management
1.  Create `CategoriesManagementScreen`.
2.  Add entry point in `SettingsScreen`.

### Phase 4: Overflow Audit
1.  Review and fix overflow issues across the app.
2.  Shorten Quick Action labels.

### Phase 5: Budget & Goal Enhancements
1.  Implement `BudgetDetailsScreen` (Transaction List).
2.  Implement `GoalDetailsScreen` (Transaction List).
3.  Update `GoalForm` to support Icon/Emoji selection.
4.  Update `GoalCard` to display the new icon.

