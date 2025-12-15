import 'package:aldeewan_mobile/domain/entities/person.dart';

/// Calculates total amount the user owes to others (payables).
/// 
/// Payables come from:
/// - Suppliers with positive balance (we owe them from purchaseOnCredit, debtTaken)
/// - Customers with negative balance (we owe them from debtTaken - we borrowed from customer)
class GetTotalPayablesUseCase {
  double call(List<Person> persons, Map<String, double> balances) {
    double total = 0.0;
    
    for (final p in persons) {
      final balance = balances[p.id] ?? 0.0;
      
      if (p.role == PersonRole.supplier && balance > 0) {
        // We owe supplier money
        total += balance;
      } else if (p.role == PersonRole.customer && balance < 0) {
        // We owe customer money (negative customer balance = we owe them)
        total += balance.abs();
      }
    }
    
    return total;
  }
}

