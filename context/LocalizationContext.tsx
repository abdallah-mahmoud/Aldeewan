import React, { createContext, useState, useContext, useEffect, useCallback } from 'react';

type Language = 'ar' | 'en';
type Direction = 'rtl' | 'ltr';

interface LocalizationContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  dir: Direction;
  t: (key: string) => string;
  appCurrency: string;
  setAppCurrency: (currency: string) => void;
  formatCurrency: (amount: number) => string;
  formatDate: (dateString: string) => string;
}

const translations: Record<Language, Record<string, string>> = {
  ar: {
    appName: 'الدِّيوانُ',
    tagline: 'دفتر ديونك... في جيبك.',
    // Home Screen
    addDebt: 'إضافة دَين',
    recordPayment: 'تسجيل سداد',
    addCashEntry: 'إضافة دخل / مصروف',
    viewBalances: 'عرض الأرصدة',
    quickActions: 'إجراءات سريعة',
    totalReceivable: 'إجمالي المستحق',
    totalPayable: 'إجمالي الدفع',
    // Navigation
    home: 'الرئيسية',
    ledger: 'السجل',
    cashbook: 'النقدية',
    reports: 'التقارير',
    settings: 'الإعدادات',
    // Ledger Screen
    customersAndSuppliers: 'العملاء والموردون',
    searchByName: 'ابحث بالاسم...',
    customer: 'عميل',
    supplier: 'مورد',
    balance: 'الرصد',
    ledgerOf: 'سجل',
    // Cashbook Screen
    incomeAndExpenses: 'الدخل والمصروفات',
    income: 'دخل',
    expense: 'مصروف',
    totalIncome: 'إجمالي الدخل',
    totalExpense: 'إجمالي المصروفات',
    netFlow: 'صافي التدفق',
    // Reports Screen
    generateReports: 'إنشاء تقارير',
    exportAsPDF: 'تصدير PDF',
    exportAsCSV: 'تصدير CSV',
    featureComingSoon: 'هذه الميزة ستتوفر قريباً',
    // Settings Screen
    theme: 'المظهر',
    light: 'فاتح',
    dark: 'داكن',
    system: 'النظام',
    currency: 'العملة',
    // General
    overdue: 'متأخر عن السداد',
    youOwe: 'لك',
    theyOwe: 'عليك',
    edit: 'تعديل',
    delete: 'حذف',
    save: 'حفظ',
    cancel: 'إلغاء',
    confirmDeletion: 'تأكيد الحذف',
    areYouSureDelete: 'هل أنت متأكد من حذف هذا السجل؟ لا يمكن التراجع عن هذا الإجراء.',
    editEntry: 'تعديل السجل',
    addEntry: 'إضافة سجل',
    back: 'رجوع',
    amount: 'المبلغ',
    date: 'التاريخ',
    category: 'الفئة',
    type: 'النوع',
    note: 'ملاحظة (اختياري)',
    selectType: 'اختر النوع',
    debt: 'دين',
    payment: 'سداد',
    addPerson: 'إضافة شخص',
    personName: 'اسم الشخص',
    phoneOptional: 'رقم الهاتف (اختياري)',
    role: 'الدور',
    addCustomerOrSupplier: 'إضافة عميل أو مورد',
    selectPerson: 'اختر شخص',
    sar: 'ريال سعودي',
    sdg: 'جنيه سوداني',
    aed: 'درهم إماراتي',
    egp: 'جنيه مصري',
  },
  en: {
    appName: 'AlDeewan',
    tagline: 'Your debt book... in your pocket.',
    // Home Screen
    addDebt: 'Add Debt',
    recordPayment: 'Record Payment',
    addCashEntry: 'Add Income / Expense',
    viewBalances: 'View Balances',
    quickActions: 'Quick Actions',
    totalReceivable: 'Total Receivable',
    totalPayable: 'Total Payable',
    // Navigation
    home: 'Home',
    ledger: 'Ledger',
    cashbook: 'Cashbook',
    reports: 'Reports',
    settings: 'Settings',
    // Ledger Screen
    customersAndSuppliers: 'Customers & Suppliers',
    searchByName: 'Search by name...',
    customer: 'Customer',
    supplier: 'Supplier',
    balance: 'Balance',
    ledgerOf: 'Ledger of',
    // Cashbook Screen
    incomeAndExpenses: 'Income & Expenses',
    income: 'Income',
    expense: 'Expense',
    totalIncome: 'Total Income',
    totalExpense: 'Total Expense',
    netFlow: 'Net Flow',
    // Reports Screen
    generateReports: 'Generate Reports',
    exportAsPDF: 'Export as PDF',
    exportAsCSV: 'Export as CSV',
    featureComingSoon: 'This feature is coming soon',
    // Settings Screen
    theme: 'Theme',
    light: 'Light',
    dark: 'Dark',
    system: 'System',
    currency: 'Currency',
    // General
    overdue: 'Overdue',
    youOwe: 'You Owe',
    theyOwe: 'They Owe',
    edit: 'Edit',
    delete: 'Delete',
    save: 'Save',
    cancel: 'Cancel',
    confirmDeletion: 'Confirm Deletion',
    areYouSureDelete: 'Are you sure you want to delete this entry? This action cannot be undone.',
    editEntry: 'Edit Entry',
    addEntry: 'Add Entry',
    back: 'Back',
    amount: 'Amount',
    date: 'Date',
    category: 'Category',
    type: 'Type',
    note: 'Note (Optional)',
    selectType: 'Select Type',
    debt: 'Debt',
    payment: 'Payment',
    addPerson: 'Add Person',
    personName: 'Person Name',
    phoneOptional: 'Phone (Optional)',
    role: 'Role',
    addCustomerOrSupplier: 'Add Customer or Supplier',
    selectPerson: 'Select Person',
    sar: 'Saudi Riyal',
    sdg: 'Sudanese Pound',
    aed: 'UAE Dirham',
    egp: 'Egyptian Pound',
  },
};

