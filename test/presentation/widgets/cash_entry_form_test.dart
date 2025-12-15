import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Mock NotificationHistoryNotifier
class MockNotificationHistoryNotifier extends NotificationHistoryNotifier with Mock {
  MockNotificationHistoryNotifier() : super(null);

  @override
  void addNotification({required String title, required String body, String type = 'info'}) {}
}

// Mock CurrencyNotifier
class MockCurrencyNotifier extends CurrencyNotifier {
  MockCurrencyNotifier() : super();
}

// Mock BudgetNotifier
class MockBudgetNotifier extends BudgetNotifier {
  MockBudgetNotifier() : super(null);
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Helper to pump the widget with necessary providers and localizations
  Future<void> pumpCashEntryForm(
    WidgetTester tester, {
    required Function(Transaction) onSave,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyProvider.overrideWith((ref) => MockCurrencyNotifier()),
          budgetProvider.overrideWith((ref) => MockBudgetNotifier()),
          notificationHistoryProvider.overrideWith((ref) => MockNotificationHistoryNotifier()),
          ...overrides,
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: CashEntryForm(onSave: onSave),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CashEntryForm Widget Test', () {
    testWidgets('renders all form fields correctly', (WidgetTester tester) async {
      await pumpCashEntryForm(tester, onSave: (_) {});

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsAtLeastNWidgets(1)); // InputDecorator label and hint
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows validation error when amount is empty', (WidgetTester tester) async {
      await pumpCashEntryForm(tester, onSave: (_) {});

      // Tap save without entering amount
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('calls onSave when form is valid', (WidgetTester tester) async {
      Transaction? savedTransaction;
      await pumpCashEntryForm(tester, onSave: (t) {
        savedTransaction = t;
      });

      // Enter amount
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '100');
      await tester.pump();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedTransaction, isNotNull);
      expect(savedTransaction!.amount, 100.0);
      expect(savedTransaction!.type, TransactionType.cashSale); // Default
    });
  });
}

