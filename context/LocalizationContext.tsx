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
  appTimezone: string;
  setAppTimezone: (timezone: string) => void;
  getTodayDateString: () => string;
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
    totalReceivable: 'إجمالي المستحق لك',
    totalPayable: 'إجمالي الدفع',
    monthlyIncome: 'دخل الشهر',
    monthlyExpense: 'مصروفات الشهر',
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
    balance: 'الرصيد',
    ledgerOf: 'سجل',
    noEntriesYet: 'لا توجد سجلات حتى الآن.',
    search_no_results: 'لم يتم العثور على نتائج.',
    ledger_empty_title: 'لا يوجد عملاء أو موردون بعد',
    ledger_empty_message: 'اضغط على زر إضافة شخص لبدء تسجيل ديونك.',
    // Cashbook Screen
    incomeAndExpenses: 'الدخل والمصروفات',
    income: 'دخل',
    custom_range: 'فترة مخصصة',
    expense: 'مصروف',
    totalIncome: 'إجمالي الدخل',
    totalExpense: 'إجمالي المصروفات',
    netFlow: 'صافي التدفق',
    cashbook_empty_title: 'دفتر النقدية فارغ',
    cashbook_empty_message: 'اضغط على زر الإضافة لتسجيل أول عملية دخل أو مصروف.',
    // Reports Screen
    generateReports: 'إنشاء تقارير',
    exportAsPDF: 'تصدير PDF',
    exportAsCSV: 'تصدير CSV',
    featureComingSoon: 'هذه الميزة ستتوفر قريباً',
    selectReportType: 'اختر نوع التقرير',
    personStatement: 'كشف حساب شخص',
    cashFlowReport: 'تقرير التدفق النقدي',
    fullDataExport: 'تصدير كل البيانات',
    generateStatementFor: 'أنشئ كشف حساب لعميل أو مورد خلال فترة محددة.',
    viewIncomeVsExpense: 'عرض ملخص الدخل والمصروفات حسب الفئة.',
    exportAllYourData: 'تصدير بيانات الأشخاص والمعاملات إلى ملفات CSV.',
    selectDateRange: 'اختر فترة زمنية',
    startDate: 'تاريخ البدء',
    endDate: 'تاريخ الانتهاء',
    generate: 'إنشاء',
    exportTransactions: 'تصدير المعاملات',
    exportPersons: 'تصدير الأشخاص',
    allTransactions: 'جميع المعاملات',
    allPersons: 'جميع الأشخاص',
    thisMonth: 'هذا الشهر',
    lastMonth: 'الشهر الماضي',
    thisQuarter: 'هذا الربع',
    noDataForPeriod: 'لا توجد بيانات للفترة المحددة.',
    profitLoss: 'الربح والخسارة',
    profit: 'ربح',
    loss: 'خسارة',
    totalCashIn: 'إجمالي المقبوضات',
    totalCashOut: 'إجمالي المدفوعات',
    // Settings Screen
    theme: 'المظهر',
    light: 'فاتح',
    dark: 'داكن',
    system: 'النظام',
    currency: 'العملة',
    timezone: 'المنطقة الزمنية',
    // Data Management
    dataManagement: 'إدارة البيانات',
    exportData: 'تصدير البيانات',
    exportDataDesc: 'احفظ نسخة احتياطية من كل بياناتك في ملف JSON.',
    importData: 'استيراد البيانات',
    importDataDesc: 'استعد بياناتك من ملف نسخة احتياطية. سيؤدي هذا إلى استبدال كافة البيانات الحالية.',
    confirmImportTitle: 'تأكيد الاستيراد',
    confirmImportMessage: 'هل أنت متأكد من استيراد هذا الملف؟ سيتم استبدال جميع البيانات الحالية بشكل دائم. لا يمكن التراجع عن هذا الإجراء.',
    importSuccess: 'تم استيراد البيانات بنجاح!',
    importError: 'فشل الاستيراد. يرجى التحقق من الملف والمحاولة مرة أخرى.',
    exportError: 'فشل التصدير. يرجى المحاولة مرة أخرى.',
    replace: 'استبدال',
    // General
    overdue: 'متأخر عن السداد',
    receivable: 'مستحق لك',
    payable: 'مستحق عليك',
    creditBalance: 'رصيد دائن',
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
    qar: 'ريال قطري',
    egp: 'جنيه مصري',
    'Africa/Khartoum': 'السودان (توقيت وسط أفريقيا)',
    'Africa/Cairo': 'مصر (توقيت شرق أوروبا)',
    'Asia/Riyadh': 'السعودية (توقيت السعودية)',
    'Asia/Qatar': 'قطر (التوقيت الرسمي العربي)',
    // Transaction Types
    sale_on_credit: 'بيع آجل',
    payment_received: 'استلام دفعة',
    purchase_on_credit: 'شراء آجل',
    payment_made: 'تسديد دفعة',
    cash_sale: 'بيع نقدي',
    cash_income: 'دخل نقدي',
    cash_expense: 'مصروف نقدي',
    // Sharing
    share: 'مشاركة',
    // Statement Export
    statement_header: '--- كشف حساب ---',
    statement_from: 'من',
    statement_to: 'إلى',
    statement_date: 'التاريخ',
    statement_summary_header: '--- ملخص الرصيد ---',
    statement_final_balance_due: 'إجمالي المبلغ المستحق عليك',
    statement_final_balance_credit: 'رصيدك الدائن لدينا',
    statement_final_balance_payable: 'إجمالي المبلغ المستحق للمورد',
    statement_tx_history_header: '--- سجل المعاملات ---',
    statement_tx_note_prefix: 'ملاحظة',
    statement_tx_running_balance_prefix: 'الرصيد بعد العملية',
    statement_footer_thanks: 'شكراً لتعاملكم معنا.',
    statement_footer_generated_by: 'تم إنشاؤه بواسطة تطبيق الديوان',
    customer_tx_debt: 'شراء جديد / دين',
    customer_tx_payment: 'سداد دفعة',
    supplier_tx_debt: 'توريد جديد / دين',
    supplier_tx_payment: 'تسديد دفعة',
    // Validation Errors
    error_amount_positive: 'يجب أن يكون المبلغ أكبر من صفر.',
    error_name_required: 'الاسم مطلوب ولا يمكن أن يكون فارغاً.',
    error_category_required: 'الفئة مطلوبة ولا يمكن أن تكون فارغة.',
    // Onboarding
    welcome_title: 'أهلاً بك في الديوان',
    welcome_message: 'تطبيقك لإدارة الديون والحسابات اليومية ببساطة. كيف تود أن تبدأ؟',
    onboarding_seed_title: 'ابدأ ببيانات تجريبية',
    onboarding_seed_desc: 'مثالي لاستكشاف التطبيق وفهم ميزاته.',
    onboarding_fresh_title: 'ابدأ بسجل نظيف',
    onboarding_fresh_desc: 'جاهز لإضافة عملائك ومعاملاتك الخاصة.',
    // Toasts
    toast_saved_successfully: 'تم الحفظ بنجاح',
    toast_deleted_successfully: 'تم الحذف بنجاح',
    toast_person_added: 'تمت إضافة الشخص بنجاح',
    toast_copied_clipboard: 'تم النسخ إلى الحافظة',
    // Filters
    filter_no_results_title: 'لا توجد نتائج مطابقة',
    filter_no_results_message: 'جرّب تعديل فلاتر البحث للحصول على نتائج أفضل.',
    filters: 'الفلاتر',
    all: 'الكل',
    customers: 'العملاء',
    suppliers: 'الموردون',
    overdue_balances: 'أرصدة متأخرة',
    by_date: 'حسب التاريخ',
    by_type: 'حسب النوع',
    reset: 'إعادة تعيين',
    search_by_category_note: 'ابحث بالفئة أو الملاحظة...',
    // About Me
    about_developer: 'عن المطور',
    developer_name: '@motaasl8',
    developer_tagline: 'ميديا | تصوير | مونتاج | تصميم | ويب | تطوير برمجيات "احترافية وجودة وفن" #motaasl',
    open_source_link: 'عرض على GitHub',
    islamic_endowment: 'هذا التطبيق وقف إسلامي خيري',
    facebook: 'فيسبوك',
    instagram: 'انستغرام',
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
    monthlyIncome: 'This Month\'s Income',
    monthlyExpense: 'This Month\'s Expense',
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
    noEntriesYet: 'No entries yet.',
    search_no_results: 'No results found.',
    ledger_empty_title: 'No Customers or Suppliers Yet',
    ledger_empty_message: "Tap the 'Add Person' button to start tracking your debts.",
    // Cashbook Screen
    incomeAndExpenses: 'Income & Expenses',
    income: 'Income',
    expense: 'Expense',
    custom_range: 'Custom Range',
    totalIncome: 'Total Income',
    totalExpense: 'Total Expense',
    netFlow: 'Net Flow',
    cashbook_empty_title: 'Your Cashbook is Empty',
    cashbook_empty_message: "Tap the '+' button to record your first income or expense.",
    // Reports Screen
    generateReports: 'Generate Reports',
    exportAsPDF: 'Export as PDF',
    exportAsCSV: 'Export as CSV',
    featureComingSoon: 'This feature is coming soon',
    selectReportType: 'Select Report Type',
    personStatement: 'Person Statement',
    cashFlowReport: 'Cash Flow Report',
    fullDataExport: 'Full Data Export',
    generateStatementFor: 'Generate a statement for a customer or supplier.',
    viewIncomeVsExpense: 'View a summary of income vs. expenses by category.',
    exportAllYourData: 'Export all persons and transactions data to CSV files.',
    selectDateRange: 'Select Date Range',
    startDate: 'Start Date',
    endDate: 'End Date',
    generate: 'Generate',
    exportTransactions: 'Export Transactions',
    exportPersons: 'Export Persons',
    allTransactions: 'All Transactions',
    allPersons: 'All Persons',
    thisMonth: 'This Month',
    lastMonth: 'Last Month',
    thisQuarter: 'This Quarter',
    noDataForPeriod: 'No data available for the selected period.',
    profitLoss: 'Profit & Loss',
    profit: 'Profit',
    loss: 'Loss',
    totalCashIn: 'Total Cash In',
    totalCashOut: 'Total Cash Out',
    // Settings Screen
    theme: 'Theme',
    light: 'Light',
    dark: 'Dark',
    system: 'System',
    currency: 'Currency',
    timezone: 'Timezone',
    // Data Management
    dataManagement: 'Data Management',
    exportData: 'Export Data',
    exportDataDesc: 'Save a backup of all your data to a JSON file.',
    importData: 'Import Data',
    importDataDesc: 'Restore data from a backup file. This will replace all current data.',
    confirmImportTitle: 'Confirm Import',
    confirmImportMessage: 'Are you sure you want to import this file? All existing data will be permanently replaced. This action cannot be undone.',
    importSuccess: 'Data imported successfully!',
    importError: 'Import failed. Please check the file and try again.',
    exportError: 'Export failed. Please try again.',
    replace: 'Replace',
    // General
    overdue: 'Overdue',
    receivable: 'Receivable',
    payable: 'Payable',
    creditBalance: 'Credit Balance',
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
    qar: 'Qatari Riyal',
    egp: 'Egyptian Pound',
    'Africa/Khartoum': 'Sudan (CAT)',
    'Africa/Cairo': 'Egypt (EET)',
    'Asia/Riyadh': 'Saudi Arabia (AST)',
    'Asia/Qatar': 'Qatar (AST)',
    // Transaction Types
    sale_on_credit: 'Sale on Credit',
    payment_received: 'Payment Received',
    purchase_on_credit: 'Purchase on Credit',
    payment_made: 'Payment Made',
    cash_sale: 'Cash Sale',
    cash_income: 'Cash Income',
    cash_expense: 'Cash Expense',
    // Sharing
    share: 'Share',
    // Statement Export
    statement_header: '--- Account Statement ---',
    statement_from: 'From',
    statement_to: 'To',
    statement_date: 'Date',
    statement_summary_header: '--- Balance Summary ---',
    statement_final_balance_due: 'Total Amount Due',
    statement_final_balance_credit: 'Your Credit Balance',
    statement_final_balance_payable: 'Total Amount Owed to Supplier',
    statement_tx_history_header: '--- Transaction History ---',
    statement_tx_note_prefix: 'Note',
    statement_tx_running_balance_prefix: 'Running Balance',
    statement_footer_thanks: 'Thank you for your business.',
    statement_footer_generated_by: 'Generated by AlDeewan App',
    customer_tx_debt: 'New Purchase / Debt',
    customer_tx_payment: 'Payment Made',
    supplier_tx_debt: 'New Supply / Debt',
    supplier_tx_payment: 'Payment Received',
    // Validation Errors
    error_amount_positive: 'Amount must be greater than zero.',
    error_name_required: 'Name is required and cannot be empty.',
    error_category_required: 'Category is required and cannot be empty.',
    // Onboarding
    welcome_title: 'Welcome to AlDeewan',
    welcome_message: 'Your simple app for managing debts and daily accounts. How would you like to start?',
    onboarding_seed_title: 'Start with Demo Data',
    onboarding_seed_desc: 'Perfect for exploring the app and its features.',
    onboarding_fresh_title: 'Start with a Clean Slate',
    onboarding_fresh_desc: 'Ready to add your own customers and transactions.',
    // Toasts
    toast_saved_successfully: 'Saved successfully',
    toast_deleted_successfully: 'Deleted successfully',
    toast_person_added: 'Person added successfully',
    toast_copied_clipboard: 'Copied to clipboard',
    // Filters
    filter_no_results_title: 'No Matching Results',
    filter_no_results_message: "Try adjusting your search filters to find what you're looking for.",
    filters: 'Filters',
    all: 'All',
    customers: 'Customers',
    suppliers: 'Suppliers',
    overdue_balances: 'Overdue Balances',
    by_date: 'By Date',
    by_type: 'By Type',
    reset: 'Reset',
    search_by_category_note: 'Search by category or note...',
    // About Me
    about_developer: 'About the Developer',
    developer_name: '@motaasl8',
    developer_tagline: 'Media | Photography | Editing | Design | Web | Software Dev "Professional, Quality and Art" #motaasl',
    open_source_link: 'View on GitHub',
    islamic_endowment: 'This app is an Islamic charitable endowment (Waqf).',
    facebook: 'Facebook',
    instagram: 'Instagram',
  },
};

