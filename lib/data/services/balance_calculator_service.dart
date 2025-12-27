import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Riverpod provider that exposes an instance of [BalanceCalculatorService].
///
/// This allows other parts of the application to easily access and use the service
/// for calculating balances.
final balanceCalculatorProvider = Provider((ref) => BalanceCalculatorService());

/// A service class responsible for calculating financial balances.
///
/// This service utilizes a `CalculateBalancesUseCase` to perform complex balance
/// calculations, offloading heavy computations to a background isolate using `compute`
/// to prevent UI freezes.
class BalanceCalculatorService {
  /// Calculates the balances for a list of persons based on their transactions.
  ///
  /// This method takes a list of [Person] entities and a list of [Transaction] entities,
  /// and uses `CalculateBalancesUseCase` to compute the net balances for each person.
  /// The computation is performed in a separate isolate to ensure UI responsiveness.
  ///
  /// - Parameters:
  ///   - `persons`: A list of [Person] entities for whom to calculate balances.
  ///   - `transactions`: A list of [Transaction] entities to be used in the balance calculation.
  /// - Returns: A `Future<Map<String, double>>` where the keys are person IDs (String)
  ///   and the values are their calculated balances (double).
  Future<Map<String, double>> calculate(List<Person> persons, List<Transaction> transactions) async {
    return compute(
      CalculateBalancesUseCase.calculate,
      (persons, transactions),
    );
  }
}
