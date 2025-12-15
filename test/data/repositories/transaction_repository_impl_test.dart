import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/repositories/transaction_repository_impl.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

@GenerateMocks([LocalDatabaseSource])
import 'transaction_repository_impl_test.mocks.dart';

void main() {
  late MockLocalDatabaseSource mockDataSource;
  late TransactionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockLocalDatabaseSource();
    repository = TransactionRepositoryImpl(mockDataSource);
  });

  group('TransactionRepositoryImpl', () {
    final tDate = DateTime.now();
    final tTransactionModel = TransactionModel(
      '1',
      'saleOnCredit',
      100.0,
      tDate,
      personId: 'p1',
      category: 'Food',
      note: 'Test Note',
    );

    test('getTransactions should return list of Transactions', () async {
      // Arrange
      when(mockDataSource.getTransactions())
          .thenAnswer((_) async => [tTransactionModel]);

      // Act
      final result = await repository.getTransactions();

      // Assert
      expect(result, isA<List<Transaction>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.amount, 100.0);
      verify(mockDataSource.getTransactions());
    });

    test('watchTransactions should emit list of Transactions', () async {
      // Arrange
      when(mockDataSource.watchTransactions())
          .thenAnswer((_) => Stream.value([tTransactionModel]));

      // Act
      final stream = repository.watchTransactions();

      // Assert
      expect(
        stream,
        emits(predicate<List<Transaction>>((list) {
          return list.length == 1 && list.first.id == '1';
        })),
      );
    });
  });
}
