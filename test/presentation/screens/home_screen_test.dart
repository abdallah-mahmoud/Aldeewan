import 'dart:async';

import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';
import 'package:aldeewan_mobile/data/services/balance_calculator_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([PersonRepository, TransactionRepository, BalanceCalculatorService])
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  late MockPersonRepository mockPersonRepository;
  late MockTransactionRepository mockTransactionRepository;
  late MockBalanceCalculatorService mockBalanceCalculatorService;
  late StreamController<List<Person>> personStreamController;
  late StreamController<List<Transaction>> transactionStreamController;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockTransactionRepository = MockTransactionRepository();
    mockBalanceCalculatorService = MockBalanceCalculatorService();
    personStreamController = StreamController<List<Person>>.broadcast();
    transactionStreamController = StreamController<List<Transaction>>.broadcast();

    when(mockPersonRepository.watchPeople()).thenAnswer((_) => personStreamController.stream);
    when(mockTransactionRepository.watchTransactions()).thenAnswer((_) => transactionStreamController.stream);
    when(mockBalanceCalculatorService.calculate(any, any)).thenAnswer((_) async => {});
  });

  tearDown(() {
    personStreamController.close();
    transactionStreamController.close();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          personRepositoryProvider.overrideWithValue(mockPersonRepository),
          transactionRepositoryProvider.overrideWithValue(mockTransactionRepository),
          balanceCalculatorProvider.overrideWithValue(mockBalanceCalculatorService),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const HomeScreen(),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator initially', (WidgetTester tester) async {
    await pumpHomeScreen(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows dashboard when data is loaded', (WidgetTester tester) async {
    await pumpHomeScreen(tester);

    // Emit data
    personStreamController.add([]);
    transactionStreamController.add([]);

    // Wait for Riverpod to update
    // We use pump() instead of pumpAndSettle() because the CircularProgressIndicator
    // can cause pumpAndSettle to timeout if the state doesn't change immediately.
    // We need to pump enough times to allow the microtasks and futures to complete.
    await tester.pump(); // Stream listeners fire
    await tester.pump(); // _updateState starts and awaits calculator
    await tester.pump(); // calculator returns, state updates
    await tester.pump(); // UI rebuilds with data

    expect(find.text('Aldeewan'), findsOneWidget);
    expect(find.text('Your Personal Ledger & Cashbook'), findsOneWidget);
    expect(find.text('Net Position'), findsOneWidget); // Hero Section
  });
}
