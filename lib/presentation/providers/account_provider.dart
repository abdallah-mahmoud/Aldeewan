import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, AsyncValue<List<FinancialAccountModel>>>((ref) {
  return AccountNotifier(ref);
});

class AccountNotifier extends StateNotifier<AsyncValue<List<FinancialAccountModel>>> {
  final Ref ref;
  late final Isar _isar;

  AccountNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    _isar = await ref.read(isarProvider.future);
    await loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final accounts = await _isar.financialAccountModels.where().findAll();
      state = AsyncValue.data(accounts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> linkAccount({
    required String providerId,
    required String username,
    required String password,
  }) async {
    try {
      BankProviderInterface provider;
      
      // Factory logic for providers
      switch (providerId) {
        case 'MOCK_BANK':
          provider = MockBankProvider();
          break;
        default:
          throw UnimplementedError('Provider $providerId not implemented yet');
      }

      final isAuthenticated = await provider.authenticate(username, password);
      
      if (isAuthenticated) {
        // In a real app, we would get a token and account ID from the provider
        // For mock, we generate a random ID
        final accountId = 'ACC_${DateTime.now().millisecondsSinceEpoch}';
        final initialBalance = await provider.getBalance(accountId);

        final newAccount = FinancialAccountModel()
          ..name = '$providerId Account'
          ..accountType = 'BANK'
          ..balance = initialBalance
          ..currency = 'SDG'
          ..providerId = providerId
          ..lastSyncTime = DateTime.now();

        await _isar.writeTxn(() async {
          await _isar.financialAccountModels.put(newAccount);
        });

        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
