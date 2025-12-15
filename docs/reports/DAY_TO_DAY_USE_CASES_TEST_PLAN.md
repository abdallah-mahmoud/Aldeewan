# Day-to-Day Use Cases Test Plan

**Date:** December 13, 2025
**Version:** 1.0
**Status:** Draft
**Target App:** Aldeewan Mobile (تطبيق الديوان)

## 1. Introduction
This document outlines a comprehensive "Day-to-Day" test plan designed to simulate real-world usage of the Aldeewan Mobile application. The goal is to verify that all features work harmoniously together as a user would experience them in their daily business operations.

## 2. Test Environment & Prerequisites
-   **Device:** Android/iOS Emulator or Physical Device.
-   **State:** Fresh Install (or Clear Data).
-   **Language:** Test in both English (LTR) and Arabic (RTL).
-   **Theme:** Test in both Light and Dark modes.

---

## 3. Detailed Use Cases

### 3.1. Onboarding & Initial Setup
**Scenario:** A new user installs the app for the first time.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **ONB-01** | **First Launch** | 1. Open the app.<br>2. Observe Splash Screen. | App launches quickly. Splash screen transitions to Home Screen (or Onboarding if applicable). |
| **ONB-02** | **Permissions** | 1. Navigate to a feature requiring permissions (e.g., Export PDF, Biometrics). | App requests necessary permissions gracefully. |
| **ONB-03** | **Default Data Seeding** | 1. Check Categories.<br>2. Check Currency settings. | Default categories (Housing, Food, etc.) are present. Default currency is set (e.g., SDG or USD). |

### 3.2. Dashboard (Home Screen)
**Scenario:** The user checks their financial health at the start of the day.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **DASH-01** | **Hero Card Display** | 1. View the top "Net Position" card. | Card stretches full width. Shows correct Net Balance (Receivables - Payables). |
| **DASH-02** | **Quick Actions** | 1. Tap "Add Transaction".<br>2. Tap "Add Person". | Buttons are responsive and navigate to the correct forms. |
| **DASH-03** | **Summary Grid** | 1. Observe "Cash in Hand", "Receivables", "Payables". | Values match the sum of underlying transactions. |
| **DASH-04** | **Date Filtering** | 1. Toggle between "All Time" and "This Month". | Dashboard stats update instantly to reflect the selected range. |

### 3.3. Ledger Management (Debts & Credits)
**Scenario:** Managing customer and supplier accounts.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **LED-01** | **Add New Customer** | 1. Go to Ledger/People tab.<br>2. Click FAB (+).<br>3. Enter Name: "Ahmed Market", Phone: "09123...", Type: Customer. | "Ahmed Market" appears in the list. Balance is 0. |
| **LED-02** | **Record Credit Sale** | 1. Open "Ahmed Market".<br>2. Click "Add Transaction".<br>3. Select "Credit Sale" (You gave goods).<br>4. Amount: 50,000.<br>5. Save. | Transaction appears in history. Ahmed's balance becomes **+50,000** (He owes you). Dashboard "Receivables" increases by 50,000. |
| **LED-03** | **Record Payment Received** | 1. Open "Ahmed Market".<br>2. Click "Add Transaction".<br>3. Select "Payment Received".<br>4. Amount: 20,000.<br>5. Save. | Ahmed's balance reduces to **+30,000**. Dashboard "Cash in Hand" increases by 20,000. |
| **LED-04** | **Add New Supplier** | 1. Add Person: "Wholesale Co", Type: Supplier. | "Wholesale Co" appears in list. |
| **LED-05** | **Record Credit Purchase** | 1. Open "Wholesale Co".<br>2. Select "Credit Purchase" (You took goods).<br>3. Amount: 100,000. | Wholesale Co balance becomes **-100,000** (You owe them). Dashboard "Payables" increases by 100,000. |
| **LED-06** | **Record Payment Made** | 1. Open "Wholesale Co".<br>2. Select "Payment Made".<br>3. Amount: 50,000. | Wholesale Co balance reduces to **-50,000**. Dashboard "Cash in Hand" decreases by 50,000. |

