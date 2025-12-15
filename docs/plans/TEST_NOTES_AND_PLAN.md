# Test Notes and Remediation Plan

## 1. Localization Issues
**Issue:** "My Accounts" section title is not translated.
**Note:** Add a "Coming Soon" label/indicator as bank linking is not yet implemented.
**Issue:** Budget and Goals screens are completely untranslated.
**Issue:** General review needed for many untranslated texts throughout the app.

**Status:** Fixed.
- [x] Add "My Accounts" to `app_en.arb` and `app_ar.arb`.
- [x] Add "Coming Soon" (قريباً) badge to the Accounts section header.
- [x] Extract all hardcoded strings in `BudgetScreen` and `SavingsGoal` widgets to ARB files.
- [x] Perform a sweep of the app to identify and externalize remaining hardcoded strings (App Lock, Bank Linking, Errors).

## 2. Currency Formatting (SDG)
**Issue:** Sudanese Pound (SDG) does not need decimal places (fractions are unused).

**Status:** Fixed.
- [x] Update `CurrencyProvider` or the currency formatting logic to check if the currency is SDG and set `decimalDigits` to 0.

## 3. UI Layout - Summary Cards
**Issue:** The 4 summary cards (Total Receivables, Payables, Monthly Income, etc.) are too large. There is too much whitespace between the label and the value.
**Requirement:** Make them compact and responsive across different screens.

**Status:** Fixed.
- [x] Refactor `SummaryStatCard` (or the grid implementation in `HomeScreen`) to reduce vertical padding.
- [x] Adjust aspect ratio or fixed height constraints to be more compact.

## 4. Quick Actions - Empty State Handling
**Issue:** When selecting "Add Debt" or "Pay Installment" from Quick Actions, if no persons are registered, a white screen appears (likely a crash or unhandled empty state).
**Requirement:** Show a dedicated empty state view with a button to redirect to "Add Person" screen (do not auto-redirect).

**Status:** Fixed.
- [x] In `TransactionFormScreen`, check if the person list is empty.
- [x] If empty, render an `EmptyState` widget explaining that a person is needed for the transaction, with a button to navigate to the Add Person screen.

## 5. Ledger - Button Styling
**Issue:** The "Add Person" button in the middle of the Ledger/Supplier screen has dark text which clashes with the app theme (should be white).

**Status:** Fixed.
- [x] Locate the `ElevatedButton` or `FilledButton` in the empty state of the Ledger screen.
- [x] Force text color to white or use `foregroundColor: Colors.white`.

## 6. Input Field Formatting
**Issue:** When entering large numbers (e.g., with many zeros), it is difficult to distinguish the number of zeros.
**Requirement:** Add thousands separators while typing.

**Status:** Fixed.
- [x] Implement a `ThousandsSeparatorInputFormatter` (or use a library like `pattern_formatter` or `currency_text_input_formatter`).
- [x] Apply this formatter to all amount input fields in the app.

## 7. Missing Reports Screen & Budget/Goals Location
**Issue:** The old Reports screen has disappeared completely. Budget and Goals screens were also missing from navigation.

**Status:** Fixed.
- Restored "Analytics" tab in Bottom Navigation.
- Created a unified `AnalyticsScreen` containing 4 tabs:
    1. Person Statement
    2. Cash Flow
    3. Budgets
    4. Goals
- Extracted Budget and Goal lists into reusable widgets.
- Added missing localization keys for Budgets and Goals.
- **Cleanup:** Renamed `reports_screen.dart` to `analytics_screen.dart` and removed unused `budget_screen.dart`.

## 8. App Lock / Biometrics
**Issue:** App Lock feature is not enabled/working with the system.

**Status:** Fixed.
- [x] Verify `AndroidManifest.xml` has the `USE_BIOMETRIC` permission.
- [x] Check `MainActivity.kt` (if needed) for `FragmentActivity` inheritance (required for `local_auth` on Android).
- [x] Ensure the `SecurityProvider` logic correctly persists the state and `PrivacyBlur` listens to it.
- [x] Implemented `AuthService` integration in `MyApp` to trigger authentication on app resume and cold start.
- [x] Enhanced `PrivacyBlur` to act as a functional Lock Screen with an "Unlock" button.

---

## Execution Order
1. **Critical Fixes:** Quick Actions Crash, Missing Reports Screen.
2. **UI/UX Polish:** Summary Cards, Input Formatting, Button Styling.
3. **Localization:** Translation of all missing screens and "My Accounts".
4. **Feature Refinement:** SDG Currency decimals, App Lock permissions.
