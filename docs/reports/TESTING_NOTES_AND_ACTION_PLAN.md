# Testing Notes & Action Plan

**Date:** 2025-12-14
**Status:** Pending Review
**Scope:** Full App Polish & Feature Enhancements

## 1. Analysis & Recommendations

### A. Input Formatting & Validation
1.  **Goal Amount Input:**
    *   **Issue:** The goal amount input field lacks comma separation (e.g., "1,000" vs "1000"), inconsistent with other amount fields.
    *   **Recommendation:** Apply `ThousandsSeparatorInputFormatter` to the goal creation/update forms.
2.  **Phone Number Validation (Sudan/SDG):**
    *   **Issue:** Phone numbers need strict validation based on the selected currency/country context (specifically SDG).
    *   **Recommendation:** Implement a validation rule: If currency is SDG, phone must be 10 digits, start with '0'. Placeholder: "0912391234".

### B. Feature Enhancements (Edit & Actions)
3.  **Edit Goals & Budgets:**
    *   **Issue:** Users cannot edit existing goals or budgets (e.g., change target amount or limit).
    *   **Recommendation:** Add an "Edit" button to `GoalDetailsScreen` and `BudgetDetailsScreen`. Implement `updateGoal` and `updateBudget` methods in `BudgetNotifier`.
4.  **Edit Person Button:**
    *   **Issue:** The edit button in `PersonDetailsScreen` is non-functional.
    *   **Recommendation:** Wire the button to open `PersonForm` pre-filled with the person's data.
5.  **Home Screen Quick Actions:**
    *   **Issue:** Summary cards (Receivable, Payable, etc.) are static.
    *   **Recommendation:** Wrap cards in `InkWell`.
        *   "Receivable" -> Navigate to Ledger (Filter: Customers).
        *   "Payable" -> Navigate to Ledger (Filter: Suppliers).
        *   "Income/Expense" -> Navigate to Cashbook.

### C. Reporting & Visualization
6.  **Cash Flow Report (Expense Breakdown):**
    *   **Issue:** Expenses are currently aggregated.
    *   **Recommendation:** Add a Pie Chart or Stacked Bar Chart to `CashFlowReport` showing expenses broken down by category.
7.  **Budget Screen Pie Chart:**
    *   **Issue:** The current summary pie chart only shows "Total Spent vs Total Limit".
    *   **Recommendation:** Update the Pie Chart to show a breakdown of *all* active budget categories, using their specific category colors.
8.  **Person Statement Clarity:**
    *   **Issue:** The net balance is ambiguous.
    *   **Recommendation:** Add a prominent header in the report: "Net Position: You owe {name} {amount}" or "{name} owes you {amount}" (لك / عليك).

### D. Localization & Terminology
9.  **Category Localization:**
    *   **Issue:** Categories appear in English (DB value) in `BudgetDetails`, `TransactionDetails`, and `Cashbook`.
    *   **Recommendation:** Use `CategoryHelper.getLocalizedCategory` in all display widgets.
10. **Transaction Types Overhaul (Arabic):**
    *   **Issue:** Terms like "دخل" (Income) are confusing for debt transactions.
    *   **Recommendation:** Rename transaction types for clarity (Target Age 25-60):
        *   *Sale on Credit* -> "له" (Owed to us) / "بيع آجل".
        *   *Payment Received* -> "تسديد منه" (Payment from him).
        *   *Purchase on Credit* -> "لنا" (Owed by us) / "شراء آجل".
        *   *Payment Made* -> "تسديد له" (Payment to him).
    *   **Action:** Update `app_ar.arb` and `TransactionLabelMapper`.
11. **Transaction Details View:**
    *   **Issue:** The view doesn't clearly show the transaction type/direction.
    *   **Recommendation:** Redesign the header to clearly state "You gave" or "You received" with appropriate icons/colors.

### E. New Features (WhatsApp & Notifications)
12. **WhatsApp Integration:**
    *   **Requirement:** Add WhatsApp number field to Person. Add "Call" and "Message" buttons.
    *   **Plan:**
        *   Update `Person` entity (add `whatsappNumber`).
        *   Update `PersonForm`.
        *   Update `PersonDetailsScreen` with `url_launcher` actions (`https://wa.me/...`).
