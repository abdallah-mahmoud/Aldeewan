import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<FinancialAccountModel>>((ref) {
  final realmAsync = ref.watch(realmProvider);
  return realmAsync.when(
    data: (realm) => AccountNotifier(realm),
    loading: () => AccountNotifier(null), // Handle loading state if needed
    error: (e, s) => AccountNotifier(null),
  );
});

class AccountNotifier extends StateNotifier<List<FinancialAccountModel>> {
  final Realm? _realm;

  AccountNotifier(this._realm) : super([]) {
    if (_realm != null) {
      loadAccounts();
    }
  }

  void loadAccounts() {
    if (_realm == null) return;
    final accounts = _realm.all<FinancialAccountModel>();
    state = accounts.toList();
    
    // Listen for changes
    accounts.changes.listen((changes) {
      state = changes.results.toList();
    });
  }

  Future<void> linkAccount(String providerId, String username, String password) async {
    if (_realm == null) return;

    try {
      BankProviderInterface provider;
      switch (providerId) {
        case 'MOCK_BANK':
          provider = MockBankProvider();
          break;
        default:
          throw Exception('Unsupported provider: ');
      }

      final isAuthenticated = await provider.authenticate(username, password);
      
      if (isAuthenticated) {
        // In a real app, we would get a token and account ID from the provider
        // For mock, we generate a random ID
        const accountId = 'ACC_';
        final initialBalance = await provider.getBalance(accountId);

        final newAccount = FinancialAccountModel(
          DateTime.now().millisecondsSinceEpoch,
          ' Account',
          providerId,
          'BANK',
          initialBalance,
          'SDG',
          externalAccountId: accountId,
          lastSyncTime: DateTime.now(),
          status: 'ACTIVE',
        );

        _realm.write(() {
          _realm.add(newAccount);
        });
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      debugPrint('Error linking account: $e');
      rethrow;
    }
  }
}
