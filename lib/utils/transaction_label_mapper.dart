import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class TransactionLabelMapper {
  static String getLabel(TransactionType type, bool isSimpleMode, AppLocalizations l10n) {
    if (isSimpleMode) {
      switch (type) {
        case TransactionType.debtGiven: return l10n.simpleLent;
        case TransactionType.debtTaken: return l10n.simpleBorrowed;
        case TransactionType.paymentReceived: return l10n.simpleGotPaid;
        case TransactionType.paymentMade: return l10n.simplePaidBack;
        default: break;
      }
    }
    
    switch (type) {
      case TransactionType.saleOnCredit: return l10n.saleOnCredit;
      case TransactionType.paymentReceived: return l10n.paymentReceived;
      case TransactionType.purchaseOnCredit: return l10n.purchaseOnCredit;
      case TransactionType.paymentMade: return l10n.paymentMade;
      case TransactionType.debtGiven: return l10n.debtGiven;
      case TransactionType.debtTaken: return l10n.debtTaken;
      case TransactionType.cashSale: return l10n.cashLabel; // نقد - Cash
      case TransactionType.cashIncome: return l10n.bankLabel; // بنك - Bank
      case TransactionType.cashExpense: return l10n.expense;
    }
  }
}


