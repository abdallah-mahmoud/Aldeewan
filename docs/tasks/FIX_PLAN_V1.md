# Fix Plan V1

## Phase 1: Critical Logic & Stability
- [x] **Fix Hero Balance (0 issue):** Investigate `LedgerProvider` and `HeroSection`.
- [x] **Fix Delete Transaction Crash:** Ensure safe navigation before state update in `TransactionDetailsScreen`.
- [x] **Fix Goal Tracker Update:** Ensure `GoalProvider` recalculates on transaction delete.

## Phase 2: Localization & Terminology
- [x] **Implement New Transaction Types:**
    - Add `debtGiven` and `debtTaken` to `TransactionType` enum.
    - Update `TransactionLabelMapper` with new mapping.
    - Update `app_en.arb` and `app_ar.arb` with new keys.
- [x] **Update Business Logic:**
    - Ensure `debtGiven` increases Receivable (like Sale).
    - Ensure `debtTaken` increases Payable (like Purchase).
    - Update `CalculateBalancesUseCase` and `LedgerProvider`.
    - Update Analytics/Reports to include new types.
- [x] **Fix Budget Category Localization:** Map stored English names to localized strings in UI.
- [x] **Update Settings Info:** Version 1.1.0, Developer "متآصل".

## Phase 3: Features & Notifications
- [x] **Fix Daily Notifications:** Verify permissions and scheduling.
- [x] **Add Ledger Transaction Details:** Enable tapping on transactions in Person Details.
- [x] **Verify Cashbook Filter:** Ensure payments appear in Cashbook.

## Phase 4: UX Polish & Assets
- [x] **Update Sounds:**
    - Replace `click_soft.mp3` with `screen-tap-38717.mp3` (Code updated, assets pending).
    - Add `register-cha-ching-376896.mp3` for Cashbook success (Code updated, assets pending).
- [x] **Animated Empty States:** Replace static icons with Lottie animations (Code updated, assets created).
