import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/locale_provider.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';

// State class to hold filtered results and totals
class CashbookComputedState {
  final List<Transaction> transactions;
  final double totalIn;
  final double totalOut;
  final double net;

  CashbookComputedState({
    required this.transactions,
    required this.totalIn,
    required this.totalOut,
    required this.net,
  });
}

// Provider
final filteredTransactionsProvider = Provider.autoDispose<AsyncValue<CashbookComputedState>>((ref) {
  final cashbookAsync = ref.watch(cashbookProvider);
  final searchQuery = ref.watch(cashbookSearchProvider);
  final ledgerAsync = ref.watch(ledgerProvider);
  final locale = ref.watch(localeProvider);
  final isSimpleMode = ref.watch(settingsProvider);
  
  return cashbookAsync.whenData((state) {
    var filteredList = state.transactions;
    
    // Perform Search if needed
    if (searchQuery.isNotEmpty) {
      // Get L10n for localized search
      final l10n = lookupAppLocalizations(locale);
      final lowerQuery = searchQuery.toLowerCase();
      final numberFormat = NumberFormat('#,##0.##');

      // Pre-compute person map for O(1) lookup
      final personMap = <String, String>{};
      ledgerAsync.whenData((ledger) {
         for (var p in ledger.persons) {
           personMap[p.id] = p.name.toLowerCase();
         }
      });
      
      filteredList = filteredList.where((tx) {
        // Note
        if ((tx.note ?? '').toLowerCase().contains(lowerQuery)) return true;
        
        // Category (EN + AR)
        final categoryEN = (tx.category ?? '').toLowerCase();
        final categoryAR = CategoryHelper.getLocalizedCategory(tx.category ?? '', l10n).toLowerCase();
        if (categoryEN.contains(lowerQuery) || categoryAR.contains(lowerQuery)) return true;
        
        // Person Name
        if (tx.personId != null) {
          final pName = personMap[tx.personId];
          if (pName != null && pName.contains(lowerQuery)) return true;
        }
        
        // Amount
        final amountStr = tx.amount.toString();
        final formattedAmount = numberFormat.format(tx.amount);
        if (amountStr.contains(lowerQuery) || formattedAmount.contains(lowerQuery)) return true;
        
        // Type Label
        final typeLabel = TransactionLabelMapper.getLabel(tx.type, isSimpleMode, l10n);
        if (typeLabel.toLowerCase().contains(lowerQuery)) return true;
        
        return false;
      }).toList();
    }
    
    // Calculate Totals
    double totalIn = 0;
    double totalOut = 0;
    
    for (final t in filteredList) {
      final isIncome = t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome ||
          t.type == TransactionType.debtTaken;
          
      if (isIncome) {
        totalIn += t.amount;
      } else {
        totalOut += t.amount;
      }
    }
    
    return CashbookComputedState(
      transactions: filteredList,
      totalIn: totalIn,
      totalOut: totalOut,
      net: totalIn - totalOut,
    );
  });
});
