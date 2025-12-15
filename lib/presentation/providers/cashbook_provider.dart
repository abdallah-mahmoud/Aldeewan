import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_state.dart';

enum CashFilter { all, income, expense }

/// Date range presets for quick filtering
enum DateRangePreset { all, today, thisWeek, thisMonth, custom }

class CashbookState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const CashbookState({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

final cashFilterProvider = StateProvider<CashFilter>((ref) => CashFilter.all);

/// Provider for date range preset selection
final dateRangePresetProvider = StateProvider<DateRangePreset>((ref) => DateRangePreset.all);

/// Search query provider for cashbook transaction filtering
final cashbookSearchProvider = StateProvider<String>((ref) => '');

/// Provider for custom date range (used when preset is 'custom')
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Computed date range based on preset or custom selection
final activeDateRangeProvider = Provider<DateTimeRange?>((ref) {
  final preset = ref.watch(dateRangePresetProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  switch (preset) {
    case DateRangePreset.all:
      return null; // No date filter
    case DateRangePreset.today:
      return DateTimeRange(
        start: today,
        end: today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
      );
    case DateRangePreset.thisWeek:
      // Start from Monday of current week
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
      return DateTimeRange(start: weekStart, end: weekEnd);
    case DateRangePreset.thisMonth:
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
      return DateTimeRange(start: monthStart, end: monthEnd);
    case DateRangePreset.custom:
      return customRange;
  }
});

final cashbookProvider = FutureProvider<CashbookState>((ref) async {
  final ledgerAsync = ref.watch(ledgerProvider);
  final filter = ref.watch(cashFilterProvider);
  final dateRange = ref.watch(activeDateRangeProvider);
  final searchQuery = ref.watch(cashbookSearchProvider);

  final ledgerState = ledgerAsync.value;
  if (ledgerState == null) {
    return const CashbookState(transactions: [], totalIncome: 0, totalExpense: 0, netBalance: 0);
  }

  return compute(_calculateCashbookState, (ledgerState, filter, dateRange, searchQuery));
});

CashbookState _calculateCashbookState((LedgerState, CashFilter, DateTimeRange?, String) data) {
  final ledgerState = data.$1;
  final filter = data.$2;
  final dateRange = data.$3;
  final searchQuery = data.$4;

  // 1. Filter for cash-related transactions
  var allCashTransactions = ledgerState.transactions.where((t) {
    return t.type == TransactionType.paymentReceived ||
        t.type == TransactionType.paymentMade ||
        t.type == TransactionType.cashSale ||
        t.type == TransactionType.cashIncome ||
        t.type == TransactionType.cashExpense ||
        t.type == TransactionType.debtGiven ||
        t.type == TransactionType.debtTaken;
  }).toList();

  // 2. Apply date range filter
  if (dateRange != null) {
    allCashTransactions = allCashTransactions.where((t) {
      return !t.date.isBefore(dateRange.start) && !t.date.isAfter(dateRange.end);
    }).toList();
  }

  // 3. Apply search query
  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    allCashTransactions = allCashTransactions.where((tx) {
      // Search by note
      if ((tx.note ?? '').toLowerCase().contains(lowerQuery)) return true;
      // Search by category
      if ((tx.category ?? '').toLowerCase().contains(lowerQuery)) return true;
      // Search by person name
      if (tx.personId != null) {
        // We need person name. ledgerState has persons list.
        try {
          final person = ledgerState.persons.firstWhere((p) => p.id == tx.personId);
          if (person.name.toLowerCase().contains(lowerQuery)) return true;
        } catch (_) {}
      }
      return false;
    }).toList();
  }

  // Sort by date descending
  allCashTransactions.sort((a, b) => b.date.compareTo(a.date));

  // 4. Apply income/expense filter
  final filtered = allCashTransactions.where((t) {
    final isIncome = t.type == TransactionType.paymentReceived ||
        t.type == TransactionType.cashSale ||
        t.type == TransactionType.cashIncome ||
        t.type == TransactionType.debtTaken;
    if (filter == CashFilter.income) return isIncome;
    if (filter == CashFilter.expense) return !isIncome;
    return true;
  }).toList();

  // 5. Compute summary
  double totalIn = 0;
  double totalOut = 0;
  for (final t in filtered) {
    final isIncome = t.type == TransactionType.paymentReceived ||
        t.type == TransactionType.cashSale ||
        t.type == TransactionType.cashIncome ||
        t.type == TransactionType.debtTaken;
    if (isIncome) {
      totalIn += t.amount;
    } else {
      totalOut += t.amount;
    }
  }
  final net = totalIn - totalOut;

  return CashbookState(
    transactions: filtered,
    totalIncome: totalIn,
    totalExpense: totalOut,
    netBalance: net,
  );
}

