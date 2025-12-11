import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class MockBankProvider implements BankProviderInterface {
  @override
  String get providerId => 'MOCK_BANK';

  @override
  Future<bool> authenticate(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // Mock authentication logic
    return username == 'user' && password == 'password';
  }

  @override
  Future<double> getBalance(String accountId) async {
    await Future.delayed(const Duration(seconds: 1));
    return 150000.0; // Mock balance: 150,000 SDG
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String accountId, DateTime since) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate some mock transactions
    return [
      TransactionModel()
        ..uuid = const Uuid().v4()
        ..type = TransactionType.paymentReceived
        ..amount = 5000.0
        ..date = DateTime.now().subtract(const Duration(days: 1))
        ..category = 'Salary'
        ..note = 'Monthly Salary'
        ..externalId = 'MOCK_TXN_001'
        ..status = 'POSTED'
        ..accountId = int.tryParse(accountId),
      TransactionModel()
        ..uuid = const Uuid().v4()
        ..type = TransactionType.cashExpense
        ..amount = 2500.0
        ..date = DateTime.now().subtract(const Duration(days: 2))
        ..category = 'Groceries'
        ..note = 'Supermarket'
        ..externalId = 'MOCK_TXN_002'
        ..status = 'POSTED'
        ..accountId = int.tryParse(accountId),
    ];
  }

  @override
  Future<void> refreshToken() async {
    // No-op for mock
  }
}
