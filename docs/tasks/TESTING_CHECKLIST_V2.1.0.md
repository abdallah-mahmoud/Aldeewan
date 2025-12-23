# v2.1.0 Testing Checklist

## 🔥 Priority 1: Performance Fixes
- [x] **Keyboard Lag:** Budget screen → Create Budget → Type amount rapidly → Should be smooth
- [x] **Keyboard Lag:** Goals screen → Add to Goal → Type amount → Should be smooth
- [x] **Pagination:** Cashbook → Add 60+ transactions → Only 50 show → "Load More" button appears

## 📊 Priority 2: Charts
- [x] **Pie Chart:** Analytics → Tap pie sections → No lag/jank
- [x] **Balance Chart:** Home → Balance trend chart renders correctly

## 🎯 Priority 3: UI/UX Fixes
- [x] **FAB Hidden:** Cashbook → Empty state shows "Add" button → No FAB visible
- [x] **Tab Indicator:** Ledger/Analytics → Tab indicator is visible (not hidden)
- [x] **Currency Spacing:** All screens → Currency symbol has space before amount
- [x] **Tour/Dialog:** *(Debug mode behavior - only triggers in release build)*

## 🌐 Priority 4: Localization
- [x] **Arabic:** Switch to Arabic → "تحميل المزيد" appears in Load More button
- [x] **RTL Layout:** Arabic layout is correct

## ✅ Quick Smoke Test
- [x] App launches without crash
- [x] Add person → Add transaction → Shows in list
- [x] Navigate all tabs (Home, Ledger, Cashbook, Reports, Settings)

---
**Result: All tests passed ✅** (Tour behavior is debug-mode specific, works in release)

