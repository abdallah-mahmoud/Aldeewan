# v2.2.0 Testing Checklist

**Date:** 2025-12-28  
**Build Type:** Debug APK  
**Previous Version:** 2.1.0

---

## 1. Help Center (مركز المساعدة) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 1.1 | Access Help Center | Settings → Help | Help Center opens with 6 categories | ✓ |
| 1.2 | Category Cards | Tap each category | FAQs expand/collapse correctly | ✓ |
| 1.3 | Arabic Content | Read FAQ answers | Arabic text displays correctly, RTL aligned | ✓ |
| 1.4 | English Content | Switch to English → Settings → Help | English FAQs display correctly | ✓ |
| 1.5 | Scroll Behavior | Scroll through long category | Smooth scrolling, no overflow | ✓ |

---

## 2. Dashboard Sections (أقسام لوحة التحكم) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 2.1 | Section Headers | View Home screen | "Debts" and "Monthly" sections visible with icons | ✓ |
| 2.2 | Debts Section | Check Receivable/Payable cards | Colors correct (green for receivable, red for payable) | ✓ |
| 2.3 | Monthly Section | Check Money In/Out and True Income/Expense | All 4 cards visible with correct styling | ✓ |
| 2.4 | Card Taps | Tap each summary card | Navigates to correct filtered screen | ✓ |
| 2.5 | RTL Layout | Use Arabic language | Headers and cards align correctly RTL | ✓ |

---

## 3. Ledger Terminology (مصطلحات الدفتر) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 3.1 | Customer Owes | Add customer with positive balance | Shows "ديون لك" (Owes You) | ✓ |
| 3.2 | Customer Advance | Add customer with negative balance | Shows "لك (رصيد مقدم)" (Advance Owes You) | ✓ |
| 3.3 | Supplier Owes | Add supplier with positive balance | Shows "ديون عليك" (You Owe) | ✓ |
| 3.4 | Supplier Advance | Add supplier with negative balance | Shows "عليك (رصيد مقدم)" (Advance You Owe) | ✓ |
| 3.5 | English Terms | Switch to English | Shows "Owes You" / "You Owe" correctly | ✓ |

---

## 4. Directional Tab Transitions (انتقالات ذكية) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 4.1 | Move Right | Tap Home → Ledger | New screen slides in from RIGHT | ✓ |
| 4.2 | Move Left | Tap Ledger → Home | New screen slides in from LEFT | ✓ |
| 4.3 | Skip Tabs | Tap Home → Settings (skip 3 tabs) | Slides from RIGHT | ✓ |
| 4.4 | Skip Tabs Back | Tap Settings → Home | Slides from LEFT | ✓ |
| 4.5 | Smooth Animation | Rapidly switch tabs | Animations smooth, no glitches | ✓ |

---

## 5. Scalable Text (نصوص قابلة للتكيف) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 5.1 | Large Font Setting | Device Settings → Font Size → Largest | No yellow overflow strips | ✗ |
| 5.2 | Dashboard Headers | With large font | Section headers shrink, no overflow |  |
| 5.3 | Date Picker | Open TransactionForm | Date text scales down if needed |  |
| 5.4 | Phone Numbers | Add person with long phone | Phone number scales in list tile |  |
| 5.5 | Summary Card Values | Large amounts | Currency amounts fit in cards |  |

---

## 6. Storage Safety (معالجة الأخطاء) 🆕

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 6.1 | Save Person Success | Add new person | Success toast appears | ✓ |
| 6.2 | Save Transaction Success | Add new transaction | Success toast appears | ✓ |
| 6.3 | Error Logging | (Dev only) Force error in debugger | Error logged with ❌ prefix | ✓ |

> **Note:** Full error testing requires forcing a database error which is difficult in normal testing. This is mainly for code robustness.

---

## 7. Code Refactoring (تحسينات الكود) ✅

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 7.1 | Static Analysis | Run `dart analyze` | 0 issues found |  |
| 7.2 | Existing Features | Use ledger, cashbook, analytics | All features work as before |  |

---

## 8. Version Display

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 8.1 | Settings Footer | Open Settings | Shows "v2.2.0" in footer | ✓ |
| 8.2 | About Screen | Settings → About | Version displays correctly | ✓ |

---

## 9. Regression Tests (Existing Features)

| # | Test Case | Steps | Expected Result | ✓/✗ |
|---|-----------|-------|-----------------|-----|
| 9.1 | Add Person | Ledger → Add Person | Person added successfully | ✓ |
| 9.2 | Add Transaction | Person → Add Transaction | Transaction saved | ✓ |
| 9.3 | Cashbook Filter | Cashbook → Filter by Income | Only income shows | ✓ |
| 9.4 | Budget Alert | Exceed budget amount | Warning appears | ✓ |
| 9.5 | Goal Progress | Add money to goal | Progress bar updates | ✓ |
| 9.6 | Backup/Restore | Settings → Backup → Restore | Data restored correctly | ✓ |
| 9.7 | Theme Switch | Settings → Dark/Light | Theme changes correctly | ✓ |
| 9.8 | Language Switch | Settings → Arabic/English | Language changes, restarts app | ✓ |
| 9.9 | Notifications | Enable and test notification | Notification received | ✓ |
| 9.10 | Analytics Charts | View analytics screen | Charts render correctly | ✓ |

---

## Summary

| Category | Tests | Priority |
|----------|-------|----------|
| Help Center | 5 | 🔴 High |
| Dashboard Sections | 5 | 🔴 High |
| Ledger Terminology | 5 | 🔴 High |
| Tab Transitions | 5 | 🟡 Medium |
| Scalable Text | 5 | 🟡 Medium |
| Storage Safety | 3 | 🟢 Low |
| Code Refactoring | 2 | 🟢 Low |
| Version Display | 2 | 🟢 Low |
| Regression | 10 | 🔴 High |
| **Total** | **42** |  |

---

**Tester:** _______________  
**Date Tested:** _______________  
**Result:** ⬜ PASS / ⬜ FAIL  
**Notes:**
