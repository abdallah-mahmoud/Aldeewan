# Aldeewan Mobile – UI/UX Design Revamp Plan

Date: 2025-12-10

## 1. Goals

- Create a **modern, delightful fintech-style UI** inspired by:
  - Dribbble fintech/budget app concepts
  - Figma community finance/budget trackers and UI kits
- Make the app **interactive and engaging**, so users enjoy using it and don’t get bored.
- Keep the experience **simple, guided, and informative** for all user levels.
- Preserve and enhance current functionality (ledger, cashbook, reports, settings, backup).

---

## 2. Design Language & Visual System

### 2.1 Colors

Use your existing brand colors as a base (from `lib/config/theme.dart`), and extend them:

- **Primary (Brand)**
  - Light: `#14B8A6` (Teal 500)
  - Dark: `#5EEAD4` (Teal 300)
- **Supporting Colors**
  - Success: soft green for positive balances, income.
  - Danger: `#EF4444` for errors/negative balances (already `_brandRed`).
  - Info/Accent: soft blue or purple for non-critical highlights.
- **Backgrounds**
  - Light mode: `_lightBackground` (`#F9FAFB`) with white cards.
  - Dark mode: `_darkBackground` (`#13131F`) and `_darkSurface` (`#20202F`).
- **Gradients** (for hero cards, primary CTAs)
  - Example 1: Teal → Emerald
  - Example 2: Teal → Blue

**Action item:** In Figma, define a color style set: `Primary/Light`, `Primary/Dark`, `Success`, `Danger`, `Background/Light`, `Background/Dark`, `Card/Light`, `Card/Dark`, `Accent/Blue`, etc.

### 2.2 Typography

- Base font: `Inter` (already configured in `AppTheme`).
- Define a simple type scale:
  - H1: 24–28, bold (e.g. dashboard headings, main amounts).
  - H2: 20–22, semibold (section titles like "Cashbook").
  - Subtitle: 14–16, medium (supporting captions under titles).
  - Body 1: 14–16, regular (primary content text).
  - Body 2: 12–14, regular (secondary or subtle text).

**Action item:** Establish `TextTheme` styles in Figma and then reflect them in `AppTheme`.

### 2.3 Components & Layout

- **Cards**
  - Rounded corners (12–16 px), soft shadows in light mode, subtle borders in dark mode.
  - Use for:
    - Summary metrics (receivable, payable, income, expenses).
    - Person list items.
    - Transaction rows.
- **Chips & Pills**
  - For filters (time range, type filters, roles).
  - Contain labels like: `Today`, `This week`, `This month`, `Custom`.
- **Buttons**
  - Primary: filled, gradient or solid primary color, rounded corners.
  - Secondary: outlined or ghost, used for less critical actions.
- **Icons**
  - Use `lucide_icons` consistently for a modern, thin-line appearance.

### 2.4 Motion & Micro-interactions

- Page transitions (via `go_router`) with subtle slide/fade.
- Button interactions: scale or ripple.
- Card hover/press: tiny elevation increase (light mode) or bright border (dark mode).
- Feedback:
  - Snackbars with icons and color-coded backgrounds for success/warning/error.

#### 2.4.1 Global Animations & Loading

- **App launch / splash animation**
  - Display the Aldeewan logo with a short (≈1–1.5s) animation on cold start:
    - Logo fades in and gently scales up.
    - Optional radial or gradient background reveal behind the logo.
  - Under the logo, show a short status text (e.g., "Preparing your workspace…") to reassure users during startup.
  - Implementation concept: a dedicated `SplashScreen` that runs minimal initialization and then transitions into the main `ScaffoldWithNavBar` with a fade/slide animation.

- **Global loading overlay**
  - For rare, long-running operations (e.g., full data restore or large exports), show a semi-transparent overlay:
    - Centered animated icon or minimal loader.
    - Short explanatory text ("Restoring data…", "Exporting report…").
  - Keep it visually consistent with the splash (reuse colors and iconography).

- **Content loading patterns**
  - Replace generic full-screen spinners with:
    - **Skeleton loaders** for lists (recent activity, people list, cashbook, reports): card-shaped placeholders with a shimmer animation while data loads.
    - **Inline loading indicators** for buttons and small actions:
      - On backup/export/restore, turn the button label into "Exporting…" with a small spinner, then restore to normal and show a snackbar on completion.

