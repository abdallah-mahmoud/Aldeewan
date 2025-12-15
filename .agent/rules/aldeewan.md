---
trigger: always_on
---

---
applyTo: '**'
---
# Agent Instructions & Documentation Index

This file serves as a guide for AI agents and developers to navigate the project's documentation and task management.

## 📱 Project Overview: Aldeewan Mobile (تطبيق الديوان)

**Aldeewan Mobile** is a comprehensive smart accounting system for managing debts, expenses, and revenues. It is designed with modern technologies and a modern interface for a superior user experience.

### Key Features
1.  **Comprehensive Dashboard:** Instant view of financial position (Debts, Balance, Net Worth), interactive charts, and quick actions.
2.  **Ledger:** Manage customer/supplier accounts, record credit sales/purchases, and track transaction history.
3.  **Cashbook:** Record daily cash transactions (income/expenses) with categorization.
4.  **Reports & Export:** Detailed PDF/CSV reports and shareable statements.
5.  **Security & Privacy:** Local-First data storage, Biometric login, and data encryption.
6.  **Modern UI/UX:** Modern "Fintech" design, Dark/Light mode, and full RTL support (Arabic).

## 📂 Documentation Structure

The `docs/` folder is organized into the following categories:

### 📋 Tasks (`docs/tasks/`)
Active task lists and TODOs.
- [TODO.md](docs/tasks/TODO.md): Main implementation task list.
- [CODE_QUALITY_TODO.md](docs/tasks/CODE_QUALITY_TODO.md): Tasks related to code quality improvements.
- [PERFORMANCE_OPTIMIZATION_TODO.md](docs/tasks/PERFORMANCE_OPTIMIZATION_TODO.md): Tasks for performance optimization.

### 📝 Plans (`docs/plans/`)
Design documents, revamp strategies, and feature roadmaps.
- [APP_DESIGN_REVAMP_PLAN.md](docs/plans/APP_DESIGN_REVAMP_PLAN.md)
- [APP_DESIGN_REVAMP_V2.md](docs/plans/APP_DESIGN_REVAMP_V2.md)
- [APP_DESIGN_REVAMP_V3.md](docs/plans/APP_DESIGN_REVAMP_V3.md)
- [FEATURES_PLAN_V1.2.md](docs/plans/FEATURES_PLAN_V1.2.md)
- [REALM_MIGRATION_PLAN.md](docs/plans/REALM_MIGRATION_PLAN.md)
- [REVAMP_PLAN.md](docs/plans/REVAMP_PLAN.md)
- [TEST_NOTES_AND_PLAN.md](docs/plans/TEST_NOTES_AND_PLAN.md)
- [UI_POLISH_PLAN.md](docs/plans/UI_POLISH_PLAN.md)

### 📊 Reports (`docs/reports/`)
Status reports, handover documents, and completion summaries.
- [APP_REVAMP_HANDOVER.md](docs/reports/APP_REVAMP_HANDOVER.md)
- [APP_REVAMP_HANDOVER_UPDATED.md](docs/reports/APP_REVAMP_HANDOVER_UPDATED.md)
- [APP_STATUS_REPORT.md](docs/reports/APP_STATUS_REPORT.md)
- [APP_STATUS_REPORT_UPDATED.md](docs/reports/APP_STATUS_REPORT_UPDATED.md)
- [FINAL_AUDIT_STATUS.md](docs/reports/FINAL_AUDIT_STATUS.md)
- [PHASE_1_2_PERFORMANCE_REPORT.md](docs/reports/PHASE_1_2_PERFORMANCE_REPORT.md)
- [PHASE_3_COMPLETION_REPORT.md](docs/reports/PHASE_3_COMPLETION_REPORT.md)
- [PHASE_4_COMPLETION_REPORT.md](docs/reports/PHASE_4_COMPLETION_REPORT.md)
- [PHASE_5_COMPLETION_REPORT.md](docs/reports/PHASE_5_COMPLETION_REPORT.md)
- [PERFORMANCE_OPTIMIZATION_COMPLETION_REPORT.md](docs/reports/PERFORMANCE_OPTIMIZATION_COMPLETION_REPORT.md)
- [USER_FEEDBACK_ANALYSIS_V3.md](docs/reports/USER_FEEDBACK_ANALYSIS_V3.md)

### 🔍 Audits (`docs/audits/`)
Audit reports for code quality, performance, and UI/UX.
- [CODE_QUALITY_AUDIT_REPORT.md](docs/audits/CODE_QUALITY_AUDIT_REPORT.md)
- [PERFORMANCE_AUDIT_REPORT.md](docs/audits/PERFORMANCE_AUDIT_REPORT.md)
- [UI_UX_AUDIT_REPORT.md](docs/audits/UI_UX_AUDIT_REPORT.md)

## 🏗️ App Architecture

The application follows **Clean Architecture** principles combined with **Riverpod** for state management.

### Layers
1.  **Presentation Layer (`lib/presentation/`)**:
    - **Screens & Widgets:** UI components.
    - **Providers:** Riverpod providers (Notifiers) that manage state and interact with UseCases.
    - **Pattern:** Reactive UI that listens to providers.
2.  **Domain Layer (`lib/domain/`)**:
    - **Entities:** Pure Dart objects representing business data (e.g., `Transaction`, `Person`).
    - **Repositories (Interfaces):** Abstract classes defining data operations.
    - **UseCases:** Encapsulate specific business logic (e.g., `CalculateBalancesUseCase`).
