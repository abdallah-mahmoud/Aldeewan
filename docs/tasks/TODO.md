# Implementation Task List - UI/UX Audit Fixes

## 1. Error Handling Sanitization (High Priority)
- [x] Create `lib/utils/error_handler.dart` with user-friendly error mapping.
- [x] Update `LinkAccountScreen` to use `ErrorHandler`.
- [x] Update `SettingsScreen` to use `ErrorHandler`.
- [x] Update `AnalyticsScreen` to use `ErrorHandler`.

## 2. Smart Report Defaults (High Priority)
- [x] Update `CashFlowReport` to default to current month and auto-generate.
- [x] Update `PersonStatementReport` to default to current month and auto-generate.

## 3. Actionable Empty States (Quick Win)
- [x] Update `EmptyState` widget to accept `actionLabel` and `onAction` callback.
- [x] Update `BudgetScreen` to provide "Create Budget" action in empty state.
- [x] Update `GoalsScreen` to provide "Create Goal" action in empty state.

## 4. Chart Accessibility (Medium Priority)
- [x] Add `Semantics` wrapper to `IncomeExpenseBarChart`.
- [x] Add `Semantics` wrapper to charts in `BudgetScreen`.
- [x] Add `Semantics` wrapper to charts in `GoalsScreen`.

## 5. Terminology Simplification (Medium Priority)
- [x] Create/Update `SettingsProvider` to support `isSimpleMode`.
- [x] Create `TransactionLabelMapper` utility.
- [x] Update `TransactionForm` to use dynamic labels.
- [x] Update `PersonStatementReport` to use dynamic labels.
