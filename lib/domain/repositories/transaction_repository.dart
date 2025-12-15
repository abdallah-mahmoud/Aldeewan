import 'package:aldeewan_mobile/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<Transaction>> watchTransactions();
  Future<List<Transaction>> getTransactions();
  Future<List<Transaction>> getTransactionsByPerson(String personId);
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
