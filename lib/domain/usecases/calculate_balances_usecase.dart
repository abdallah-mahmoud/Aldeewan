import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class CalculateBalancesUseCase {
  Map<String, double> call(List<Person> persons, List<Transaction> transactions) {
    return calculate((persons, transactions));
  }

  static Map<String, double> calculate((List<Person>, List<Transaction>) data) {
    final persons = data.$1;
    final transactions = data.$2;
    final balances = <String, double>{};
    final personMap = {for (var p in persons) p.id: p};
    
    // Initialize balances
    for (var p in persons) {
      balances[p.id] = 0.0;
    }

    // Single pass through transactions O(M)
    for (var t in transactions) {
      if (t.personId != null && balances.containsKey(t.personId)) {
        final person = personMap[t.personId];
        if (person == null) continue;

        double current = balances[t.personId]!;
        
        if (person.role == PersonRole.customer) {
          // Customer owes us (+balance) or we owe them (-balance/advance)
          if (t.type == TransactionType.saleOnCredit) current += t.amount;
          if (t.type == TransactionType.debtGiven) current += t.amount;
          if (t.type == TransactionType.paymentReceived) current -= t.amount;
          if (t.type == TransactionType.debtTaken) current -= t.amount;
          // If we pay a customer (returning advance), reduce the negative balance
          if (t.type == TransactionType.paymentMade) current += t.amount;
        } else { // Supplier
          // We owe supplier (+balance) or supplier owes us (-balance/advance)
          if (t.type == TransactionType.purchaseOnCredit) current += t.amount;
          if (t.type == TransactionType.debtTaken) current += t.amount;
          if (t.type == TransactionType.paymentMade) current -= t.amount;
          if (t.type == TransactionType.debtGiven) current -= t.amount;
          // If supplier pays us (returning advance), reduce their negative balance
          if (t.type == TransactionType.paymentReceived) current += t.amount;
        }
        balances[t.personId!] = current;
      }
    }
    return balances;
  }
}