13. **Notifications System:**
    *   **Requirement:** Daily/Weekly reminders. Read/Unread status.
    *   **Plan:**
        *   Add `flutter_local_notifications` dependency.
        *   Create `NotificationService` to schedule local notifications.
        *   Create `NotificationsScreen` to list past notifications (requires local persistence or just showing system history). *Note: For MVP, we might just implement the scheduling and a simple list.*

### F. UI Layout & Overflow Issues
14. **Cashbook Summary Card Crowding:**
    *   **Issue:** The main card (Income | Expense | Net) becomes crowded/unreadable when amounts are long (e.g., millions).
    *   **Recommendation:**
        *   Use `FittedBox` or `AutoSizeText` to scale down font size for large numbers.
        *   Consider a vertical layout or scrollable row for smaller screens if scaling makes text too small.
15. **Goal Screen Overflow:**
    *   **Issue:** The main goal card overflows when the amount exceeds 6 digits.
    *   **Recommendation:** Wrap the amount text in `FittedBox` with `fit: BoxFit.scaleDown` to ensure it stays within bounds.

### G. Data Consistency & Logic
16. **Goal Savings in Cashbook:**
    *   **Issue:** Adding funds to a Savings Goal updates the goal but is not recorded as a transaction in the Cashbook. This creates a disconnect between "Cash on Hand" and "Savings".
    *   **Recommendation:** When adding funds to a goal, automatically create a `Transaction` (Type: `cashExpense`, Category: "Savings") to reflect the money leaving the main cash balance.
17. **Supplier Transactions in Cashbook:**
    *   **Issue:** "Purchase on Credit" (شراء آجل) transactions are not showing in the Cashbook.
    *   **Analysis:** Technically, a credit purchase is not a cash outflow, so it shouldn't be in the Cashbook (which tracks Cash Flow). However, users often view "Cashbook" as a general "Expense Log".
    *   **Recommendation:**
        *   **Short Term:** Ensure "Payment Made" (paying off the supplier) *does* appear in the Cashbook.
        *   **Long Term:** Add a filter toggle in Cashbook: "Show Credit Transactions" (visualized differently, perhaps faded) for users who want a total expense view.

### H. Simple Mode & Localization
18. **Simple Mode Localization:**
    *   **Issue:** When "Simple Mode" is active, some transaction types display in English (missing Arabic localization).
    *   **Recommendation:** Audit `TransactionLabelMapper`. Ensure all Simple Mode return values map to localized strings in `app_ar.arb`.
19. **Simple Mode Terminology Update:**
    *   **Issue:** The current terms need to be friendlier for the target age group (40-60).
    *   **Recommendation:** Align Simple Mode terms with the overhaul planned in Point 10. Use clear, colloquial terms (e.g., "عليه" instead of "Receivable", "له" instead of "Payable").

---

## 2. Action Task List

### Phase 1: Core Fixes & Validation
- [ ] **Goal Input:** Add `ThousandsSeparatorInputFormatter` to `GoalForm`.
- [ ] **Phone Validation:** Update `PersonForm` validator for SDG (10 digits, starts with 0).
- [ ] **Edit Person:** Implement `onPressed` in `PersonDetailsScreen` to open `PersonForm`.
- [ ] **Category Localization:** Apply `CategoryHelper` to `BudgetDetails`, `TransactionDetails`, `Cashbook`.
- [ ] **UI Overflow:** Apply `FittedBox`/`AutoSizeText` to Cashbook Summary and Goal Card.

### Phase 2: UI/UX & Terminology
- [ ] **Transaction Types:** Rename Arabic keys in `app_ar.arb` for clearer debt terminology.
- [ ] **Simple Mode:** Fix missing localizations and update terminology for older users.
- [ ] **Transaction Details:** Update UI to show clear "Direction" of money (You -> Them vs Them -> You).
- [ ] **Home Cards:** Add navigation logic to Summary Cards.
- [ ] **Person Report:** Add "Net Position" (لك/عليك) header text.

### Phase 3: Charts & Visuals
- [ ] **Budget Pie Chart:** Refactor `BudgetScreen` chart to show Category breakdown.
- [ ] **Cash Flow Chart:** Add Category breakdown to `CashFlowReport`.

### Phase 4: Data Logic & Features
- [ ] **Goal <-> Cashbook Sync:** Auto-create transactions when adding goal funds.
- [ ] **Edit Goals/Budgets:** Add Edit buttons and logic.
- [ ] **WhatsApp:** Add field to Person entity/form and buttons to Details screen.
- [ ] **Notifications:** Setup `flutter_local_notifications` and create Reminder Settings UI.