const LocalizationContext = createContext<LocalizationContextType | undefined>(undefined);

export const LocalizationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguage] = useState<Language>('ar');
  const [dir, setDir] = useState<Direction>('rtl');
  const [appCurrency, setAppCurrencyState] = useState<string>(() => localStorage.getItem('appCurrency') || 'SDG');
  const [appTimezone, setAppTimezoneState] = useState<string>(() => localStorage.getItem('appTimezone') || 'Africa/Khartoum');

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
  
  const setAppTimezone = useCallback((timezone: string) => {
    localStorage.setItem('appTimezone', timezone);
    setAppTimezoneState(timezone);
  }, []);

  const t = useCallback((key: string): string => {
    return translations[language][key] || key;
  }, [language]);

  const getTodayDateString = useCallback(() => {
    // Returns 'YYYY-MM-DD' for the current day in the selected timezone.
    // 'en-CA' locale format is consistently YYYY-MM-DD.
    try {
        const formatter = new Intl.DateTimeFormat('en-CA', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            timeZone: appTimezone,
        });
        return formatter.format(new Date());
    } catch (e) {
        // Fallback for environments with limited timezone support.
        console.error("Timezone formatting failed, falling back to local date:", e);
        const today = new Date();
        const y = today.getFullYear();
        const m = String(today.getMonth() + 1).padStart(2, '0');
        const d = String(today.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }
  }, [appTimezone]);

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
    const date = new Date(dateString);

    return new Intl.DateTimeFormat(locale, {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        timeZone: appTimezone,
    }).format(date);
  }, [language, appTimezone]);


  const value = { language, setLanguage, dir, t, appCurrency, setAppCurrency, appTimezone, setAppTimezone, getTodayDateString, formatCurrency, formatDate };

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