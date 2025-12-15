# Cashbook & UI Improvements Task List

## Phase 1: Cashbook UI Fixes
- [x] **Refactor List Item:** In `CashbookScreen`, move the transaction note from the `trailing` Column to the `subtitle` Row. Ensure it uses `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
- [x] **Create Details Screen:** Create `lib/presentation/screens/transaction_details_screen.dart`.
    - [x] Display Amount (Hero animation?), Date, Category, Person, and Full Note.
    - [x] Add "Edit" button (opens `CashEntryForm` with data).
    - [x] Add "Delete" button (shows confirmation dialog).
- [x] **Navigation:** Update `CashbookScreen` `onTap` to push `TransactionDetailsScreen`.
- [x] **Show Category:** In `CashbookScreen` list item, display the category name/icon (e.g., next to the date or as a leading icon if not already present).

## Phase 2: Category Enhancements
- [x] **Localization Keys:** Add the following keys to `app_en.arb` and `app_ar.arb`:
    - `catHousing`, `catFood`, `catTransportation`, `catHealth`, `catEntertainment`, `catShopping`, `catUtilities`, `catIncome`, `catOther`.
- [x] **Localization Helper:** Create `String getLocalizedCategory(String dbName, AppLocalizations l10n)` in `utils/category_helper.dart`.
- [x] **Update Selector:** Modify `CategorySelector` widget:
    - [x] Accept `TransactionType? filterType`.
    - [x] Filter the displayed list based on the type.
    - [x] Use the localization helper to display names.
- [x] **Update Form:** In `CashEntryForm`, pass the selected `_type` to `CategorySelector`.

## Phase 3: Settings & Management
- [x] **Management Screen:** Create `lib/presentation/screens/categories_management_screen.dart`.
    - [x] List all categories.
    - [x] Allow adding new custom categories.
    - [x] Allow deleting custom categories.
- [x] **Settings Link:** Add "Manage Categories" tile to `SettingsScreen`.

## Phase 4: Overflow Audit
- [x] **Review:** Check `Home`, `Ledger`, and `Budget` screens for similar overflow risks (e.g., long names in list tiles).
- [x] **Fix:** Apply `Expanded`/`Flexible` and `TextOverflow` constraints where missing.
- [x] **Shorten Labels:** Update `app_en.arb` and `app_ar.arb` to change "Add Cash Transaction" to "Add Transaction" (and Arabic equivalent).

## Phase 5: Budget & Goal Enhancements
- [x] **Budget Details:** Create `lib/presentation/screens/budget_details_screen.dart`.
    - [x] Receive `BudgetModel`.
    - [x] Query transactions matching budget category and date range.
    - [x] Display list of transactions with dates and amounts.
- [x] **Budget Navigation:** Update `BudgetScreen` to navigate to `BudgetDetailsScreen` when a budget card is tapped.
- [x] **Goal Details:** Create `lib/presentation/screens/goal_details_screen.dart`.
    - [x] Receive `SavingsGoalModel`.
    - [x] Query transactions with `category == 'Savings'` and `note` containing goal name (or add a `goalId` to transaction model for better linking).
    - [x] Display list of contributions.
- [x] **Goal Navigation:** Update `GoalsScreen` to navigate to `GoalDetailsScreen` when a goal card is tapped.
- [x] **Goal Icons:** Update `GoalForm` and `SavingsGoalModel`.
    - [x] Add `icon` field to `SavingsGoalModel` (store string name or emoji char).
    - [x] Add Icon Picker in `GoalForm` (Presets + Emoji support).
    - [x] Update `GoalCard` to show the icon.
