# Test Feedback Report & Action Plan (V1)

**Date:** December 14, 2025
**Version:** 1.1.0
**Status:** Draft

## 1. Critical Issues (High Priority)

### 1.1. Hero Balance is 0
**Observation:** The "Net Position" card on the Home Screen shows 0, even with data.
**Root Cause Analysis:**
- The `HeroSection` widget uses `totalReceivableProvider` and `totalPayableProvider`.
- These providers rely on `getTotalReceivablesUseCase` and `getTotalPayablesUseCase`.
- **Hypothesis:** The `LedgerProvider` might be returning an empty state initially, or the calculation logic in the UseCases is flawed (e.g., filtering out valid transactions).
- **Action:** Debug `LedgerProvider` state and UseCase logic. Ensure `ref.watch` is triggering updates correctly.

### 1.2. Deleting Transaction -> Black Screen
**Observation:** Deleting a transaction causes the screen to go black and hang.
**Root Cause Analysis:**
- Likely an issue with `Navigator.pop` being called multiple times or in a way that conflicts with the widget lifecycle.
- If `TransactionDetailsScreen` is opened via `GoRouter` (push), popping it should work.
- **Hypothesis:** The `deleteTransaction` method in the notifier might be async and causing a rebuild of the details screen *before* it pops, leading to a crash if the transaction no longer exists in the list.
- **Action:** Ensure navigation happens *before* the state update or handle the "transaction not found" case gracefully in the `build` method of `TransactionDetailsScreen`.

### 1.3. Arabic Terminology Conflicts
**Observation:**
- Two "دخل" (Income) types.
- Two "دفعة" (Payment) types.
- Mismatch between Form dropdown and List view.
**Root Cause Analysis:**
- `app_ar.arb` maps multiple keys to the same string.
- `TransactionLabelMapper` uses these ambiguous keys.
**Resolution (Approved Mapping):**
The following mapping has been approved to resolve ambiguity and distinguish between Trade Credit and Pure Debt.

| Category | Enum Value | English Label | Arabic Label | Usage Note |
| :--- | :--- | :--- | :--- | :--- |
| **Ledger (Trade)** | `saleOnCredit` | **Sale (Credit)** | **بيع (آجل)** | Selling items/services expecting payment later. |
| | `purchaseOnCredit` | **Purchase (Credit)** | **شراء (آجل)** | Buying items/services expecting to pay later. |
| **Ledger (Debt)** | **`debtGiven`** *(New)* | **Debt (Owed by)** | **دين (عليه)** | Lending money to someone (Pure debt). |
| | **`debtTaken`** *(New)* | **Debt (Owed to)** | **دين (له)** | Borrowing money from someone (Pure debt). |
| **Ledger (Payment)** | `paymentReceived` | **Payment Received** | **استلام دفعة** | Receiving money (settles sales or debts). |
| | `paymentMade` | **Payment Made** | **دفع دفعة** | Paying money (settles purchases or debts). |
| **Cashbook** | `cashSale` | **Cash** | **نقد** | Cash inflow (Physical Cash). |
| | `cashIncome` | **Bank** | **بنك** | Bank inflow (Transfer/Digital). |
| | `cashExpense` | **Expense** | **صرف** | Any money outflow for expenses. |

**Action:**
- Update `TransactionType` enum in `domain/entities/transaction.dart`.
- Update `app_en.arb` and `app_ar.arb` with new keys.
- Update `TransactionLabelMapper`.
- **Update Logic:** Ensure `debtGiven` behaves like `saleOnCredit` (Receivable) and `debtTaken` behaves like `purchaseOnCredit` (Payable) in all calculations and reports.

### 1.4. Goal Tracker Not Updating on Delete
**Observation:** Deleting a transaction linked to a goal does not update the goal's progress.
**Root Cause Analysis:**
- The `GoalProvider` likely listens to `TransactionRepository` for *adds* but might miss *deletes*, or the dependency graph isn't set up to re-calculate goal progress when the transaction list changes.
- **Action:** Ensure `GoalProvider` watches the `LedgerProvider` (or transaction stream) and recalculates progress whenever transactions change.

## 2. Functional Issues (Medium Priority)

### 2.1. Daily Notification Not Working
**Observation:** No notifications received outside the app.
**Root Cause Analysis:**
- `flutter_local_notifications` might not be initialized correctly for background/scheduled tasks.
- Android 13+ requires explicit notification permission request.
- **Action:** Verify initialization code in `main.dart` and permission request logic.

### 2.2. Ledger Transactions Missing from Cashbook
**Observation:** Not all ledger transactions appear in Cashbook.
**Root Cause Analysis:**
- By design, only *cash* transactions (Cash Sale, Cash Expense, Payment Received, Payment Made) should appear in Cashbook. Credit transactions (Sale on Credit) are non-cash.
- **Action:** Clarify requirements. If the user expects *all* transactions, explain the accounting logic. If they expect *payments* to appear and they aren't, fix the filter in `CashbookProvider`.

### 2.3. Missing Transaction Details for Ledger
**Observation:** Tapping a transaction in the Ledger list doesn't open a details screen.
**Root Cause Analysis:**
- `PersonDetailsScreen` likely uses a `ListTile` without an `onTap` handler.
- **Action:** Add `onTap` to navigate to `TransactionDetailsScreen`.

### 2.4. Budget Categories in English
**Observation:** Categories show as "Housing" instead of "السكن" in some views.
**Root Cause Analysis:**
- The category *name* is stored as a string (e.g., "Housing").
- The UI displays this raw string instead of mapping it back to a localized key.
- **Action:** Create a `CategoryLocalizationHelper` to map stored English keys to `AppLocalizations` getters.

## 3. UX & Polish (Low Priority)

### 3.1. Sound Effects
**Observation:**
- Click sound is annoying.
- Cashbook success sound needs to be distinct.
**Action:**
- Replace `click_soft.mp3` with `screen-tap.mp3`.
- Add `register-cha-ching.mp3` and use it in `CashEntryForm`.

### 3.2. Settings Screen Info
**Observation:** Version is wrong (1.1.0) and Developer name typo ("متصل" -> "متآصل").
**Action:** Update `app_ar.arb` and `pubspec.yaml`.

### 3.3. Animated Empty States
**Observation:** Old static icons are still used.
**Action:** Replace `Icon` widgets in `EmptyState` with `Lottie.asset`.

---

# Action Plan (Fix Plan V1)

## Step 1: Fix Critical Crashes & Logic (High)
1.  **Fix Hero Balance:** Debug `LedgerProvider` and `HeroSection`.
2.  **Fix Delete Crash:** Refactor `TransactionDetailsScreen` delete logic to pop safely.
3.  **Fix Goal Updates:** Ensure `GoalProvider` reacts to transaction deletions.

## Step 2: Fix Localization & Terminology (High)
4.  **Update ARB Files:** distinct keys for all transaction types.
5.  **Update Mapper:** Fix `TransactionLabelMapper` to use new keys.
6.  **Fix Category Names:** Implement localization mapping for budget categories.
7.  **Update Settings:** Fix version and developer name.

## Step 3: Fix Notifications & Features (Medium)
8.  **Fix Notifications:** Check permissions and scheduling logic.
9.  **Ledger Details:** Add navigation to transaction details from Ledger.
10. **Cashbook Filter:** Verify which transactions should appear and fix filter.

## Step 4: UX Polish (Low)
11. **Update Sounds:** Replace audio files and update `SoundService`.
12. **Add Lottie:** Implement animated empty states.

