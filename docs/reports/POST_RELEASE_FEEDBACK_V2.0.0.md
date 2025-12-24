# Post-Release Feedback Report - v2.0.0

**Version:** 2.0.0  
**Release Date:** December 21, 2025  
**Report Status:** ✅ All Items Addressed in v2.1.0

---

## 📋 Feedback Summary

| # | Category | Priority | Status |
|---|----------|----------|--------|
| 1 | Responsiveness | Medium | ✅ Addressed |
| 2 | UX Copy/Tone | Low | ✅ Addressed |
| 3 | Duplicate UI Elements | Medium | ✅ Addressed |
| 4 | Empty State Layout | Medium | ✅ Addressed |
| 5 | Tour & Dialog Conflict | High | ✅ Addressed |
| 6 | Tab Indicator Visibility | Medium | ✅ Addressed |
| 7 | Debt Given Balance Limit | High | ✅ Addressed |
| 8 | Reports Person Filter Empty State | Medium | ✅ Addressed |
| 9 | Seamless Data Migration on Update | High | ✅ Addressed |
| 10 | Ledger Person List Sorting | Medium | ✅ Addressed |
| 11 | Numeric Keyboard for Amounts | Low | ✅ Addressed |
| 12 | Currency Formatting Spacing | Low | ✅ Addressed |
| 13 | Expanded Currency List & Selector UX | Medium | ✅ Addressed |

---

## 🔍 Detailed Feedback Items

### 1. Screen Responsiveness
**Source:** Pro Flutter Developer  
**Category:** UI/UX  
**Priority:** 🟡 Medium

**Issue:**  
App layout may not scale well across different screen sizes.

**Recommendation:**  
Use the `screenutil` package for responsive sizing of fonts, margins, and widgets.

**Affected Areas:**  
- All screens (global change)

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** Applied `flutter_screenutil` globally.

---

### 2. Harsh UX Copy
**Source:** Pro Flutter Developer  
**Category:** UX Copy  
**Priority:** 🟢 Low

