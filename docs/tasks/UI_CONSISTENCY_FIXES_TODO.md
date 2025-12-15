# UI Consistency Fixes Task List

Based on `docs/audits/UI_CONSISTENCY_AUDIT_REPORT.md`.

## Phase 1: Standardization (Colors & Typography)
- [ ] **Define Colors:** Create `lib/config/app_colors.dart` with `success` (Mint), `error` (Rose), and other semantic colors.
- [ ] **Ledger Screen:**
    - [ ] Replace hardcoded `Colors.green`/`Colors.red` with `AppColors`.
    - [ ] Replace direct `TextStyle` with `Theme.of(context).textTheme`.
- [ ] **Cashbook Screen:**
    - [ ] Replace hardcoded `Colors.green`/`Colors.red` with `AppColors`.
    - [ ] Replace direct `TextStyle` with `Theme.of(context).textTheme`.
- [ ] **Analytics Screen:**
    - [ ] Replace hardcoded colors in `CashFlowReport` and `PersonStatementReport`.
    - [ ] Standardize typography.

## Phase 2: Component Polish
- [ ] **Ledger List Item:**
    - [ ] Replace `CircleAvatar` with a rounded square container (soft background).
    - [ ] Align styling with `CashbookScreen` list items.
- [ ] **Report Cards:**
    - [ ] Update `CashFlowReport` summary cards to use the flat, bordered style (like `CashbookScreen`).

## Phase 3: UX Overhaul (Reports & Tabs)
- [ ] **Report Filters (Analytics):**
    - [ ] Replace `DropdownButtonFormField` and `InputDecorator` with "Action Tiles" or "Filter Chips".
    - [ ] Create a reusable `FilterActionTile` widget.
- [ ] **Tabs:**
    - [ ] Style the `TabBar` in `LedgerScreen` and `AnalyticsScreen` to look more modern (e.g., pill indicators or segmented control style).

