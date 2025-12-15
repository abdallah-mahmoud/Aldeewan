# UI Polish & Refinement Plan

This document outlines the plan to refine the app's UI/UX, focusing on icons, currency display, and visual styling.

## 🎨 Task 1: UI Icon Refresh
**Goal:** Update in-app icons (Navigation, Actions, Categories) to match the new lively design style.

### Steps:
1.  **Navigation Bar:**
    *   Update `BottomNavBar` to use a more distinct style for the selected state (e.g., filled icons or a pill indicator).
2.  **Action Icons:**
    *   Review icons in `HomeScreen` (Notification bell, Dashboard).
    *   Ensure they have consistent styling (e.g., rounded backgrounds).
3.  **Category/Section Icons:**
    *   Add colorful container backgrounds to icons in lists (e.g., Budget categories, Settings menu) to match the "lively" theme.

## 💰 Task 2: Dynamic Currency Display
**Goal:** Ensure all money inputs and displays use the selected currency (e.g., SDG, USD) instead of hardcoded symbols.

### Steps:
1.  **Audit Codebase:**
    *   Search for hardcoded `$` or other symbols in `lib/`.
    *   Identify `TextField`s with hardcoded prefixes/suffixes.
2.  **Implementation:**
    *   **`BudgetScreen`:** Update budget cards and goal cards to use `ref.watch(currencyProvider)`.
    *   **`LinkAccountScreen`:** Ensure balance display uses the provider (if applicable).
    *   **`HomeScreen`:** Verify `HeroBalanceCard` and Account cards use the provider.
    *   **`AddTransactionScreen` / Dialogs:** Update input fields to show the dynamic currency symbol as a prefix/suffix.
3.  **Testing:** Switch currency in Settings and verify all screens update.

## ✨ Task 3: Lively Cards (Visual Polish)
**Goal:** Enhance the visual appeal of cards with gradients and colors.

### Steps:
1.  **Define Styles:**
    *   Create a `AppGradients` class in `lib/config/theme.dart` (or similar).
    *   Define gradients for:
        *   **Primary Card:** (e.g., Blue -> Purple) for Total Balance.
        *   **Account Cards:** (e.g., Teal -> Green, Orange -> Red) based on account type or random assignment.
        *   **Budget Cards:** Gradient progress bars.
2.  **Update Widgets:**
    *   **`HeroBalanceCard`:** Apply a rich gradient background. Add subtle pattern/noise if possible (optional).
    *   **`HomeScreen` (Account List):** Give each account card a distinct gradient or color.
    *   **`BudgetScreen`:**
        *   Update Budget Cards to have a cleaner look, possibly with a colored left border or header.
        *   Make Progress Bars more vibrant.
    *   **`SummaryStatCard`:** Add subtle background color or icon accents.

## 📝 Execution Checklist
- [ ] Run `flutter_launcher_icons`.
- [ ] Replace hardcoded `$` in `BudgetScreen`.
- [ ] Replace hardcoded `$` in `LinkAccountScreen` (if any).
- [ ] Update `TextField` prefixes in Dialogs.
- [ ] Create `AppGradients` class.
- [ ] Apply Gradients to `HeroBalanceCard`.
- [ ] Apply Gradients to Account Cards.
- [ ] Polish Budget & Goal Cards.
