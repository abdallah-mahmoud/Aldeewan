import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncAllAccounts() async {
    final realm = await ref.read(realmProvider.future);
    final accounts = realm.all<FinancialAccountModel>().toList();

    for (final account in accounts) {
      if (account.providerId.isNotEmpty) {
        await _syncAccount(realm, account);
      }
    }
  }

  Future<void> _syncAccount(Realm realm, FinancialAccountModel account) async {
    try {
      BankProviderInterface provider;
      switch (account.providerId) {
        case 'MOCK_BANK':
          provider = MockBankProvider();
          break;
        default:
          // Skip unsupported providers
          return;
      }

      // Fetch transactions since last sync or last 30 days
      final lastSync = account.lastSyncTime ?? DateTime.now().subtract(const Duration(days: 30));
      final transactions = await provider.fetchTransactions(account.externalAccountId ?? '', lastSync);

      if (transactions.isEmpty) return;

      realm.write(() {
        // Save transactions
        for (final txn in transactions) {
          // Check if transaction already exists to avoid duplicates
          final exists = realm.query<TransactionModel>('externalId == \$0', [txn.externalId]).firstOrNull;

          if (exists == null) {
            txn.accountId = account.id;
            realm.add(txn);
          }
        }

        // Update account balance and sync time
        // In a real app, we would fetch balance separately.
        // For now we assume provider.getBalance works.
      });
      
      // Fetch balance outside write transaction because it's async
      final newBalance = await provider.getBalance(account.externalAccountId ?? '');
      
      realm.write(() {
        account.balance = newBalance;
        account.lastSyncTime = DateTime.now();
      });

    } catch (e) {
      debugPrint('Error syncing account : $e');
    }
  }
}
