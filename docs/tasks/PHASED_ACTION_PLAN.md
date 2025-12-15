# Phased Action Plan

**Status:** In Progress
**Source:** `docs/reports/TESTING_NOTES_AND_ACTION_PLAN.md`

## Phase 1: Core Fixes & Validation
- [x] **Goal Input:** Add `ThousandsSeparatorInputFormatter` to Goal creation/edit inputs.
- [x] **Phone Validation:** Update `PersonForm` validator for SDG (10 digits, starts with 0).
- [x] **Edit Person:** Implement `onPressed` in `PersonDetailsScreen` to open `PersonForm`.
- [x] **Category Localization:** Apply `CategoryHelper` to `BudgetDetails`, `TransactionDetails`, `Cashbook`.
- [x] **UI Overflow:** Apply `FittedBox` to Cashbook Summary and Goal Card.

## Phase 2: UI/UX & Terminology
- [x] **Transaction Types:** Rename Arabic keys in `app_ar.arb` for clearer debt terminology.
- [x] **Simple Mode:** Fix missing localizations and update terminology for older users.
- [x] **Transaction Details:** Update UI to show clear "Direction" of money (You -> Them vs Them -> You).
- [x] **Home Cards:** Add navigation logic to Summary Cards.
- [x] **Person Report:** Add "Net Position" (لك/عليك) header text.

## Phase 3: Charts & Visuals
- [x] **Budget Pie Chart:** Refactor `BudgetScreen` chart to show Category breakdown.
- [x] **Cash Flow Chart:** Add Category breakdown to `CashFlowReport`.

## Phase 4: Data Logic & Features
- [x] **Goal <-> Cashbook Sync:** Auto-create transactions when adding goal funds.
- [x] **Edit Goals/Budgets:** Add Edit buttons and logic.
- [x] **WhatsApp:** Add field to Person entity/form and buttons to Details screen.
- [x] **Notifications:** Setup `flutter_local_notifications` and create Reminder Settings UI.
