import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class PersonStatementReport extends ConsumerStatefulWidget {
  const PersonStatementReport({super.key});

  @override
  ConsumerState<PersonStatementReport> createState() => _PersonStatementReportState();
}

class _PersonStatementReportState extends ConsumerState<PersonStatementReport> {
  Person? _selectedPerson;
  DateTimeRange? _dateRange;
  List<Transaction> _statementTransactions = [];
  double _balanceBroughtForward = 0.0;
  bool _generated = false;

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<Person>(
            value: _selectedPerson,
            decoration: InputDecoration(
              labelText: l10n.selectPerson,
              border: const OutlineInputBorder(),
            ),
            items: ledgerState.persons.map((person) {
              return DropdownMenuItem(
                value: person,
                child: Text(person.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPerson = value;
                _generated = false;
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
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
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.dateRange,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dateRange == null
                      ? l10n.selectDateRange
                      : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}'),
                  const Icon(LucideIcons.calendar),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _selectedPerson != null && _dateRange != null
                ? () {
                    _generateReport(notifier);
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
              l10n.statementFor(_selectedPerson!.name),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.period(DateFormat.yMMMd().format(_dateRange!.start), DateFormat.yMMMd().format(_dateRange!.end)),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(l10n.balanceBroughtForward, _balanceBroughtForward),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statementTransactions.length,
              itemBuilder: (context, index) {
                final tx = _statementTransactions[index];
                return ListTile(
                  title: Text(_getTransactionLabel(tx.type, l10n)),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: Text(tx.amount.toStringAsFixed(2)),
                );
              },
            ),
            const Divider(),
            _buildSummaryRow(
                l10n.closingBalance, _calculateClosingBalance()),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _exportCsv,
              icon: const Icon(Icons.download),
              label: Text(l10n.exportCsv),
            ),
          ],
        ],
      ),
    );
  }

  void _generateReport(LedgerNotifier notifier) {
    if (_selectedPerson == null || _dateRange == null) return;

    final allTransactions = ref.read(ledgerProvider).transactions
        .where((t) => t.personId == _selectedPerson!.id)
        .toList();

    final beforeRange = allTransactions
        .where((t) => t.date.isBefore(_dateRange!.start))
        .toList();

    final inRange = allTransactions
        .where((t) =>
            t.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate Balance B/F
    double balanceBF = 0.0;
    for (var t in beforeRange) {
      balanceBF = _applyTransactionToBalance(balanceBF, t, _selectedPerson!);
    }

    setState(() {
      _balanceBroughtForward = balanceBF;
      _statementTransactions = inRange;
      _generated = true;
    });
  }

  double _applyTransactionToBalance(double currentBalance, Transaction t, Person p) {
    if (p.role == PersonRole.customer) {
      if (t.type == TransactionType.saleOnCredit) return currentBalance + t.amount;
      if (t.type == TransactionType.paymentReceived) return currentBalance - t.amount;
    } else {
      if (t.type == TransactionType.purchaseOnCredit) return currentBalance + t.amount;
      if (t.type == TransactionType.paymentMade) return currentBalance - t.amount;
    }
    return currentBalance;
  }

  double _calculateClosingBalance() {
    double balance = _balanceBroughtForward;
    for (var t in _statementTransactions) {
      balance = _applyTransactionToBalance(balance, t, _selectedPerson!);
    }
    return balance;
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(amount.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getTransactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.saleOnCredit: return l10n.debt;
      case TransactionType.paymentReceived: return l10n.payment;
      case TransactionType.purchaseOnCredit: return l10n.credit;
      case TransactionType.paymentMade: return l10n.payment;
      default: return l10n.transaction;
    }
  }

  Future<void> _exportCsv() async {
    if (_selectedPerson == null || _dateRange == null) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Note', 'Amount', 'Balance'],
      ['', l10n.balanceBroughtForward, '', '', _balanceBroughtForward.toStringAsFixed(2)],
    ];

    double runningBalance = _balanceBroughtForward;
    for (var t in _statementTransactions) {
      runningBalance = _applyTransactionToBalance(runningBalance, t, _selectedPerson!);
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        _getTransactionLabel(t.type, l10n),
        t.note ?? '',
        t.amount.toStringAsFixed(2),
        runningBalance.toStringAsFixed(2),
      ]);
    }

    final fileName = 'statement_${_selectedPerson!.name}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: l10n.statementFor(_selectedPerson!.name),
      text: 'Here is the statement for ${_selectedPerson!.name} from ${DateFormat.yMMMd().format(_dateRange!.start)} to ${DateFormat.yMMMd().format(_dateRange!.end)}.',
    );
  }
}