3.  **Data Layer (`lib/data/`)**:
    - **Models:** Database-specific models (Realm objects).
    - **Repositories (Implementation):** Concrete implementations of domain repositories.
    - **Data Sources:** Local database (Realm) access.
    - **Mappers:** Convert between Data Models and Domain Entities.

### State Management
- **Riverpod:** Used for dependency injection and state management.
- **Reactive Streams:** The app prefers listening to database streams rather than manual fetching.
- **AsyncValue:** Used to handle loading and error states explicitly.

## ⚡ Performance Instructions

To ensure a smooth user experience (60 FPS), adhere to the following guidelines:

1.  **Avoid Main Thread Blocking:**
    - **Heavy Calculations:** Move O(N*M) operations (like balance calculations) to background Isolates or optimize them to O(N) or O(1).
    - **Data Mapping:** Use `compute()` for mapping large lists of database models to domain entities.
2.  **Widget Optimization:**
    - **Scope Rebuilds:** Use `ref.watch(provider.select(...))` to listen only to specific data changes.
    - **Split Widgets:** Break large screens (like `HomeScreen`) into smaller, `const` widgets.
    - **RepaintBoundaries:** Wrap complex list items (shadows, gradients) in `RepaintBoundary`.
3.  **Memory Management:**
    - **Const Constructors:** Use `const` wherever possible to reduce GC pressure.
    - **Image Caching:** Ensure images and icons are cached efficiently.

## 🧹 Clean Code & Code Quality

1.  **SOLID Principles:** Adhere to Single Responsibility, Open/Closed, etc.
2.  **Naming Conventions:**
    - Files: `snake_case.dart`
    - Classes: `PascalCase`
    - Variables/Methods: `camelCase`
3.  **Error Handling:**
    - **Never Swallow Errors:** Do not use empty `catch` blocks.
    - **User-Friendly Messages:** Map technical exceptions to localized, user-friendly messages.
    - **AsyncValue:** Use `AsyncValue` to propagate error states to the UI.
4.  **Testing:**
    - Write unit tests for UseCases and Repositories.
    - Write widget tests for complex UI components.

## 🎨 UI/UX Design Guidelines

**Theme:** "Modern Fintech" (Elegant, Clean, Trustworthy).

1.  **Colors:**
    - **Primary:** Royal Indigo (`#4338ca`)
    - **Secondary:** Vibrant Mint (`#10b981`)
    - **Background:** Pale Slate (`#f8fafc`)
    - **Surface:** Pure White (`#ffffff`)
2.  **Typography:**
    - **Font:** Cairo (for Arabic support).
    - **Hierarchy:** Use `Theme.of(context).textTheme` for consistency.
    - **Readability:** Ensure high contrast and adequate line height.
3.  **Components:**
    - **Cards:** Rounded corners (16-20px), soft shadows.
    - **Buttons:** Large touch targets (min 48px height).
    - **Icons:** Use Lucide icons for a modern, consistent look.
4.  **Accessibility:**
    - **Text Scaling:** Ensure layouts adapt to large font sizes.
    - **Semantics:** Add semantic labels to charts and non-text elements.
    - **Contrast:** Maintain AA contrast ratio for text.

## 🌍 Localization Instructions

1.  **Always Localize:** Never use hardcoded strings in the UI. Always use `AppLocalizations.of(context)`.
2.  **Update ARB Files:** When adding new text, update both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
3.  **Naming Keys:** Use descriptive camelCase keys (e.g., `transactionDetailsTitle`, `saveButtonLabel`).
4.  **Generation:** The project is configured to generate localization files automatically. If needed, run `flutter gen-l10n`.

## 🔒 Security Instructions

1.  **Local-First:** Data is stored locally on the device using Realm.
2.  **Biometrics:** Support biometric authentication (Fingerprint/Face ID) for app access.
3.  **Data Encryption:**
    - Encrypt sensitive data at rest if possible.
    - Ensure backups are handled securely.
4.  **Input Validation:** Validate all user inputs to prevent data corruption.

## 🚀 Getting Started for Agents
1.  **Check Active Tasks:** Always start by checking `docs/tasks/TODO.md` to understand the current priorities and active tasks.
2.  **Consult Plans:** Before implementing new features or major refactors, refer to the relevant documents in `docs/plans/` to ensure alignment with the architectural vision.
3.  **Update Documentation:** When completing major milestones or changing the system structure, update the relevant reports in `docs/reports/` or create new ones.
4.  **Follow Coding Standards:** Adhere to the project's coding standards (Clean Architecture, Riverpod, etc.) as implied by the existing codebase and audit reports.

## 🏁 Handover & Continuation Notes (Dec 2025)

**Last Agent Context:**
- All static analysis issues resolved (as of Dec 14, 2025).
- APK size optimization plan created in `docs/plans/APK_OPTIMIZATION_PLAN.md`.
- Audio and animation assets are present and integrated.
- GoRouter assertion error was being debugged; last fix was to move navigator keys to global scope and remove redundant parentNavigatorKey assignments.
- If GoRouter error persists, review all uses of `parentNavigatorKey` and ensure subroutes do not set a parentNavigatorKey that does not match their immediate parent.
- All recent work is documented in `docs/tasks/FIX_PLAN_V1.md` and `docs/plans/APK_OPTIMIZATION_PLAN.md`.

**Next Steps for New Agent:**
1. If GoRouter error persists, review `lib/config/router.dart` for any remaining parentNavigatorKey issues (see last error screenshot for context).
2. Check `docs/tasks/FIX_PLAN_V1.md` for completed and pending tasks.
3. Use `flutter build apk --release` for real APK size testing.
4. Continue with any new tasks as per user direction.

**User expects seamless handover and context continuity.**