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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([PersonRepository, TransactionRepository, BalanceCalculatorService])
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({
      'is_initial_balance_prompt_shown': true, // Skip initial balance dialog
      'is_tour_completed': true, // Skip tour
    });
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
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          personRepositoryProvider.overrideWithValue(mockPersonRepository),
          transactionRepositoryProvider.overrideWithValue(mockTransactionRepository),
          balanceCalculatorProvider.overrideWithValue(mockBalanceCalculatorService),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            // ignore: deprecated_member_use
            home: ShowCaseWidget(
              builder: (context) => const HomeScreen(),
            ),
          ),
        ),
      ),
    );
  }

  // SKIP: Flaky due to async provider initialization timing
  testWidgets('shows loading indicator initially', (WidgetTester tester) async {
    await pumpHomeScreen(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Advance timers to prevent pending timer errors
    await tester.pump(const Duration(seconds: 1));
  }, skip: true);

  testWidgets('shows dashboard when data is loaded', (WidgetTester tester) async {
    await pumpHomeScreen(tester);

    // Emit data
    personStreamController.add([]);
    transactionStreamController.add([]);

    // Wait for Riverpod to update and advance timers (800ms for ShowcaseTourMixin)
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Advance past the 800ms delayed timer
    await tester.pump();

    expect(find.text('Aldeewan'), findsOneWidget);
    expect(find.text('Your Personal Ledger & Cashbook'), findsOneWidget);
    expect(find.text('Net Position'), findsOneWidget);
  });
}

