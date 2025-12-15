# Aldeewan Mobile – UI/UX Revamp Plan V2 (Refinement)

Date: 2025-12-10

## 1. Goals

- **Refine Design**: Align closer to modern fintech concepts (cleaner, flexible typography).
- **Fix Issues**:
  - Text sizes are too big/rigid.
  - Navigation bar styling/flexibility.
  - Localization gaps (Home screen cards not using Arabic).
- **Update Business Logic**:
  - Restrict currencies to: QAR (Qatar), SAR (Saudi), EGP (Egypt), SDG (Sudan).

## 2. Action Plan

### 2.1 Typography & Layout
- **Problem**: Text is too big and not flexible.
- **Solution**:
  - Reduce base font sizes in `AppTheme`.
  - Use `FittedBox` or `Flexible`/`Expanded` wrappers for text in Cards to prevent overflow.
  - Ensure responsive sizing.

### 2.2 Localization (Arabic Support)
- **Problem**: New home screen cards have hardcoded English text.
- **Solution**:
  - Identify hardcoded strings in `HomeScreen`, `CashbookScreen`, `LedgerScreen`.
  - Add keys to `app_en.arb` and `app_ar.arb`.
  - Ensure RTL layout works correctly (Flutter handles this mostly, but check padding/margins).

### 2.3 Currencies
- **Problem**: Unwanted currencies (USD, EUR, AED). Missing QAR, SDG.
- **Solution**:
  - Update `SettingsScreen` currency list.
  - Update `CurrencyProvider` default if necessary.
  - Supported list: QAR, SAR, EGP, SDG.

### 2.4 Navigation Bar
- **Problem**: "Flexibility" issues.
- **Solution**:
  - Review `BottomNavBar`.
  - Ensure labels don't overflow.
  - potentially reduce icon size or label size.

### 2.5 Visual Polish (Fintech Style)
- **Inspiration**: Clean, rounded, soft shadows.
- **Adjustments**:
  - Refine `CardTheme` (elevation, border radius).
  - Refine `ColorScheme` if needed (though Teal is good, maybe softer backgrounds).

## 3. Execution Steps

1.  **Currencies**: Update `SettingsScreen`.
2.  **Localization**: Extract strings from `HomeScreen` (e.g., "Net position", "Customers owe you more").
3.  **Typography**: Tune `theme.dart`.
4.  **Nav Bar**: Tune `bottom_nav_bar.dart`.
5.  **Verify**: Run app (or check code) for RTL/Arabic correctness.
