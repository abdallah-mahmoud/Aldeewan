import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/repositories/person_repository_impl.dart';
import 'package:aldeewan_mobile/data/repositories/transaction_repository_impl.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_receivables_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_payables_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_monthly_income_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_monthly_expense_usecase.dart';

// Data Source
final localDatabaseSourceProvider = Provider<LocalDatabaseSource>((ref) {
  return LocalDatabaseSource();
});

// Repositories
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return PersonRepositoryImpl(dataSource);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

// Use Cases
final calculateBalancesUseCaseProvider = Provider<CalculateBalancesUseCase>((ref) {
  return CalculateBalancesUseCase();
});

final getTotalReceivablesUseCaseProvider = Provider<GetTotalReceivablesUseCase>((ref) {
  return GetTotalReceivablesUseCase();
});

final getTotalPayablesUseCaseProvider = Provider<GetTotalPayablesUseCase>((ref) {
  return GetTotalPayablesUseCase();
});

final getMonthlyIncomeUseCaseProvider = Provider<GetMonthlyIncomeUseCase>((ref) {
  return GetMonthlyIncomeUseCase();
});

final getMonthlyExpenseUseCaseProvider = Provider<GetMonthlyExpenseUseCase>((ref) {
  return GetMonthlyExpenseUseCase();
});
