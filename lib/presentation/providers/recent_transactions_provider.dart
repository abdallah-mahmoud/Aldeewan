import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';

/// efficiently computes the top 5 recent transactions
/// This runs only when ledger data changes, not on every UI rebuild.
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final ledgerAsync = ref.watch(ledgerProvider);
  
  return ledgerAsync.maybeWhen(
    data: (state) {
      final transactions = state.transactions;
      if (transactions.isEmpty) return [];
      
      // Perform sort on a shallow copy
      final sorted = List<Transaction>.from(transactions)
        ..sort((a, b) => b.date.compareTo(a.date));
        
      return sorted.take(5).toList();
    },
    orElse: () => const [],
  );
});