- **Smooth screen transitions**
  - Distinguish between **tab switches** and **drill-down details**:
    - Bottom navigation (Overview / People / Cashbook / Reports / More):
      - Use a short (≈250–300ms) slide + fade transition between screens.
    - Detail screens (Person Details, About, etc.):
      - Use a vertical slide-up or subtle scale-in transition, so it feels like "opening a card".
  - Where appropriate, use hero-style animations:
    - Person avatar and name animate from People list into the header on Person Details.
    - Transaction card animates into a full transaction details view (if/when added).

- **Micro-interactions on key elements**
  - Quick action tiles on Overview:
    - Scale down slightly on tap (e.g. to 0.95) and bounce back for a satisfying press feel.
  - FABs (global and cashbook):
    - Rotate or morph into a close icon when opening a quick-add bottom sheet.
  - Charts and summary cards (Reports):
    - Values and bars animate in on first load and when filters change (fade + translate or size animation).

---

## 3. Information Architecture & Navigation

Current main structure (Home, Ledger, Cashbook, Reports, Settings) is good; we refine labels and flows.

### 3.1 Bottom Navigation

- Keep `ScaffoldWithNavBar` but modernize:
  - Tabs:
    - **Overview** (Home)
    - **People** (Ledger)
    - **Cashbook**
    - **Reports**
    - **More** (Settings/About)
  - Always show labels under icons (no icon-only tabs).
  - Use active/selected states with color + underline/indicator.

### 3.2 Main User Jobs

Design the flows around what users want to do:

1. "See how I’m doing" → Overview dashboard.
2. "See what each customer/supplier owes" → People (Ledger) → Person details.
3. "See and control cash movements" → Cashbook.
4. "Get statements or exports for accountant" → Reports.
5. "Configure the app or backup data" → More/Settings.

---

## 4. Screen-by-Screen Revamp

### 4.1 Overview (Home) Screen

**Goal:** A modern fintech-style dashboard: clear, motivating, and informative.

**Layout:**

1. **Top Area**
   - Greeting/title: "Good morning" / "Aldeewan Overview".
   - One-line subtitle: "Here’s your financial summary".
   - Optional icon for notifications/help.

2. **Hero Balance Card**
   - Large gradient card showing:
     - Net position (e.g. `totalReceivable - totalPayable`).
     - A short message: "Customers owe you" vs "You owe suppliers".
     - Time range chips embedded in the card: `Today | Week | Month | All`.

3. **Summary Cards Grid**
   - 2×2 grid or horizontal scroll of cards:
     - Total Receivable.
     - Total Payable.
     - Monthly Income.
     - Monthly Expense.
   - Each card:
     - Icon (arrow up/down, credit/debit).
     - Label + amount.
     - Optional small trend indicator (e.g. +10% vs last month).

4. **Quick Actions Section**
   - Title: "Quick actions".
   - Action tiles (2×2 grid or horizontal chips):
     - Add customer debt (→ ledger with `action=debt`).
     - Record payment (→ ledger with `action=payment`).
     - Add cash entry (→ cashbook with `action=add`).
     - View balances (→ ledger).
   - Tiles use distinct colors/icons to stand out.

5. **Recent Activity / Timeline**
   - Title: "Recent activity".
   - List grouped by date: Today, Yesterday, This week.
   - Each row:
     - Left: circular icon with color (green for income, red for expense).
     - Middle: localized transaction type and person name/category.
     - Right: amount + time.
   - Empty state: illustration + "No activity yet" + primary button "Add your first transaction".

**Implementation notes:**

- Backed by `ledgerProvider` summaries and transaction list.
- Use reusable widgets for cards and summary tiles so they can be used in Reports as well.

---

### 4.2 People (Ledger) Screen

**Goal:** Clean, modern people list like CRM/finance apps, with quick insight per customer/supplier.

**Layout:**

1. **Header & Role Tabs**
   - Title: "People".
   - Tabs or segmented control: `Customers | Suppliers`.

2. **Search & Filters**
   - Search bar: filter by name or phone.
   - Filter chips:
     - All / Positive balance / Negative balance / Zero.
   - Sort dropdown:
     - Name (A–Z) / Balance (high to low) / Recently active.

