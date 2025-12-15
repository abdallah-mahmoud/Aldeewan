import 'package:flutter_test/flutter_test.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';

void main() {
  late CalculateBalancesUseCase useCase;

  setUp(() {
    useCase = CalculateBalancesUseCase();
  });

  group('CalculateBalancesUseCase', () {
    test('should return empty map when no persons', () {
      final result = useCase([], []);
      expect(result, isEmpty);
    });

    test('should return 0 balance for person with no transactions', () {
      final person = Person(id: '1', name: 'John', role: PersonRole.customer, createdAt: DateTime.now());
      final result = useCase([person], []);
      expect(result['1'], 0.0);
    });

    test('should calculate customer balance correctly', () {
      final person = Person(id: '1', name: 'John', role: PersonRole.customer, createdAt: DateTime.now());
      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.saleOnCredit,
          amount: 100.0,
          date: DateTime.now(),
          personId: '1',
        ),
        Transaction(
          id: 't2',
          type: TransactionType.paymentReceived,
          amount: 40.0,
          date: DateTime.now(),
          personId: '1',
        ),
      ];

      final result = useCase([person], transactions);
      expect(result['1'], 60.0);
    });

    test('should calculate supplier balance correctly', () {
      final person = Person(id: '2', name: 'Supplier', role: PersonRole.supplier, createdAt: DateTime.now());
      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.purchaseOnCredit,
          amount: 200.0,
          date: DateTime.now(),
          personId: '2',
        ),
        Transaction(
          id: 't2',
          type: TransactionType.paymentMade,
          amount: 50.0,
          date: DateTime.now(),
          personId: '2',
        ),
      ];

      final result = useCase([person], transactions);
      expect(result['2'], 150.0);
    });

    test('should ignore transactions for unknown persons', () {
      final person = Person(id: '1', name: 'John', role: PersonRole.customer, createdAt: DateTime.now());
      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.saleOnCredit,
          amount: 100.0,
          date: DateTime.now(),
          personId: '999', // Unknown ID
        ),
      ];

      final result = useCase([person], transactions);
      expect(result['1'], 0.0);
    });
  });
}
