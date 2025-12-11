import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDatabaseSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _dataSource.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByPerson(String personId) async {
    final models = await _dataSource.getTransactionsByPerson(personId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final models = await _dataSource.getTransactionsByDateRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModelMapper.fromEntity(transaction);
    await _dataSource.putTransaction(model);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModelMapper.fromEntity(transaction);
    await _dataSource.putTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _dataSource.deleteTransaction(id);
  }
}
