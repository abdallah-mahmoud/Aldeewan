import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final balanceCalculatorProvider = Provider((ref) => BalanceCalculatorService());

class BalanceCalculatorService {
  Future<Map<String, double>> calculate(List<Person> persons, List<Transaction> transactions) async {
    return compute(
      CalculateBalancesUseCase.calculate,
      (persons, transactions),
    );
  }
}
