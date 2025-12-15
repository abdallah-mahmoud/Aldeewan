import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/charts/income_expense_bar_chart.dart';
import 'package:aldeewan_mobile/presentation/widgets/expense_pie_chart.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/presentation/widgets/common/filter_action_tile.dart';

class CashFlowReport extends ConsumerStatefulWidget {
  const CashFlowReport({super.key});

  @override
  ConsumerState<CashFlowReport> createState() => _CashFlowReportState();
}

class _CashFlowReportState extends ConsumerState<CashFlowReport> {
  DateTimeRange? _dateRange;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<Transaction> _transactions = [];
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateReport());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final formatter = NumberFormat('#,##0.##');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterActionTile(
            label: l10n.dateRange,
            value: _dateRange == null
                ? l10n.selectDateRange
                : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}',
            icon: LucideIcons.calendar,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() {
                  _dateRange = picked;
                  _generated = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _dateRange != null
                ? () {
                    _generateReport();
                  }
                : null,
            icon: const Icon(LucideIcons.fileBarChart),
            label: Text(l10n.generateReport),
          ),
          if (_generated) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.cashFlowReport,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.period(DateFormat.yMMMd().format(_dateRange!.start), DateFormat.yMMMd().format(_dateRange!.end)),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            IncomeExpenseBarChart(income: _totalIncome, expense: _totalExpense),
            const SizedBox(height: 24),
            if (_totalExpense > 0) ...[
              Text(
                l10n.expenseBreakdown,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ExpensePieChart(transactions: _transactions),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 12),
            _buildSummaryCard(l10n.totalExpense, _totalExpense, AppColors.error, currency, formatter),
            const SizedBox(height: 12),
            _buildSummaryCard(
                l10n.netProfitLoss,
                _totalIncome - _totalExpense,
                (_totalIncome - _totalExpense) >= 0 ? AppColors.success : AppColors.error,
                currency,
                formatter),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _exportCsv,
              icon: const Icon(LucideIcons.download),
              label: Text(l10n.exportCsv),
            ),
          ],
        ],
      ),
    );
  }

  void _generateReport() {
    if (_dateRange == null) return;

    final allTransactions = ref.read(ledgerProvider).value?.transactions ?? [];
    final inRange = allTransactions
        .where((t) =>
            t.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double income = 0.0;
    double expense = 0.0;

    for (var t in inRange) {
      if (t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome) {
        income += t.amount;
      } else if (t.type == TransactionType.paymentMade ||
          t.type == TransactionType.cashExpense) {
        expense += t.amount;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _transactions = inRange;
      _generated = true;
    });
  }

  Widget _buildSummaryCard(String label, double amount, Color color, String currency, NumberFormat formatter) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(
            '$currency ${formatter.format(amount)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_dateRange == null) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Note', 'Income', 'Expense'],
    ];

    for (var t in _transactions) {
      double income = 0.0;
      double expense = 0.0;
      if (t.type == TransactionType.paymentReceived ||
          t.type == TransactionType.cashSale ||
          t.type == TransactionType.cashIncome) {
        income = t.amount;
      } else if (t.type == TransactionType.paymentMade ||
          t.type == TransactionType.cashExpense) {
        expense = t.amount;
      }

      if (income > 0 || expense > 0) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(t.date),
          t.type.toString().split('.').last,
          t.note ?? '',
          income > 0 ? income.toStringAsFixed(2) : '',
          expense > 0 ? expense.toStringAsFixed(2) : '',
        ]);
      }
    }

    rows.add(['', '', 'TOTAL', _totalIncome.toStringAsFixed(2), _totalExpense.toStringAsFixed(2)]);
    rows.add(['', '', 'NET', (_totalIncome - _totalExpense).toStringAsFixed(2), '']);

    final fileName = 'cash_flow_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: l10n.cashFlowReport,
      text: 'Here is the cash flow report from ${DateFormat.yMMMd().format(_dateRange!.start)} to ${DateFormat.yMMMd().format(_dateRange!.end)}.',
    );
  }
}

