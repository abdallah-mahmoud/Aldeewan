# Revamp & Feature Implementation Plan: Budget, Goals & Home Screen

## Overview
This plan outlines the steps to revamp the `Aldeewan-Mobile` app to align with an "Elegant Theme" personal finance tracker. The key objectives are to elevate the Budget and Goal tracking features, integrate them prominently into the Home Screen, and enhance the visual appeal of categories.

**Reference:** [Personal Finance Tracker (Elegant Theme)](https://spreadsheetshub.com/products/personal-finance-tracker-elegant-theme)

---

## 1. Data Layer Enhancements (Categories)

**Objective:** Support rich category data (icons, colors) for Budgets and Transactions.

*   [x] **Create `Category` Entity/Model:**
    *   Define a structure for Categories: `id`, `name`, `iconName` (string for Lucide icon), `colorHex` (string), `type` (income/expense).
    *   *Note:* Since `BudgetModel` currently uses a simple `String category`, we will create a `CategoryService` or `CategoryProvider` that maps these strings to rich objects.
*   [x] **Seed Default Categories:**
    *   Create a list of "Most Used" categories with elegant icons and colors.
    *   *Examples:*
        *   🏠 Housing (Blue/Indigo)
        *   🍔 Food & Dining (Orange)
        *   🚗 Transportation (Teal)
        *   💊 Health (Red)
        *   🎬 Entertainment (Purple)
        *   🛍️ Shopping (Pink)
        *   💡 Utilities (Yellow)
*   [x] **Update `BudgetModel` (Optional/Future):**
    *   Consider adding `icon` and `color` fields directly to `BudgetModel` if user customization per budget is required, similar to `SavingsGoalModel`.

## 2. UI Components & "Elegant" Theme

**Objective:** Create reusable widgets that match the "Elegant" aesthetic (clean, card-based, subtle shadows).

*   [x] **Create `ElegantDashboardButton`:**
    *   A large, visually appealing button/card for the Home Screen.
    *   **Props:** Title, Icon, Color/Gradient, OnTap.
    *   **Style:** Rounded corners (16-20px), subtle gradient background or glassmorphism effect, large icon.
*   [x] **Create `CategorySelector` Widget:**
    *   A modal or bottom sheet grid to select categories.
    *   Allows picking from presets.
    *   (Bonus) Allow changing the icon/color for a custom category.
*   [x] **Implement Charts (using `fl_chart`):**
    *   **Budget Radial Gauge:** A circular chart showing "Spent vs Limit" with a "Remaining" text in the center.
    *   **Goal Progress Bar:** A sleek linear progress indicator with "Target" and "Current" labels.
    *   **Spending Trend:** A simple line chart for the Budget details screen.

## 3. Home Screen Restructuring

**Objective:** Reorganize the Home Screen to prioritize Budgets and Goals.

*   [x] **Refactor `HomeScreen` Layout:**
    *   **Top Section:** Keep the "Net Position" / Hero Card (maybe refine its look to be more "Elegant").
    *   **Action Section (New):** Insert a Row with two large `ElegantDashboardButton`s:
        1.  **Budgets** (Icon: Pie Chart/Wallet)
        2.  **Goals** (Icon: Target/Trophy)
    *   **Middle Section:** "Recent Transactions" or "Cash Flow" summary.
    *   **Bottom Section:** Move "My Accounts" / "Link Bank" section here.
        *   Update the "Link Account" card to be less intrusive but still accessible.

## 4. Feature Screens: Budgets & Goals

**Objective:** Create dedicated, detailed screens for these features (moving out of Analytics tabs).

*   [x] **Create `BudgetScreen` (Dedicated):**
    *   **Header:** Total Monthly Budget vs Total Spent (Radial Chart).
    *   **List:** List of individual budgets.
        *   Each item shows: Category Icon, Name, Progress Bar, "Left to Spend" amount.
    *   **FAB:** "Create Budget" with the new `CategorySelector`.
*   [x] **Create `GoalsScreen` (Dedicated):**
    *   **Header:** Total Savings vs Total Target.
    *   **Grid/List:** Cards for each goal.
        *   Visual progress bar.
        *   "Add Money" quick button on the card.
*   [x] **Update Navigation:**
    *   Ensure the Home Screen buttons navigate to these new screens.
    *   (Optional) Keep them in Analytics as a summary, or remove them to reduce redundancy.

## 5. Implementation Tasks & Checklist

### Phase 1: Setup & Components
- [x] Create `lib/presentation/widgets/elegant_dashboard_button.dart`.
- [x] Create `lib/presentation/widgets/charts/budget_radial_chart.dart` (Implemented in BudgetScreen).
- [x] Create `lib/presentation/widgets/charts/goal_progress_bar.dart` (Implemented in GoalsScreen).
- [x] Define `CategoryProvider` with default data in `lib/presentation/providers/category_provider.dart`.

### Phase 2: Home Screen
- [x] Modify `lib/presentation/screens/home_screen.dart`.
- [x] Insert Budget/Goal buttons below the Hero Card.
- [x] Move "My Accounts" section to the bottom of the `SingleChildScrollView`.

### Phase 3: Budget & Goal Screens
- [x] Create `lib/presentation/screens/budget_screen.dart` (refactor from `BudgetList`).
- [x] Create `lib/presentation/screens/goals_screen.dart` (refactor from `GoalList`).
- [x] Integrate the new Charts into these screens.
- [x] Update `AnalyticsScreen` to remove the tabs (or keep them as read-only summaries).

### Phase 4: Category Revamp
- [x] Update `_showAddBudgetDialog` in `BudgetScreen` to use `CategorySelector`.
- [x] Update `CashEntryForm` to use `CategorySelector`.

## 6. Next Steps (Post-Revamp)
- [x] Add "Edit/Delete" functionality for Categories.
- [x] Add animations for charts.
- [x] Implement "Recurring Budgets" logic fully.

## 7. Conclusion
The "Elegant Theme" revamp is complete. The app now features a modern UI, rich category management, and robust budget/goal tracking.



## 6. Design References
*   **Colors:** Use the app's primary color (Teal/Green) for "Good/Income", Red/Orange for "Expense/Over Budget".
*   **Typography:** Clean, sans-serif (Cairo/Google Fonts).
*   **Spacing:** Generous padding (16px-24px) to avoid clutter.