3. **People List**
   - Each person row (card-like):
     - Avatar with letter initials.
     - Name + phone.
     - Right side: balance amount + status label ("Owes you", "You owe").
     - Balance color-coded: green, red, or neutral.
   - Tap row → Person Details.

4. **Person Details Screen**
   - Header card:
     - Name, role chip, contact (phone/email if available).
     - Current balance and last activity date.
   - Tabs:
     - **Transactions**: timeline list of that person’s transactions.
     - **Summary**: key stats:
       - Total debt/income with that person.
       - Monthly breakdown.
       - Optionally: basic bar chart (later implementation).
   - FAB: "Add transaction" for this person (pre-fills person in the new transaction form).

5. **Add/Edit Person (person_form.dart)**
   - Compact, focused form:
     - Role selection chips: Customer / Supplier.
     - Name.
     - Phone.
   - Helper text hints (e.g., "Use full legal name if you share with accountant").

---

### 4.3 Cashbook Screen

**Goal:** A refined, filterable list of all cash movements, inspired by budget tracker UIs.

**Layout:**

1. **Header & Filters**
   - Title: "Cashbook".
   - Filter chips:
     - All / Income / Expense.
   - Date filter:
     - Today / This week / This month / Custom range.

2. **Summary Bar**
   - Small card summarizing:
     - Total cash in.
     - Total cash out.
     - Net cash for the selected period.

3. **Transactions List**
   - Each cash transaction row:
     - Icon + color representing type (sale, income, expense).
     - Primary text: localized type.
     - Secondary text: person name or category + formatted date.
     - Right side: amount with currency, color-coded.
   - Swipe gestures:
     - Left swipe: delete (with confirm).
     - Right swipe: edit.

4. **Add Cash Entry Bottom Sheet**
   - Multi-step or segmented form:
     - Step 1: choose type via chips (Payment received, Payment made, Cash sale, Cash income, Cash expense).
     - Step 2: fields: amount, date, person (optional), category, note.
   - Live amount preview in selected currency using `currencyProvider`.

---

### 4.4 Reports Screen

**Goal:** Analytics-style interface similar to finance dashboards in Figma kits.

**Tabs:**

1. **Person Statement**
   - Controls:
     - Person selector (dropdown/search).
     - Date range picker.
   - Summary row:
     - Opening balance.
     - Total debits.
     - Total credits.
     - Closing balance.
   - Statement list (table-like):
     - Date, description, debit, credit, running balance.
   - CTA: "Export statement" (CSV, later PDF if desired).

2. **Cash Flow**
   - Filters:
     - Interval: Day / Week / Month.
     - Date range.
   - Visuals:
     - Bar or line chart for cash in vs out.
     - Top categories (for expenses) as chips/cards.
   - Summary:
     - Total in, Total out, Net for the period.

**Implementation notes:**

- Start with the layout and static UI.
- Later, integrate a charting library, or build simple visual bars with `Container` + `Flex`.

---

### 4.5 More / Settings Screen

**Goal:** Group configuration, data, and help in an organized, less cluttered way.

**Sections:**

1. **Appearance**
   - Theme mode selector with visual preview tiles:
     - System / Light / Dark.

2. **Language**
   - EN / AR toggle, show a preview snippet for each.

3. **Currency**
   - Dropdown with currency codes and symbols (USD, EUR, SAR, EGP, AED).
   - Small note: "Used for displaying amounts; does not convert values."

4. **Data & Backup**
   - Two large cards:
     - Backup data (JSON): explanation and CTA.
     - Restore data: explanation + warning label.
   - CSV exports grouped (persons, transactions) with icons.

5. **Help & About**
   - "How to use Aldeewan" (link to help/onboarding section).
   - About developer.
   - Link to GitHub or support.

---

## 5. Onboarding & Guidance

### 5.1 First-Time Onboarding

- Add a 3-screen carousel shown on first launch:
  1. Track customers and suppliers.
  2. Manage cashbook and see reports.
  3. Backup and keep your data safe.
- Each screen: simple illustration + short copy + primary CTA ("Start now").

### 5.2 Contextual Tips (Coach Marks)

- For each main screen, show a one-time tooltip:
  - Overview: highlight "Add transaction" or hero card.
  - People: highlight "Add person".
  - Cashbook: highlight filters or FAB.
  - Reports: highlight person/date filters.
