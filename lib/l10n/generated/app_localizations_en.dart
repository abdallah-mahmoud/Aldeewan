// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aldeewan';

  @override
  String get appTitle => 'Aldeewan';

  @override
  String get home => 'Home';

  @override
  String get ledger => 'Ledger';

  @override
  String get cashbook => 'Cashbook';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addPerson => 'Add Person';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backupData => 'Backup Data (JSON)';

  @override
  String get backupDataSubtitle => 'Export all data to a JSON file';

  @override
  String get restoreData => 'Restore Data (JSON)';

  @override
  String get restoreDataSubtitle =>
      'Import data from a JSON file (Replaces current data)';

  @override
  String get exportPersons => 'Export Persons (CSV)';

  @override
  String get exportTransactions => 'Export Transactions (CSV)';

  @override
  String get personStatement => 'Person Statement';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get aboutDeveloper => 'About Developer';

  @override
  String get currency => 'Currency';

  @override
  String get currencyOptions => 'Currency Options';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String restoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get exportSuccess => 'Export successful';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get developerName => '@motaasl8';

  @override
  String get developerEmail => 'contact@example.com';

  @override
  String get version => 'Version';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get category => 'Category';

  @override
  String get type => 'Type';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get selectPerson => 'Select Person';

  @override
  String get customer => 'Customer';

  @override
  String get supplier => 'Supplier';

  @override
  String get unknown => 'Unknown';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get generateReport => 'Generate Report';

  @override
  String statementFor(Object name) {
    return 'Statement for $name';
  }

  @override
  String period(Object end, Object start) {
    return 'Period: $start - $end';
  }

  @override
  String get balanceBroughtForward => 'Balance Brought Forward';

  @override
  String get closingBalance => 'Closing Balance';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get debt => 'Debt';

  @override
  String get payment => 'Payment';

  @override
  String get credit => 'Credit';

  @override
  String get transaction => 'Transaction';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get netProfitLoss => 'Net Profit/Loss';

  @override
  String get cashFlowReport => 'Cash Flow Report';

  @override
  String get developerTagline =>
      'Media | Photography | Editing | Design | Web | Software Dev \"Professional, Quality and Art\" #motaasl';

  @override
  String get openSourceLink => 'View on GitHub';

  @override
  String get islamicEndowment =>
      'This app is an Islamic charitable endowment (Waqf).';

  @override
  String get facebook => 'Facebook';

  @override
  String get instagram => 'Instagram';

  @override
  String get email => 'Email';

  @override
  String get tagline => 'Your Personal Ledger & Cashbook';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get addCashEntry => 'Add Cash Entry';

  @override
  String get viewBalances => 'View Balances';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get totalReceivable => 'Total Receivable';

  @override
  String get totalPayable => 'Total Payable';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get monthlyExpense => 'Monthly Expense';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get netPosition => 'Net Position';

  @override
  String get customersOweYouMore => 'Customers owe you more';

  @override
  String get youOweSuppliersMore => 'You owe suppliers more';

  @override
  String get all => 'All';

  @override
  String get thisMonth => 'This Month';

  @override
  String get saleOnCredit => 'Sale (Credit)';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get purchaseOnCredit => 'Purchase (Credit)';

  @override
  String get paymentMade => 'Payment Made';

  @override
  String get cashSale => 'Cash Sale';

  @override
  String get cashIncome => 'Extra Income';

  @override
  String get cashExpense => 'Expenses';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get settled => 'Settled';

  @override
  String get receivable => 'Receivable';

  @override
  String get payable => 'Payable';

  @override
  String get advance => 'Advance';

  @override
  String get analytics => 'Analytics';

  @override
  String get budgets => 'Budgets';

  @override
  String get goals => 'Goals';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get myAccounts => 'My Accounts';

  @override
  String get syncAccounts => 'Sync Accounts';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get budgetSummary => 'Budget Summary';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentSaved => 'Current Saved';

  @override
  String get addToGoal => 'Add to Goal';

  @override
  String get connectBank => 'Connect Bank';

  @override
  String get selectProvider => 'Select Provider';
}
