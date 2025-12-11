import 'package:aldeewan_mobile/data/models/transaction_model.dart';

abstract class BankProviderInterface {
  String get providerId; // e.g., "MBOK"
  
  /// Authenticate with the bank API
  Future<bool> authenticate(String username, String password);
  
  /// Get current balance
  Future<double> getBalance(String accountId);
  
  /// Fetch transactions since a specific date
  Future<List<TransactionModel>> fetchTransactions(String accountId, DateTime since);
  
  /// Refresh the access token if needed
  Future<void> refreshToken();
}