**Issue:**  
The budget warning text "هنبلغك لو صرفت كتير" (We'll notify you if you spend too much) sounds harsh/aggressive.

**Recommendation:**  
Reword to a more casual, friendly tone. Examples:
- "سنذكرك عند اقتراب الحد" (We'll remind you when nearing the limit)
- "تنبيه ودي عند تجاوز الميزانية" (Friendly alert when exceeding budget)

**Affected Areas:**  
- Budget/spending notification settings
- Localization files (`app_ar.arb`)

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** The text was changed from "هنبلغك لو صرفت كتير" to "سنذكرك عند اقتراب ميزانيتك" (friendly reminder tone).

---

### 3. Duplicate Add Buttons
**Source:** Pro Flutter Developer  
**Category:** UI Redundancy  
**Priority:** 🟡 Medium

**Issue:**  
In empty states, both a FAB (Floating Action Button) and an inline "Add" button are shown. This is redundant.

**Recommendation:**  
When showing an empty state with an inline call-to-action, hide the FAB. Or vice versa - keep only one clear action.

**Affected Screens (to audit):**
- [ ] Cashbook (Transactions list) - confirmed
- [ ] Ledger (Contacts list)
- [ ] Reports sections
- [x] Any other list screens

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** FAB is hidden when empty state "Add" button is visible in Cashbook and Ledger.

---

### 4. Empty State Takes Too Much Space
**Source:** Pro Flutter Developer  
**Category:** UI Layout  
**Priority:** 🟡 Medium

**Issue:**  
On the Home Screen, the "Recent Transactions" block shows a large empty/loading state when there are no transactions, wasting vertical space.

**Recommendation:**  
- Collapse or minimize the section when empty
- Show a compact single-line message instead of a full empty state illustration
- Or hide the section entirely until there's data

**Affected Areas:**  
- `HomeScreen` → Recent Transactions block
- Other summary blocks on Home

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** `RecentTransactions` widget uses a compact single-line empty state (icon + text) instead of a large illustration.

---

### 5. Tour & Initial Balance Dialog Conflict
**Source:** Pro Flutter Developer  
**Category:** Onboarding Flow  
**Priority:** 🔴 High

**Issue:**  
On first app launch, the app tour and the initial balance dialog both trigger simultaneously, causing visual conflict and confusing UX.

**Recommendation:**  
Sequence the onboarding flow properly:
1. Show Initial Balance dialog first
2. Wait for user to save OR skip
3. THEN start the app tour

**Affected Areas:**  
- `HomeScreen` initialization logic
- `OnboardingService`
- App tour trigger logic

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** Tour is queued to start only AFTER the Initial Balance dialog closes. `barrierDismissible: false` prevents accidental dismissal.

---

### 6. Tab Indicator Not Distinguishable
**Source:** Pro Flutter Developer  
**Category:** UI Visibility  
**Priority:** 🟡 Medium

**Issue:**  
The active tab indicator on tabbed screens (Reports/Analytics, Ledger) isn't visually distinct enough.

**Recommendation:**  
- Increase indicator thickness or add underline
- Use bolder color contrast for active tab
- Add subtle animation or background highlight

**Affected Screens:**  
- Reports / Analytics screen (tabs)
- Ledger screen (tabs)

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** Tab indicators now have a shadow and border for better visibility.

---

### 7. Debt Given Should Check Balance
**Source:** Pro Flutter Developer  
**Category:** Business Logic / Validation  
**Priority:** 🔴 High

**Issue:**  
When recording "Debt Given" (money lent to others), the app doesn't check if the user has sufficient balance - unlike expenses which show an "Insufficient Funds" alert.

**Recommendation:**  
Apply the same balance validation and alert system used for expenses:
- Check if current balance >= debt amount being given
- Show "Insufficient Funds" alert if balance is too low
- Optionally allow override with confirmation

**Affected Areas:**  
- Ledger transaction form (giving debt)
- Balance validation logic
- `InsufficientFundsDialog` reuse

**Status:** ✅ Addressed in v1.1.0/v2.1.0  
**Resolution:** Balance check is implemented in `TransactionForm` for both payments and debt given.

---

### 8. Reports Person Filter Empty State
**Source:** Pro Flutter Developer  
**Category:** UI/UX  
**Priority:** � Medium

**Issue:**  
In the Reports/Analytics screen, when selecting a person filter and there are no transactions for that person, the screen shows a blank list instead of a proper empty state.

**Recommendation:**  
Show a meaningful empty state with:
- An illustration or icon
- Message like "لا توجد معاملات لهذا الشخص" (No transactions for this person)
- Optionally a suggestion to add a transaction

**Affected Areas:**  
- Reports / Analytics screen
- Person filter functionality

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** Empty states added to both Person Statement and Cash Flow reports.

---

### 9. Seamless Data Migration on Update
**Source:** Tester Feedback  
**Category:** Data Persistence / Migration  
**Priority:** 🔴 High

**Issue:**  
When updating the app to a new version, user data must be preserved. The update process should be seamless and not affect or delete any existing user data.

**Recommendation:**  
- Implement proper Realm database migration strategies
- Test upgrade paths from previous versions
- Add version checks and migration scripts if schema changes
- Ensure backward compatibility with existing data
- Consider adding backup prompt before major updates

**Affected Areas:**  
- Realm database configuration
- App initialization flow
- Data models (if schema changes)

---

### 10. Ledger Person List Sorting Filters
**Source:** User Feedback  
**Category:** UX / Feature Request  
**Priority:** � Medium

**Issue:**  
The person list in the Ledger screen lacks sorting/filter options. Users cannot easily organize contacts by different criteria.

**Recommendation:**  
Add filter/sort options to the Ledger person list:
- Sort by date added (newest/oldest first)
- Sort by money amount (highest/lowest debt/credit)

**Affected Areas:**  
- Ledger screen (Person list)
- Filter/Sort UI component

**Status:** ✅ Addressed in v2.0.0/v2.1.0  
**Resolution:** Sorting filters added to Ledger person list.

---

### 11. Numeric Keyboard for Amount Inputs
**Source:** User Feedback  
**Category:** UX / Input Optimization  
**Priority:** 🟢 Low

**Issue:**  
When entering money amounts, the default keyboard is shown instead of the numeric keyboard. This makes it slower and less convenient to input numbers.

**Recommendation:**  
Set `keyboardType: TextInputType.number` (or `TextInputType.numberWithOptions(decimal: true)`) for all amount/money input fields throughout the app.

**Affected Areas:**  
- All money/amount input fields across the app
- Cash entry forms
- Ledger transaction forms
- Budget input fields
- Initial balance input
- Goal amount inputs

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** All amount fields consistently use `numberWithOptions(decimal: true)`.

---

### 12. Currency Formatting Spacing
**Source:** User Feedback  
**Category:** UI / Formatting  
**Priority:** 🟢 Low

**Issue:**  
Currency amounts are displayed without a space between the currency code and the number (e.g., "SDG15,999" instead of "SDG 15,999"), making them harder to read.

**Recommendation:**  
Add a space between the currency sign/code and the amount value. For example:
- Before: `SDG15,999`
- After: `SDG 15,999`

**Affected Areas:**  
- Currency formatting utility/helper
- All screens displaying monetary values

**Status:** ✅ Addressed in v1.1.0/v2.1.0  
**Resolution:** `CurrencyFormatter` ensures a space between currency and amount globally.

---

### 13. Expanded Currency List & Selector UX
**Source:** User Feedback  
**Category:** Feature / UX Enhancement  
**Priority:** 🟡 Medium

**Issue:**  
The current currency list is limited and doesn't include many currencies from Islamic/Muslim-majority countries. Additionally, with an expanded list, the current selector UI will be difficult to navigate.

**Recommendation:**  
1. **Expand Currency List** - Add currencies from Islamic countries (see reference table below)
2. **Add Search Functionality** - Implement a search bar in the currency selector for easier navigation
3. **Arabic Localization** - Add Arabic names for all currencies
4. **Default Currency** - Keep SDG (Sudanese Pound) as the default
5. **No Duplicates** - Ensure no duplicate currency codes (e.g., XOF used by multiple countries should appear once)

**Currency Reference Table (Islamic Countries):**

| Code | English Name | Arabic Name | Symbol |
|------|--------------|-------------|--------|
| **Middle East** ||||
| SDG | Sudanese Pound | الجنيه السوداني | ج.س |
| SAR | Saudi Riyal | الريال السعودي | ﷼ |
| AED | UAE Dirham | الدرهم الإماراتي | د.إ |
| QAR | Qatari Riyal | الريال القطري | ﷼ |
| KWD | Kuwaiti Dinar | الدينار الكويتي | د.ك |
| BHD | Bahraini Dinar | الدينار البحريني | .د.ب |
| OMR | Omani Rial | الريال العماني | ﷼ |
| JOD | Jordanian Dinar | الدينار الأردني | د.ا |
| IQD | Iraqi Dinar | الدينار العراقي | ع.د |
| SYP | Syrian Pound | الليرة السورية | £S |
| LBP | Lebanese Pound | الليرة اللبنانية | ل.ل |
| YER | Yemeni Rial | الريال اليمني | ﷼ |
| **North Africa** ||||
| EGP | Egyptian Pound | الجنيه المصري | ج.م |
| LYD | Libyan Dinar | الدينار الليبي | ل.د |
| TND | Tunisian Dinar | الدينار التونسي | د.ت |
| DZD | Algerian Dinar | الدينار الجزائري | د.ج |
| MAD | Moroccan Dirham | الدرهم المغربي | د.م |
| MRU | Mauritanian Ouguiya | الأوقية الموريتانية | أ.م |
| **South/Central Asia** ||||
| PKR | Pakistani Rupee | الروبية الباكستانية | ₨ |
| BDT | Bangladeshi Taka | التاكا البنغلاديشية | ৳ |
| AFN | Afghan Afghani | الأفغاني الأفغاني | ؋ |
| IRR | Iranian Rial | الريال الإيراني | ﷼ |
| TRY | Turkish Lira | الليرة التركية | ₺ |
| AZN | Azerbaijani Manat | المانات الأذربيجاني | ₼ |
| KZT | Kazakhstani Tenge | التنغي الكازاخستاني | ₸ |
| UZS | Uzbekistani Som | السوم الأوزبكستاني | сўм |
| TMT | Turkmenistani Manat | المانات التركمانستاني | m |
| TJS | Tajikistani Somoni | السوموني الطاجيكستاني | ЅМ |
| KGS | Kyrgyzstani Som | السوم القيرغيزستاني | сом |
| **Southeast Asia** ||||
| IDR | Indonesian Rupiah | الروبية الإندونيسية | Rp |
| MYR | Malaysian Ringgit | الرينغيت الماليزي | RM |
| BND | Brunei Dollar | دولار بروناي | B$ |
| **Sub-Saharan Africa** ||||
| SOS | Somali Shilling | الشلن الصومالي | Sh.So |
| DJF | Djiboutian Franc | الفرنك الجيبوتي | Fdj |
| KMF | Comorian Franc | الفرنك القمري | CF |
| GMD | Gambian Dalasi | الدالاسي الغامبي | D |
| XOF | West African CFA Franc | فرنك غرب أفريقيا | CFA |
| GNF | Guinean Franc | الفرنك الغيني | FG |
| SLE | Sierra Leonean Leone | الليون السيراليوني | Le |
| NGN | Nigerian Naira | النيرة النيجيرية | ₦ |

**Affected Areas:**  
- Settings screen (Currency selector)
- Currency model/data
- Localization files (`app_ar.arb`, `app_en.arb`)
- Currency formatting utilities

**Status:** ✅ Addressed in v2.1.0  
**Resolution:** Expanded `currency_data.dart` to 40+ currencies covering Islamic countries. `CurrencySelectorSheet` includes search functionality for easy navigation.

---

## 📝 Additional Notes

> This document is for feedback collection only. Add new feedback items as they come in. Once ready to implement, create an implementation plan.

---

## 🗓️ Changelog

| Date | Update |
|------|--------|
| Dec 21, 2025 | Initial feedback collection from Pro Flutter Dev review |
| Dec 21, 2025 | Added #8: Reports person filter empty state |
| Dec 21, 2025 | Added #9: Seamless data migration on update |
| Dec 23, 2025 | Added #10: Ledger person list sorting filters |
| Dec 23, 2025 | Added #11: Numeric keyboard for amount inputs |
| Dec 23, 2025 | Added #12: Currency formatting spacing |
| Dec 23, 2025 | Added #13: Expanded currency list with Islamic countries & selector UX |
| Dec 23, 2025 | **v2.1.0 Release:** Marked items #1, #3, #4, #5, #6, #7, #8, #10, #11, #12 as Addressed |

