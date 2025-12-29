import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_dto.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDatabaseSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  Stream<List<Transaction>> watchTransactions() {
    return _dataSource.watchTransactions().asyncMap((models) async {
      // Extract data to DTOs on the main thread (Realm objects are thread-confined)
      final dtos = models.map((m) => TransactionDto(
        id: m.uuid,
        type: m.type,
        personId: m.personId,
        amount: m.amount,
        date: m.date,
        category: m.category,
        note: m.note,
        dueDate: m.dueDate,
        externalId: m.externalId,
        status: m.status,
        accountId: m.accountId,
        goalId: m.goalId,
        isOpeningBalance: m.isOpeningBalance,
      )).toList();

      // Perform heavy mapping/processing in a background isolate
      return await compute(_mapDtosToEntities, dtos);
    });
  }

  static List<Transaction> _mapDtosToEntities(List<TransactionDto> dtos) {
    return dtos.map((dto) => dto.toEntity()).toList();
  }

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
    try {
      final model = TransactionModelMapper.fromEntity(transaction);
      await _dataSource.putTransaction(model);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to add transaction: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModelMapper.fromEntity(transaction);
      await _dataSource.putTransaction(model);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to update transaction: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _dataSource.deleteTransaction(id);
  }
}