### 3.4. Cashbook (Daily Expenses & Income)
**Scenario:** Recording daily operational costs and miscellaneous income.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **CASH-01** | **Record Expense** | 1. Go to Cashbook.<br>2. Click "Add Expense".<br>3. Amount: 5,000.<br>4. Category: "Transportation".<br>5. Note: "Taxi". | Transaction saved. "Cash in Hand" decreases by 5,000. |
| **CASH-02** | **Record Income** | 1. Click "Add Income".<br>2. Amount: 10,000.<br>3. Category: "Income".<br>4. Note: "Side gig". | Transaction saved. "Cash in Hand" increases by 10,000. |
| **CASH-03** | **Filter by Category** | 1. Filter Cashbook list by "Transportation". | Only the Taxi transaction is shown. |

### 3.5. Budgets
**Scenario:** Setting limits to control spending.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **BUD-01** | **Create Budget** | 1. Go to Budgets.<br>2. Create new Budget.<br>3. Category: "Food".<br>4. Limit: 50,000.<br>5. Recurring: Yes. | Budget card appears. Progress bar is empty (0%). |
| **BUD-02** | **Track Spending** | 1. Go to Cashbook.<br>2. Add Expense: 10,000, Category: "Food".<br>3. Return to Budgets. | Budget card shows 10,000 / 50,000 spent (20%). |
| **BUD-03** | **Over Budget Warning** | 1. Add another Expense: 45,000, Category: "Food".<br>2. Return to Budgets. | Total spent: 55,000. Card shows red "Over Budget" warning. |
| **BUD-04** | **History Tab** | 1. Switch to "History" tab. | Shows past/archived budgets (should be empty initially). |

### 3.6. Savings Goals
**Scenario:** Saving for a specific target (e.g., New Equipment).

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **GOAL-01** | **Create Goal** | 1. Go to Goals.<br>2. Create Goal: "New Laptop".<br>3. Target: 200,000.<br>4. Deadline: Next Month. | Goal card appears. Progress 0%. |
| **GOAL-02** | **Add Funds (Success)** | 1. Tap "Add Funds".<br>2. Amount: 50,000.<br>3. Confirm. | Goal progress updates to 25%. A "Savings" expense transaction is created in Cashbook. "Cash in Hand" decreases. |
| **GOAL-03** | **Add Funds (Insufficient)** | 1. Try to add 1,000,000 (more than Cash in Hand). | Error message: "Insufficient funds". Transaction blocked. |
| **GOAL-04** | **Edit/Delete Goal** | 1. Edit goal name to "Gaming Laptop".<br>2. Delete goal. | Changes reflected. Deletion removes goal (verify if funds are returned or just goal removed - *Policy Check*). |

### 3.7. Reports & Analytics
**Scenario:** End-of-month reconciliation.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **REP-01** | **View Analytics** | 1. Go to Analytics tab.<br>2. View Expense Breakdown pie chart. | Chart correctly segments expenses (Food, Transportation, Savings). |
| **REP-02** | **Generate PDF** | 1. Go to Settings/Reports.<br>2. Generate "Account Statement" for "Ahmed Market". | PDF is generated containing all transactions for Ahmed. |
| **REP-03** | **Share Report** | 1. Click Share icon on PDF preview. | System share sheet opens (WhatsApp, Email, etc.). |

### 3.8. Settings & Customization
**Scenario:** Personalizing the app experience.

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| **SET-01** | **Dark Mode** | 1. Go to Settings.<br>2. Toggle "Dark Mode". | UI colors invert immediately. Text remains readable. |
| **SET-02** | **Language (RTL)** | 1. Change Language to Arabic. | UI flips to RTL. Text is in Arabic. "Ahmed Market" aligns right. |
| **SET-03** | **Security** | 1. Enable "Biometric Lock".<br>2. Close and reopen app. | App asks for Fingerprint/FaceID before showing data. |

## 4. Edge Cases & Stress Tests
-   **EC-01:** Entering emojis in name fields.
-   **EC-02:** Entering extremely large numbers (billions).
-   **EC-03:** Rapidly tapping "Save" button (prevent duplicate entries).
-   **EC-04:** Deleting a category that has active transactions (Should be blocked or handled safely).
-   **EC-05:** Changing system time (Time travel) - Verify how recurring budgets handle this.

## 5. Success Criteria
The app is considered "Release Ready" for the current phase if:
1.  All **Critical** (Crash/Data Loss) bugs are fixed.
2.  All Core Workflows (3.1 - 3.6) function as described.
3.  UI is consistent in both Light/Dark and LTR/RTL modes.
4.  `dart analyze` returns zero errors.