const LocalizationContext = createContext<LocalizationContextType | undefined>(undefined);

export const LocalizationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguage] = useState<Language>('ar');
  const [dir, setDir] = useState<Direction>('rtl');
  const [appCurrency, setAppCurrencyState] = useState<string>(() => localStorage.getItem('appCurrency') || 'SDG');

  useEffect(() => {
    const newDir = language === 'ar' ? 'rtl' : 'ltr';
    setDir(newDir);
    document.documentElement.lang = language;
    document.documentElement.dir = newDir;
  }, [language]);
  
  const setAppCurrency = useCallback((currency: string) => {
    localStorage.setItem('appCurrency', currency);
    setAppCurrencyState(currency);
  }, []);

  const t = useCallback((key: string): string => {
    return translations[language][key] || key;
  }, [language]);

  const formatCurrency = useCallback((amount: number) => {
    const locale = language === 'ar' ? 'ar-SA-u-nu-latn' : 'en-US';
    const options: Intl.NumberFormatOptions = {
        style: 'currency',
        currency: appCurrency,
        currencyDisplay: 'symbol',
    };

    if (appCurrency === 'SDG') {
        options.minimumFractionDigits = 0;
        options.maximumFractionDigits = 0;
    } else {
        options.minimumFractionDigits = 2;
        options.maximumFractionDigits = 2;
    }

     try {
        return new Intl.NumberFormat(locale, options).format(amount);
    } catch (e) {
        const fallbackAmount = appCurrency === 'SDG' ? Math.round(amount) : amount.toFixed(2);
        return `${fallbackAmount.toLocaleString(language === 'ar' ? 'ar-EG-u-nu-latn' : 'en-US')} ${appCurrency}`;
    }
  }, [language, appCurrency]);

  const formatDate = useCallback((dateString: string) => {
    const locale = language === 'ar' ? 'ar-EG-u-nu-latn' : 'en-GB';
    // When dealing with 'YYYY-MM-DD', create the date as UTC to avoid timezone shifts.
    const date = new Date(dateString);
    const userTimezoneOffset = date.getTimezoneOffset() * 60000;
    const dateInUTC = new Date(date.getTime() + userTimezoneOffset);

    return new Intl.DateTimeFormat(locale, {
        day: '2-digit',
        month: 'short',
        year: 'numeric'
    }).format(dateInUTC);
  }, [language]);


  const value = { language, setLanguage, dir, t, appCurrency, setAppCurrency, formatCurrency, formatDate };

  return (
    <LocalizationContext.Provider value={value}>
      {children}
    </LocalizationContext.Provider>
  );
};

export const useLocalization = (): LocalizationContextType => {
  const context = useContext(LocalizationContext);
  if (context === undefined) {
    throw new Error('useLocalization must be used within a LocalizationProvider');
  }
  return context;
};