- Remember dismissed tips via `shared_preferences`.

### 5.3 Empty States

- Replace plain "No entries" text with:
  - Small illustration/icon.
  - One-line explanation.
  - Clear action button ("Add first customer", "Add first transaction").

### 5.4 Animations & Loading Patterns (Summary)

To ensure a smooth, modern feel across the app:

- **Launch & global**
  - Implement a branded splash animation on app start.
  - Provide a global loading overlay for heavy operations (restore, big exports).

- **Per-screen transitions**
  - Use slide/fade transitions for bottom navigation tab changes.
  - Use vertical slide or scale animations for detail modals and full-screen drill-downs.

- **Inline content loading**
  - Adopt skeleton/shimmer placeholders for lists while fetching data.
  - Use inline loading states for action buttons (backup, export, restore) instead of blocking spinners.

- **Delightful micro-interactions**
  - Animate taps on quick actions, FABs, and key cards.
  - Animate charts and summary values on entry and filter changes.

These patterns should be reflected both in the Figma prototypes (as motion specs) and in the Flutter implementation (using `Animated*` widgets, custom `go_router` transitions, and, optionally, a small Lottie animation for splash/loading).

---

## 6. Personalization & Advanced UX

### 6.1 Frequent People Shortcuts

- On Overview, show a row of frequently used persons:
  - Avatars for top 3–5 people by activity.
  - Tap → open Person Details.
  - Long-press → quick action: add transaction for this person.

### 6.2 Global Quick Add

- Floating "+" FAB on Overview (optionally shared across tabs):
  - Opens bottom sheet with:
    - Add customer debt.
    - Record payment.
    - Add cash income/expense.
  - This mirrors interactions in modern finance apps.

### 6.3 Localization & RTL

- Ensure layouts work both LTR (English) and RTL (Arabic):
  - Use `Directionality`-aware paddings and icons.
  - Avoid hard-coded alignments like `Alignment.centerLeft` for text that should flip.

---

## 7. Implementation Roadmap

### Phase 1 – Design System

1. In Figma, create:
   - Color styles (light/dark, gradient variants).
   - Typography styles based on Inter (H1, H2, Body, Caption).
   - Components: buttons, cards, chips, inputs, bottom navigation, FAB.
2. Update `AppTheme` in Flutter to reflect these styles:
   - `ColorScheme`, `TextTheme`, `ButtonTheme`, `CardTheme`, `NavigationBarTheme`, `ChipTheme`.

### Phase 2 – Overview & Cashbook

1. Redesign `HomeScreen` (Overview):
   - Implement hero card, summary cards grid, quick actions section, and improved recent activity.
2. Revamp `CashbookScreen`:
   - Add filter chips, date filters, summary bar, and redesigned list items.
   - Implement improved add cash entry sheet.

### Phase 3 – People & Person Details

1. Update `LedgerScreen` (People):
   - Role tabs, search, filter chips, sorting.
   - Person list cards.
2. Enhance `PersonDetailsScreen`:
   - Header summary, tabs for transactions and summary, more polished list.

### Phase 4 – Reports & More/Settings

1. Rebuild `ReportsScreen` to match analytics layout:
   - Person statement tab and cash flow tab.
   - Clear filters, summaries, and export buttons.
2. Restructure `SettingsScreen` into a "More" section with grouped cards.

### Phase 5 – Onboarding, Tips, & Polish

1. Add onboarding carousel and contextual tips.
2. Implement global quick add sheet.
3. Refine micro-interactions and transitions.
4. Validate RTL and accessibility (text scaling, contrast).

---

## 8. Deliverables for Design

For the designer (or for yourself if you use Figma directly), prepare:

- A **Figma file** with:
  - Design system page (colors, typography, components).
  - Screens for:
    - Overview (light & dark).
    - People (list & details).
    - Cashbook.
    - Reports.
    - More/Settings.
    - Onboarding & key empty states.
- An **implementation checklist** that maps each Figma screen/component to Flutter widgets and files (e.g., `HomeScreen` → `home_screen.dart`, `ScaffoldWithNavBar` → `scaffold_with_nav_bar.dart`).

This document is intended as your long-term guide while you gradually implement the new modern UI/UX in Aldeewan Mobile.
