import 'package:aldeewan_mobile/domain/entities/person.dart';

/// Calculates total amount others owe to the user (receivables).
/// 
/// Receivables come from:
/// - Customers with positive balance (they owe us from saleOnCredit, debtGiven)
/// - Suppliers with negative balance (we overpaid or they owe us - rare but possible)
class GetTotalReceivablesUseCase {
  double call(List<Person> persons, Map<String, double> balances) {
    double total = 0.0;
    
    for (final p in persons) {
      final balance = balances[p.id] ?? 0.0;
      
      if (p.role == PersonRole.customer && balance > 0) {
        // Customer owes us money
        total += balance;
      } else if (p.role == PersonRole.supplier && balance < 0) {
        // Supplier owes us money (negative supplier balance = they owe us)
        total += balance.abs();
      }
    }
    
    return total;
  }
}

