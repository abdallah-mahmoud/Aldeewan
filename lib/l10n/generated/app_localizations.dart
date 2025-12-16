import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Secure Financial Management'**
  String get appSlogan;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @cashbook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook'**
  String get cashbook;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get addPerson;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @addPersonPrompt.
  ///
  /// In en, this message translates to:
  /// **'You need to add a person before adding a transaction'**
  String get addPersonPrompt;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data (JSON)'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all data to a JSON file'**
  String get backupDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data (JSON)'**
  String get restoreData;

  /// No description provided for @restoreDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from a JSON file (Replaces current data)'**
  String get restoreDataSubtitle;

  /// No description provided for @exportPersons.
  ///
  /// In en, this message translates to:
  /// **'Export Persons (CSV)'**
  String get exportPersons;

  /// No description provided for @exportTransactions.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions (CSV)'**
  String get exportTransactions;

  /// No description provided for @personStatement.
  ///
  /// In en, this message translates to:
  /// **'Person Statement'**
  String get personStatement;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyOptions.
  ///
  /// In en, this message translates to:
  /// **'Currency Options'**
  String get currencyOptions;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'@motaasl8'**
  String get developerName;

  /// No description provided for @developerEmail.
  ///
  /// In en, this message translates to:
  /// **'abdo13-m.azme@hotmail.com'**
  String get developerEmail;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @selectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select Person'**
  String get selectPerson;

  /// No description provided for @noPersonsFound.
  ///
  /// In en, this message translates to:
  /// **'No persons found'**
  String get noPersonsFound;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @statementFor.
  ///
  /// In en, this message translates to:
  /// **'Statement for {name}'**
  String statementFor(Object name);

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} - {end}'**
  String period(Object end, Object start);

  /// No description provided for @balanceBroughtForward.
  ///
  /// In en, this message translates to:
  /// **'Balance Brought Forward'**
  String get balanceBroughtForward;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get closingBalance;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @netProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Profit/Loss'**
  String get netProfitLoss;

  /// No description provided for @cashFlowReport.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Report'**
  String get cashFlowReport;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Motaasl'**
  String get madeWithLove;

  /// No description provided for @appVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan Mobile v{version}'**
  String appVersionInfo(String version);

  /// No description provided for @developerTagline.
  ///
  /// In en, this message translates to:
  /// **'Media | Photography | Editing | Design | Web | Software Dev \"Professional, Quality and Art\" #motaasl'**
  String get developerTagline;

  /// No description provided for @openSourceLink.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get openSourceLink;

  /// No description provided for @islamicEndowment.
  ///
  /// In en, this message translates to:
  /// **'This app is an Islamic charitable endowment (Waqf).'**
  String get islamicEndowment;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Ledger & Cashbook'**
  String get tagline;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @addCashEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addCashEntry;

  /// No description provided for @viewBalances.
  ///
  /// In en, this message translates to:
  /// **'View Balances'**
  String get viewBalances;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @totalReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable'**
  String get totalReceivable;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// No description provided for @monthlyExpense.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expense'**
  String get monthlyExpense;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirm;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashLabel;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankLabel;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addToLedger.
  ///
  /// In en, this message translates to:
  /// **'Add to Ledger (Debt/Credit)'**
  String get addToLedger;

  /// No description provided for @addToLedgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requires selecting a person'**
  String get addToLedgerSubtitle;

  /// No description provided for @addToCashbook.
  ///
  /// In en, this message translates to:
  /// **'Add to Cashbook (Income/Expense)'**
  String get addToCashbook;

  /// No description provided for @addToCashbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No person required'**
  String get addToCashbookSubtitle;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Error scanning receipt: {error}'**
  String scanError(Object error);

  /// No description provided for @scanTimeout.
  ///
  /// In en, this message translates to:
  /// **'Scanning timed out'**
  String get scanTimeout;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Reached'**
  String goalReached(Object percent);

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String targetLabel(Object amount);

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Goal Progress'**
  String get goalProgress;

  /// No description provided for @budgetUsage.
  ///
  /// In en, this message translates to:
  /// **'Budget Usage {percentage}'**
  String budgetUsage(Object percentage);

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @netPosition.
  ///
  /// In en, this message translates to:
  /// **'Net Position'**
  String get netPosition;

  /// No description provided for @customersOweYouMore.
  ///
  /// In en, this message translates to:
  /// **'Customers owe you more'**
  String get customersOweYouMore;

  /// No description provided for @youOweSuppliersMore.
  ///
  /// In en, this message translates to:
  /// **'You owe suppliers more'**
  String get youOweSuppliersMore;

  /// No description provided for @profitThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Profit this month'**
  String get profitThisMonth;

  /// No description provided for @lossThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Loss this month'**
  String get lossThisMonth;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @saleOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Sale (Credit)'**
  String get saleOnCredit;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @purchaseOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Purchase (Credit)'**
  String get purchaseOnCredit;

  /// No description provided for @paymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment Made'**
  String get paymentMade;

  /// No description provided for @debtGiven.
  ///
  /// In en, this message translates to:
  /// **'Debt (Owed by)'**
  String get debtGiven;

  /// No description provided for @debtTaken.
  ///
  /// In en, this message translates to:
  /// **'Debt (Owed to)'**
  String get debtTaken;

  /// No description provided for @cashSale.
  ///
  /// In en, this message translates to:
  /// **'Cash Sale'**
  String get cashSale;

  /// No description provided for @cashIncome.
  ///
  /// In en, this message translates to:
  /// **'Extra Income'**
  String get cashIncome;

  /// No description provided for @cashExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get cashExpense;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @receivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivable;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payable;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccounts;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @syncAccounts.
  ///
  /// In en, this message translates to:
  /// **'Sync Accounts'**
  String get syncAccounts;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @budgetSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget Summary'**
  String get budgetSummary;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentSaved.
  ///
  /// In en, this message translates to:
  /// **'Current Saved'**
  String get currentSaved;

  /// No description provided for @addToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to Goal'**
  String get addToGoal;

  /// No description provided for @connectBank.
  ///
  /// In en, this message translates to:
  /// **'Connect Bank'**
  String get connectBank;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select Provider'**
  String get selectProvider;

  /// No description provided for @noExpensesToShow.
  ///
  /// In en, this message translates to:
  /// **'No expenses to show'**
  String get noExpensesToShow;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get appLocked;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @linkBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Link your bank account'**
  String get linkBankAccount;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get errorLoadingAccounts;

  /// No description provided for @personNotFound.
  ///
  /// In en, this message translates to:
  /// **'Person Not Found'**
  String get personNotFound;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require authentication to open app'**
  String get appLockSubtitle;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock App'**
  String get unlockApp;

  /// No description provided for @accountLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get accountLinkedSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check credentials.'**
  String get authFailed;

  /// No description provided for @linkBankAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Bank Account'**
  String get linkBankAccountTitle;

  /// No description provided for @connectAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Account'**
  String get connectAccount;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @simpleModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use simplified terminology (Lent/Borrowed)'**
  String get simpleModeSubtitle;

  /// No description provided for @simpleLent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get simpleLent;

  /// No description provided for @simpleBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get simpleBorrowed;

  /// No description provided for @simpleGotPaid.
  ///
  /// In en, this message translates to:
  /// **'Got Paid'**
  String get simpleGotPaid;

  /// No description provided for @simplePaidBack.
  ///
  /// In en, this message translates to:
  /// **'Paid Back'**
  String get simplePaidBack;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @currencyQAR.
  ///
  /// In en, this message translates to:
  /// **'QAR (ر.ق)'**
  String get currencyQAR;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'SAR (ر.س)'**
  String get currencySAR;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'EGP (ج.م)'**
  String get currencyEGP;

  /// No description provided for @currencySDG.
  ///
  /// In en, this message translates to:
  /// **'Sudanese Pound (SDG)'**
  String get currencySDG;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar (KWD)'**
  String get currencyKWD;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"?'**
  String deleteCategoryContent(Object categoryName);

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryTitle;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Type: '**
  String get categoryType;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get catFood;

  /// No description provided for @catTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get catTransportation;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get catIncome;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get catSavings;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @budgetExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your budget by {currency} {amount}'**
  String budgetExceededMessage(String currency, String amount);

  /// No description provided for @budgetRemainingMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {currency} {amount} remaining'**
  String budgetRemainingMessage(String currency, String amount);

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get deleteBudgetConfirmation;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get deleteGoalConfirmation;

  /// No description provided for @goalDetails.
  ///
  /// In en, this message translates to:
  /// **'Goal Details'**
  String get goalDetails;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget Details'**
  String get budgetDetails;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get addFunds;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @goalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalNotFound;

  /// No description provided for @budgetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Budget not found'**
  String get budgetNotFound;

  /// No description provided for @goalExceededError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add funds. Total saved would exceed the target amount.'**
  String get goalExceededError;

  /// No description provided for @budgetExceededError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add expense. Total spent would exceed the budget limit.'**
  String get budgetExceededError;

  /// No description provided for @goalExceededErrorWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cannot add funds. You can only add up to {amount}.'**
  String goalExceededErrorWithRemaining(String amount);

  /// No description provided for @budgetExceededErrorWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cannot add expense. You only have {amount} remaining in this budget.'**
  String budgetExceededErrorWithRemaining(String amount);

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No Date'**
  String get noDate;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @appSounds.
  ///
  /// In en, this message translates to:
  /// **'App Sounds'**
  String get appSounds;

  /// No description provided for @appSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable sound effects'**
  String get appSoundsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a daily reminder to record your transactions'**
  String get dailyReminderSubtitle;

  /// No description provided for @authenticateReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access Aldeewan'**
  String get authenticateReason;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to record your transactions for today!'**
  String get dailyReminderBody;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @budgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceededTitle;

  /// No description provided for @budgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your budget for {category} by {amount} {currency}.'**
  String budgetExceededBody(String category, String amount, String currency);

  /// No description provided for @goalReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached!'**
  String get goalReachedTitle;

  /// No description provided for @goalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have reached your goal: {goalName}.'**
  String goalReachedBody(String goalName);

  /// No description provided for @insufficientFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Funds'**
  String get insufficientFundsTitle;

  /// No description provided for @insufficientFundsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current balance ({balance} {currency}) is not enough for this expense of {amount} {currency}. Please add more funds first.'**
  String insufficientFundsMessage(
    String balance,
    String currency,
    String amount,
  );

  /// No description provided for @tourWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aldeewan!'**
  String get tourWelcome;

  /// No description provided for @tourDashboard.
  ///
  /// In en, this message translates to:
  /// **'See your money at a glance'**
  String get tourDashboard;

  /// No description provided for @tourAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add money in or out'**
  String get tourAddTransaction;

  /// No description provided for @tourLedger.
  ///
  /// In en, this message translates to:
  /// **'People who owe you or you owe them'**
  String get tourLedger;

  /// No description provided for @tourCashbook.
  ///
  /// In en, this message translates to:
  /// **'Filter by income or expenses'**
  String get tourCashbook;

  /// No description provided for @tourSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, amount, or type'**
  String get tourSearch;

  /// No description provided for @tourHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Come here anytime'**
  String get tourHelp;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @tourFinish.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get tourFinish;

  /// No description provided for @tourPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get tourPrevious;

  /// No description provided for @tipQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Use Quick Actions for faster entry'**
  String get tipQuickActions;

  /// No description provided for @tipFilterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter and search transactions by date, type, or name'**
  String get tipFilterTransactions;

  /// No description provided for @tipPersonBalance.
  ///
  /// In en, this message translates to:
  /// **'Tap a person to see their account'**
  String get tipPersonBalance;

  /// No description provided for @tipBudgetAlert.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tell you if you spend too much'**
  String get tipBudgetAlert;

  /// No description provided for @tipGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your savings here'**
  String get tipGoalProgress;

  /// No description provided for @tipExportReport.
  ///
  /// In en, this message translates to:
  /// **'Save reports as files'**
  String get tipExportReport;

  /// No description provided for @tipGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipGotIt;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and tutorials'**
  String get helpCenterSubtitle;

  /// No description provided for @restartTour.
  ///
  /// In en, this message translates to:
  /// **'Restart Tutorial'**
  String get restartTour;

  /// No description provided for @restartTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the app guide again'**
  String get restartTourSubtitle;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Need help? Reach out to us'**
  String get contactSupportSubtitle;

  /// No description provided for @faqGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get faqGettingStarted;

  /// No description provided for @faqWhatIsAldeewan.
  ///
  /// In en, this message translates to:
  /// **'What is Aldeewan?'**
  String get faqWhatIsAldeewan;

  /// No description provided for @faqWhatIsAldeewaAnswer.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan is a smart accounting app to manage your money, track debts, and set budgets.'**
  String get faqWhatIsAldeewaAnswer;

  /// No description provided for @faqHowToAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'How to add a transaction?'**
  String get faqHowToAddTransaction;

  /// No description provided for @faqHowToAddTransactionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button on any screen to add income or expense.'**
  String get faqHowToAddTransactionAnswer;

  /// No description provided for @faqCashbook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook'**
  String get faqCashbook;

  /// No description provided for @faqLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get faqLedger;

  /// No description provided for @faqBudgetsGoals.
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get faqBudgetsGoals;

  /// No description provided for @faqReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get faqReports;

  /// No description provided for @faqSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get faqSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
