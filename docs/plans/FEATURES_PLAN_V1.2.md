# Aldeewan v1.2 Feature Plan: Budgeting & Multi-Account Management

This document outlines the technical and design plan for introducing **Budget Planning** and **Multi-Account Management** (Bank/Wallets) to the Aldeewan app.

## 🎯 Feature 1: Smart Budgeting & Goals (التخطيط المالي والأهداف)

### 1.1 Overview
Enable users to set spending limits for specific categories (e.g., Food, Transport) and track savings goals (e.g., "Buy a Car"). Visualized with rich charts.

### 1.2 Data Modeling (Isar Schema)
We need two new entities and an update to the existing `Transaction` logic.

**New Entity: `Budget`**
```dart
@collection
class Budget {
  Id id = Isar.autoIncrement;
  late String category; // e.g., "Food"
  late double amountLimit; // e.g., 50,000 SDG
  late double currentSpent; // Calculated field or cached
  late DateTime startDate;
  late DateTime endDate;
  bool isRecurring = true; // Auto-renew monthly?
}
```

**New Entity: `SavingsGoal`**
```dart
@collection
class SavingsGoal {
  Id id = Isar.autoIncrement;
  late String name; // e.g., "Emergency Fund"
  late double targetAmount;
  late double currentSaved;
  DateTime? deadline;
  String? icon;
  String? colorHex;
}
```

### 1.3 UI/UX Design
*   **Analytics Tab (New Main Tab):**
    *   **Pie Chart:** Visual breakdown of expenses by category (using `fl_chart`).
    *   **Budget Progress:** Linear progress bars showing "Spent vs Limit" for each category. Color changes from Green -> Yellow -> Red as the limit approaches.
*   **Goals Section:**
    *   Cards showing savings progress with a circular indicator.
    *   "Add to Goal" button to allocate spare cash to a goal.

### 1.4 Technical Implementation
*   **Library:** Add `fl_chart` for rendering Pie and Bar charts.
*   **Logic:**
    *   When a `Transaction` (Expense) is added, find the active `Budget` for that category and update its state.
    *   Create a `BudgetProvider` to calculate totals dynamically.

---

## 💳 Feature 2: Automated Bank & Wallet Integration (الربط البنكي الآلي)

### 2.1 Overview
Seamlessly connect the app to external financial institutions (Banks & E-Wallets) to automatically fetch balances and transactions.
*   **Supported Providers:** Bank of Khartoum (Mbok), Syber, Fawry, etc.
*   **Automation:** Transactions are fetched via API, categorized automatically, and reflected in the app without manual entry.

### 2.2 Data Modeling (Isar Schema)

**New Entity: `FinancialAccount`**
```dart
@collection
class FinancialAccount {
  Id id = Isar.autoIncrement;
  late String name; // e.g., "Mbok Account"
  late String providerId; // e.g., "MBOK", "SYBER"
  late String accountType; // "BANK", "WALLET"
  late double balance;
  late String currency;
  
  // API Integration Fields
  String? externalAccountId; // ID from the bank's system
  DateTime? lastSyncTime;
  String? status; // "ACTIVE", "ERROR", "NEEDS_REAUTH"
}
```

**Update Entity: `Transaction`**
*   `String? externalId`: Unique ID from the bank API to prevent duplicates.
*   `String? status`: "PENDING", "POSTED".
*   `int? accountId`: Link to the `FinancialAccount`.

### 2.3 UI/UX Design
*   **Link Account Flow:**
    *   "Connect Bank" button -> Select Provider List.
    *   Secure Login / API Key Input Screen.
    *   Success/Syncing Animation.
*   **Wallet Screen:**
    *   Cards showing live balances (fetched from API).
    *   "Pull to Refresh" to trigger immediate sync.
*   **Transaction List:**
    *   Visual indicator (e.g., Bank Icon) for auto-imported transactions.

### 2.4 Technical Implementation
*   **Security:** Use `flutter_secure_storage` to store API Tokens/Keys. **NEVER** store credentials in plain text or Isar.
*   **Networking:** Use `Dio` for robust HTTP requests with interceptors for token refreshing.
*   **Architecture:**
    *   **`BankProviderInterface`:** Abstract class defining methods like `getBalance()`, `fetchTransactions(startDate)`.
    *   **`MbokProvider`, `SyberProvider`:** Concrete implementations connecting to specific APIs.
    *   **`SyncService`:** Background service (using `workmanager` or similar) to fetch updates periodically.

---

## 🔒 Feature 3: Security & Privacy (الأمان والخصوصية)

### 3.1 Overview
Given the sensitive nature of financial data, we will implement a multi-layered security architecture to protect user data at rest, in transit, and during usage.

### 3.2 Data Encryption (At Rest)
*   **Database Encryption:**
    *   Use Isar's built-in **AES-256 encryption**.
    *   Generate a random encryption key on first launch, store it securely in the device's Keystore/Keychain (using `flutter_secure_storage`), and use it to open the Isar instance.
    *   *Benefit:* Even if the device is rooted or the file is extracted, the database cannot be read without the key.
*   **Credential Storage:**
    *   Bank API Tokens, Passwords, and Refresh Tokens will **NEVER** be stored in the database.
    *   Use `flutter_secure_storage` (Android Keystore / iOS Keychain) for all sensitive strings.

### 3.3 App Access Control (Biometrics & PIN)
*   **Biometric Login:**
    *   Integrate `local_auth` to support Fingerprint and FaceID.
    *   Prompt for authentication immediately upon app launch and after a timeout (e.g., 5 minutes of inactivity).
*   **PIN Fallback:**
    *   Allow users to set a 4-6 digit PIN as a backup if biometrics fail or are unavailable.
*   **Privacy Screen:**
    *   Blur the app screen when it goes into the background (App Switcher view) to prevent shoulder surfing.

### 3.4 Network Security (In Transit)
*   **HTTPS/TLS:** Enforce strict HTTPS for all API connections.
*   **Certificate Pinning:** (Optional for V1.2, Recommended for V2) Pin the server's SSL certificate to prevent Man-in-the-Middle (MitM) attacks.

---

## 📅 Implementation Roadmap

### Phase 1: Infrastructure & Security (Week 1)
1.  [ ] Add `fl_chart`, `dio`, `flutter_secure_storage`, `local_auth`.
2.  [ ] **Implement Database Encryption:** Generate key & init Isar with encryption.
3.  [ ] **Implement Biometric Auth:** Create `AuthService` and Login Screen.
4.  [ ] Create `FinancialAccount`, `Budget`, and `SavingsGoal` Isar collections.
5.  [ ] Implement `BankProviderInterface` structure.

### Phase 2: API Integration (Week 2)
1.  [ ] Implement **Mock API Provider** (for testing).
2.  [ ] Implement real **Bank APIs** (Mbok/Syber) integration.
3.  [ ] Build **Link Account UI** and Secure Storage logic.
4.  [ ] Implement `SyncService` to fetch and merge transactions.

### Phase 3: Budgeting & Charts (Week 3)
1.  [ ] Implement `BudgetRepository` (connected to auto-fetched data).
2.  [ ] Build **Analytics Screen** with Pie Charts.
3.  [ ] Build **Budget Creation** UI.

### Phase 4: Goals & Polish (Week 4)
1.  [ ] Build **Savings Goals** UI.
2.  [ ] Add "New Transaction Detected" notifications.
3.  [ ] **Privacy Screen:** Implement app switcher blurring.
4.  [ ] Final testing and localization (Arabic).
