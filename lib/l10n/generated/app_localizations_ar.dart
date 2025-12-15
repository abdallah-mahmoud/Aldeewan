// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الديوان';

  @override
  String get appTitle => 'الديوان';

  @override
  String get appSlogan => 'إدارة مالية آمنة';

  @override
  String get home => 'الرئيسية';

  @override
  String get ledger => 'الدفتر';

  @override
  String get cashbook => 'الصندوق';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get general => 'عام';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get search => 'بحث...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get addPersonPrompt => 'تحتاج إلى إضافة شخص قبل إضافة معاملة';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get backupData => 'نسخ احتياطي (JSON)';

  @override
  String get backupDataSubtitle => 'تصدير جميع البيانات إلى ملف JSON';

  @override
  String get restoreData => 'استعادة البيانات (JSON)';

  @override
  String get restoreDataSubtitle =>
      'استيراد البيانات من ملف JSON (يستبدل البيانات الحالية)';

  @override
  String get exportPersons => 'تصدير الأشخاص (CSV)';

  @override
  String get exportTransactions => 'تصدير المعاملات (CSV)';

  @override
  String get personStatement => 'كشف حساب';

  @override
  String get cashFlow => 'التدفق النقدي';

  @override
  String get aboutDeveloper => 'عن المطور';

  @override
  String get currency => 'العملة';

  @override
  String get currencyOptions => 'خيارات العملة';

  @override
  String get backupSuccess => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String backupFailed(Object error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get restoreSuccess => 'تم استعادة البيانات بنجاح';

  @override
  String restoreFailed(Object error) {
    return 'فشل الاستعادة: $error';
  }

  @override
  String get exportSuccess => 'تم التصدير بنجاح';

  @override
  String exportFailed(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get developerName => 'متآصل';

  @override
  String get developerEmail => 'contact@example.com';

  @override
  String get version => 'الإصدار';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get role => 'الدور';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get note => 'ملاحظة';

  @override
  String get category => 'التصنيف';

  @override
  String get type => 'النوع';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'صرف';

  @override
  String get selectPerson => 'اختر الشخص';

  @override
  String get noPersonsFound => 'لا يوجد أشخاص';

  @override
  String get customer => 'عميل';

  @override
  String get supplier => 'مورد';

  @override
  String get unknown => 'غير معروف';

  @override
  String get dateRange => 'الفترة الزمنية';

  @override
  String get selectDateRange => 'اختر الفترة';

  @override
  String get generateReport => 'إنشاء التقرير';

  @override
  String statementFor(Object name) {
    return 'كشف حساب $name';
  }

  @override
  String period(Object end, Object start) {
    return 'الفترة: $start - $end';
  }

  @override
  String get balanceBroughtForward => 'الرصيد المرحل';

  @override
  String get closingBalance => 'الرصيد الختامي';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get debt => 'دين (لنا)';

  @override
  String get payment => 'دفعة';

  @override
  String get credit => 'دين (علينا)';

  @override
  String get transaction => 'معاملة';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get totalExpense => 'إجمالي المصروفات';

  @override
  String get netProfitLoss => 'صافي الربح/الخسارة';

  @override
  String get cashFlowReport => 'تقرير التدفق النقدي';

  @override
  String get madeWithLove => 'صنع بـ ❤️ بواسطة متآصل';

  @override
  String appVersionInfo(String version) {
    return 'الديوان موبايل إصدار $version';
  }

  @override
  String get developerTagline =>
      'ميديا | تصوير | مونتاج | تصميم | ويب | تطوير برمجيات \"احترافية وجودة وفن\" #motaasl';

  @override
  String get openSourceLink => 'عرض على GitHub';

  @override
  String get islamicEndowment => 'هذا التطبيق وقف إسلامي خيري';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'انستغرام';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get tagline => 'دفتر حساباتك الشخصي';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get addCashEntry => 'إضافة معاملة';

  @override
  String get viewBalances => 'عرض الأرصدة';

  @override
  String get allTransactions => 'كل المعاملات';

  @override
  String get recentActivity => 'أحدث المعاملات';

  @override
  String get noEntriesYet => 'لا توجد معاملات حتى الآن';

  @override
  String get totalReceivable => 'إجمالي المستحقات';

  @override
  String get totalPayable => 'إجمالي المطلوبات';

  @override
  String get monthlyIncome => 'الدخل الشهري';

  @override
  String get monthlyExpense => 'المصروف الشهري';

  @override
  String get transactionDetails => 'تفاصيل المعاملة';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get deleteTransactionConfirm => 'هل أنت متأكد من حذف هذه المعاملة؟';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get person => 'الشخص';

  @override
  String get savedSuccessfully => 'تم الحفظ بنجاح';

  @override
  String get cashLabel => 'نقد';

  @override
  String get bankLabel => 'بنك';

  @override
  String get camera => 'كاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get addToLedger => 'إضافة إلى الدفتر (دين/ائتمان)';

  @override
  String get addToLedgerSubtitle => 'يتطلب اختيار شخص';

  @override
  String get addToCashbook => 'إضافة إلى الصندوق (دخل/صرف)';

  @override
  String get addToCashbookSubtitle => 'لا يتطلب شخص';

  @override
  String get scanReceipt => 'مسح إيصال';

  @override
  String scanError(Object error) {
    return 'خطأ في مسح الإيصال: $error';
  }

  @override
  String get scanTimeout => 'انتهت مهلة المسح';

  @override
  String get totalSpent => 'إجمالي المصروف';

  @override
  String goalReached(Object percent) {
    return 'تم تحقيق $percent%';
  }

  @override
  String targetLabel(Object amount) {
    return 'الهدف: $amount';
  }

  @override
  String get goalProgress => 'تقدم الهدف';

  @override
  String budgetUsage(Object percentage) {
    return 'استخدام الميزانية $percentage';
  }

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم';

  @override
  String get me => 'أنا';

  @override
  String get netPosition => 'صافي المركز المالي';

  @override
  String get customersOweYouMore => 'العملاء مدينون لك بأكثر';

  @override
  String get youOweSuppliersMore => 'أنت مدين للموردين بأكثر';

  @override
  String get profitThisMonth => 'ربح هذا الشهر';

  @override
  String get lossThisMonth => 'خسارة هذا الشهر';

  @override
  String get all => 'الكل';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get custom => 'مخصص';

  @override
  String get saleOnCredit => 'بيع (آجل)';

  @override
  String get paymentReceived => 'استلام دفعة';

  @override
  String get purchaseOnCredit => 'شراء (آجل)';

  @override
  String get paymentMade => 'دفع دفعة';

  @override
  String get debtGiven => 'دين (عليه)';

  @override
  String get debtTaken => 'دين (له)';

  @override
  String get cashSale => 'بيع (نقد)';

  @override
  String get cashIncome => 'إيراد إضافي';

  @override
  String get cashExpense => 'مصروفات';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String get settled => 'خالص';

  @override
  String get receivable => 'مستحق';

  @override
  String get payable => 'مطلوب';

  @override
  String get advance => 'مستحق';

  @override
  String get analytics => 'التحليلات';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get goals => 'الأهداف';

  @override
  String get linkAccount => 'ربط حساب';

  @override
  String get myAccounts => 'حساباتي';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get syncAccounts => 'مزامنة الحسابات';

  @override
  String get expensesByCategory => 'المصروفات حسب الفئة';

  @override
  String get budgetSummary => 'ملخص الميزانية';

  @override
  String get createBudget => 'إنشاء ميزانية';

  @override
  String get createGoal => 'إنشاء هدف';

  @override
  String get goalName => 'اسم الهدف';

  @override
  String get monthlyLimit => 'الحد الشهري';

  @override
  String get targetAmount => 'المبلغ المستهدف';

  @override
  String get currentSaved => 'المدخرات الحالية';

  @override
  String get addToGoal => 'إضافة للهدف';

  @override
  String get connectBank => 'ربط البنك';

  @override
  String get selectProvider => 'اختر المزود';

  @override
  String get noExpensesToShow => 'لا توجد مصروفات لعرضها';

  @override
  String get unlock => 'فتح القفل';

  @override
  String get appLocked => 'التطبيق مقفل';

  @override
  String get link => 'ربط';

  @override
  String get linkBankAccount => 'ربط حسابك البنكي';

  @override
  String get errorLoadingAccounts => 'خطأ في تحميل الحسابات';

  @override
  String get personNotFound => 'الشخص غير موجود';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockSubtitle => 'طلب المصادقة لفتح التطبيق';

  @override
  String get unlockApp => 'فتح التطبيق';

  @override
  String get accountLinkedSuccess => 'تم ربط الحساب بنجاح!';

  @override
  String get authFailed => 'فشلت المصادقة. يرجى التحقق من البيانات.';

  @override
  String get linkBankAccountTitle => 'ربط حساب بنكي';

  @override
  String get connectAccount => 'اتصال بالحساب';

  @override
  String errorOccurred(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get simpleMode => 'الوضع البسيط';

  @override
  String get simpleModeSubtitle => 'استخدام مصطلحات مبسطة (سلف/دين)';

  @override
  String get simpleLent => 'سلفته (لنا)';

  @override
  String get simpleBorrowed => 'تسلف منه (علينا)';

  @override
  String get simpleGotPaid => 'استلمت منه';

  @override
  String get simplePaidBack => 'سددت له';

  @override
  String get english => 'English';

  @override
  String get currencyQAR => 'ريال قطري (ر.ق)';

  @override
  String get currencySAR => 'ريال سعودي (ر.س)';

  @override
  String get currencyEGP => 'جنيه مصري (ج.م)';

  @override
  String get currencySDG => 'جنيه سوداني (ج.س)';

  @override
  String get currencyKWD => 'دينار كويتي (KWD)';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get error => 'خطأ';

  @override
  String get deleteCategoryTitle => 'حذف الفئة؟';

  @override
  String deleteCategoryContent(Object categoryName) {
    return 'هل أنت متأكد أنك تريد حذف \"$categoryName\"؟';
  }

  @override
  String get newCategoryTitle => 'فئة جديدة';

  @override
  String get categoryType => 'النوع: ';

  @override
  String get selectColor => 'اختر لوناً';

  @override
  String get selectIcon => 'اختر أيقونة';

  @override
  String get create => 'إنشاء';

  @override
  String get active => 'نشط';

  @override
  String get history => 'السجل';

  @override
  String get overBudget => 'تجاوز الميزانية';

  @override
  String get remaining => 'المتبقي';

  @override
  String get spent => 'المصروف';

  @override
  String get limit => 'الحد';

  @override
  String get catHousing => 'السكن';

  @override
  String get catFood => 'الطعام';

  @override
  String get catTransportation => 'المواصلات';

  @override
  String get catHealth => 'الصحة';

  @override
  String get catEntertainment => 'الترفيه';

  @override
  String get catShopping => 'التسوق';

  @override
  String get catUtilities => 'الفواتير';

  @override
  String get catIncome => 'الدخل';

  @override
  String get catOther => 'أخرى';

  @override
  String get catSavings => 'المدخرات';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String budgetExceededMessage(String currency, String amount) {
    return 'لقد تجاوزت ميزانيتك بمقدار $currency $amount';
  }

  @override
  String budgetRemainingMessage(String currency, String amount) {
    return 'لديك $currency $amount متبقية';
  }

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get deleteBudgetConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذه الميزانية؟';

  @override
  String get deleteGoal => 'حذف الهدف';

  @override
  String get deleteGoalConfirmation => 'هل أنت متأكد أنك تريد حذف هذا الهدف؟';

  @override
  String get goalDetails => 'تفاصيل الهدف';

  @override
  String get budgetDetails => 'تفاصيل الميزانية';

  @override
  String get deadline => 'الموعد النهائي';

  @override
  String get saved => 'المدخرات';

  @override
  String get target => 'الهدف';

  @override
  String get actions => 'الإجراءات';

  @override
  String get addFunds => 'إضافة أموال';

  @override
  String get withdraw => 'سحب';

  @override
  String get goalNotFound => 'الهدف غير موجود';

  @override
  String get budgetNotFound => 'الميزانية غير موجودة';

  @override
  String get goalExceededError =>
      'لا يمكن إضافة الأموال. إجمالي المدخرات سيتجاوز المبلغ المستهدف.';

  @override
  String get budgetExceededError =>
      'لا يمكن إضافة المصروف. إجمالي المصروفات سيتجاوز حد الميزانية.';

  @override
  String goalExceededErrorWithRemaining(String amount) {
    return 'لا يمكن إضافة الأموال. يمكنك إضافة ما يصل إلى $amount فقط.';
  }

  @override
  String budgetExceededErrorWithRemaining(String amount) {
    return 'لا يمكن إضافة المصروف. لديك $amount فقط متبقية في هذه الميزانية.';
  }

  @override
  String get expenseBreakdown => 'تفاصيل المصروفات';

  @override
  String get editGoal => 'تعديل الهدف';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get noDate => 'لا يوجد تاريخ';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get appSounds => 'أصوات التطبيق';

  @override
  String get appSoundsSubtitle => 'تفعيل المؤثرات الصوتية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get dailyReminderSubtitle => 'احصل على تذكير يومي لتسجيل معاملاتك';

  @override
  String get authenticateReason => 'يرجى المصادقة للوصول إلى الديوان';

  @override
  String get dailyReminderTitle => 'تذكير يومي';

  @override
  String get dailyReminderBody => 'لا تنس تسجيل معاملاتك اليوم!';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get budgetExceededTitle => 'تجاوز الميزانية';

  @override
  String budgetExceededBody(String category, String amount, String currency) {
    return 'لقد تجاوزت ميزانيتك لفئة $category بمقدار $amount $currency.';
  }

  @override
  String get goalReachedTitle => 'تم تحقيق الهدف!';

  @override
  String goalReachedBody(String goalName) {
    return 'تهانينا! لقد حققت هدفك: $goalName.';
  }
}
