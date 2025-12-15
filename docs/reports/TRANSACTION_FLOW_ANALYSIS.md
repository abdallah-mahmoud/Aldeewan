# Transaction Flow & Logic Analysis

## Overview
This document details the flow of `TransactionType` values in the application, their localized labels, and their effects on the Cashbook (Income/Expense) and Person Balances (Ledger).

## Transaction Logic Table

| Transaction Type | English Label | Arabic Label | Cashbook Effect | Person Balance Effect |
| :--- | :--- | :--- | :--- | :--- |
| **saleOnCredit** | Sale on Credit | بيع آجل | **None** | **Customer:** Increase (User Asset) <br> **Supplier:** N/A (Logic handles Customer role primarily) |
| **paymentReceived** | Payment Received | استلام دفعة | **Income** | **Customer:** Decrease (Counts as paying off debt) <br> **Supplier:** Decrease (Counts as Supplier paying back advance) |
| **purchaseOnCredit** | Purchase on Credit | شراء آجل | **None** | **Supplier:** Increase (User Liability/Debt) <br> **Customer:** N/A |
| **paymentMade** | Payment Made | دفع دفعة | **Expense** | **Supplier:** Decrease (Counts as User paying off debt) <br> **Customer:** Decrease (Counts as User paying back advance) |
| **debtGiven** | Debt Given | دَين معطى (أعطيت) | **Expense** (Cash Out) | **Customer:** Increase (Adds to amount they owe you) <br> **Supplier:** Decrease (Reduces amount you owe them - technically unusual but handled) |
| **debtTaken** | Debt Taken | دَين مأخوذ (استلفت) | **Income** (Cash In) | **Supplier:** Increase (Adds to amount you owe them) <br> **Customer:** Decrease (Reduces amount they owe you) |
| **cashSale** | Cash Sale | بيع نقدي | **Income** | **None** (Does not affect Ledger Balance) |
| **cashIncome** | Income (Bank/Other) | دخل (بنك/آخر) | **Income** | **None** (Does not affect Ledger Balance) |
| **cashExpense** | Expense | مصروف | **Expense** | **None** (Does not affect Ledger Balance) |

## Refined Transaction Filtering (Impl. V1.2)
To reduce confusion, the "Add Transaction" screen now strictly filters types based on the selected person's role:

### For Customers
*   **Default:** Sale on Credit
*   **Allowed:** `saleOnCredit`, `paymentReceived`, `debtGiven` (Lend), `debtTaken`, `paymentMade` (Refund).
*   **Hidden:** `purchaseOnCredit`, `cashIncome`, `cashExpense`.

### For Suppliers
*   **Default:** Purchase on Credit
*   **Allowed:** `purchaseOnCredit`, `paymentMade`, `debtTaken` (Borrow), `debtGiven`, `paymentReceived` (Refund).
*   **Hidden:** `saleOnCredit`, `cashIncome`, `cashExpense`.

## Detailed Balance Calculation Logic

### Customer Role
*   **Asset (+):** The customer owes YOU money.
*   **Liability (-):** You owe the customer money (Advance).

**Formula:**
`Balance = (saleOnCredit + debtGiven) - (paymentReceived + debtTaken) + paymentMade (if refund)`
*   `saleOnCredit`: You sold goods, they owe you. (+)
*   `debtGiven`: You lent them cash, they owe you. (+)
*   `paymentReceived`: They paid you, debt reduces. (-)
*   `debtTaken`: You borrowed from them, debt reduces (or becomes negative). (-)
*   `paymentMade`: You paid them (e.g. returning an advance). (+) -> **Reduces Liability (Negative Balance -> 0)**

### Supplier Role
*   **Liability (+):** You owe the SUPPLIER money.
*   **Asset (-):** The supplier owes you money (Advance).

**Formula:**
`Balance = (purchaseOnCredit + debtTaken) - (paymentMade + debtGiven) + paymentReceived (if refund)`
*   `purchaseOnCredit`: You bought goods, you owe them. (+)
*   `debtTaken`: You borrowed cash from them, you owe them. (+)
*   `paymentMade`: You paid them, debt reduces. (-)
*   `debtGiven`: You lent them cash (or returned goods for credit), debt reduces. (-)
*   `paymentReceived`: They paid you (e.g. returning an advance). (+) -> **Reduces Asset (Negative Balance -> 0)**

## Reporting Impact
*   **Cashbook Report:** Includes `debtGiven` (Expense), `debtTaken` (Income), `cashSale` (Income), `cashIncome` (Income), `cashExpense` (Expense), `paymentReceived` (Income), `paymentMade` (Expense).
*   **Ledger Report / Statement:** Includes all transactions capable of affecting the Person Balance.
    *   *Note:* `cashSale` and `cashExpense` are linked to the user's wallet, not a specific person's account, and thus do not appear in Person Statements.
