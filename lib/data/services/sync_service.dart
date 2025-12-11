import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncAllAccounts() async {
    final isar = await ref.read(isarProvider.future);
    final accounts = await isar.financialAccountModels.where().findAll();

    for (final account in accounts) {
      if (account.providerId.isNotEmpty) {
        await _syncAccount(isar, account);
      }
    }
  }

  Future<void> _syncAccount(Isar isar, FinancialAccountModel account) async {
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

      await isar.writeTxn(() async {
        // Save transactions
        for (final txn in transactions) {
          // Check if transaction already exists to avoid duplicates
          final exists = await isar.transactionModels
              .filter()
              .externalIdEqualTo(txn.externalId)
              .findFirst();

          if (exists == null) {
            txn.accountId = account.id;
            await isar.transactionModels.put(txn);
          }
        }

        // Update account balance and sync time
        // In a real app, we might want to fetch the balance from the API again
        // or calculate it based on transactions. Here we trust the provider's balance if available,
        // but fetchTransactions doesn't return balance.
        // Let's fetch balance separately.
        final newBalance = await provider.getBalance(account.externalAccountId ?? '');
        
        account.balance = newBalance;
        account.lastSyncTime = DateTime.now();
        await isar.financialAccountModels.put(account);
      });
    } catch (e) {
      print('Error syncing account ${account.name}: $e');
    }
  }
}
