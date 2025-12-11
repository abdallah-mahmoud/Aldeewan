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
  String get dashboard => 'لوحة التحكم';

  @override
  String get recentTransactions => 'أحدث المعاملات';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get addPerson => 'إضافة شخص';

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
  String get developerName => 'عبدالله محمود';

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
  String get debt => 'دين';

  @override
  String get payment => 'دفعة';

  @override
  String get credit => 'ائتمان';

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
  String get addCashEntry => 'إضافة معاملة نقدية';

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
  String get savedSuccessfully => 'تم الحفظ بنجاح';

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم';

  @override
  String get netPosition => 'صافي المركز المالي';

  @override
  String get customersOweYouMore => 'العملاء مدينون لك بأكثر';

  @override
  String get youOweSuppliersMore => 'أنت مدين للموردين بأكثر';

  @override
  String get all => 'الكل';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get saleOnCredit => 'بيع (آجل)';

  @override
  String get paymentReceived => 'استلام دفعة';

  @override
  String get purchaseOnCredit => 'شراء (آجل)';

  @override
  String get paymentMade => 'دفع دفعة';

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
  String get receivable => 'لنا';

  @override
  String get payable => 'علينا';

  @override
  String get advance => 'مقدم';

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
}
