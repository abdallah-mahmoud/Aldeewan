import 'package:aldeewan_mobile/data/models/transaction_model.dart';

/// Abstract class defining the interface for a bank provider.
///
/// This interface outlines the essential operations for interacting with a bank's API,
/// including authentication, fetching balances, and retrieving transaction data.
/// Any concrete bank provider implementation must adhere to this interface.
abstract class BankProviderInterface {
  /// A unique identifier for the bank provider (e.g., "MBOK" for a specific bank).
  String get providerId;
  
  /// Authenticates the user with the bank's API using provided credentials.
  ///
  /// - Parameters:
  ///   - `username`: The user's username for the bank's online services.
  ///   - `password`: The user's password for the bank's online services.
  /// - Returns: A `Future<bool>` indicating whether the authentication was successful.
  Future<bool> authenticate(String username, String password);
  
  /// Retrieves the current balance for a specified financial account.
  ///
  /// - Parameters:
  ///   - `accountId`: The unique identifier of the financial account.
  /// - Returns: A `Future<double>` representing the current balance of the account.
  Future<double> getBalance(String accountId);
  
  /// Fetches a list of transactions for a given account, starting from a specified date.
  ///
  /// - Parameters:
  ///   - `accountId`: The unique identifier of the financial account.
  ///   - `since`: The `DateTime` from which to fetch transactions. Transactions older than this date will not be included.
  /// - Returns: A `Future<List<TransactionModel>>` containing the fetched transactions.
  Future<List<TransactionModel>> fetchTransactions(String accountId, DateTime since);
  
  /// Refreshes the access token for the bank API if it has expired or is nearing expiration.
  ///
  /// This method ensures continuous access to the bank's services without requiring
  /// a full re-authentication by the user.
  /// - Returns: A `Future<void>` that completes when the token has been refreshed.
  Future<void> refreshToken();
}
