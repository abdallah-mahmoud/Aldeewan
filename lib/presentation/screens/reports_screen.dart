import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_statement_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_flow_report.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reports),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'export_persons') {
                  _exportPersonsCsv(context, ref);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'export_persons',
                    child: Text(l10n.exportPersons),
                  ),
                ];
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.personStatement),
              Tab(text: l10n.cashFlow),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PersonStatementReport(),
            CashFlowReport(),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    try {
      final persons = ref.read(ledgerProvider).persons;
      final rows = <List<dynamic>>[
        ['ID', 'Name', 'Role', 'Phone', 'Created At'],
      ];

      for (var p in persons) {
        rows.add([
          p.id,
          p.name,
          p.role.toString().split('.').last,
          p.phone ?? '',
          DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt),
        ]);
      }

      final fileName = 'persons_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      await CsvExporter.exportToCsv(
        fileName: fileName,
        rows: rows,
        subject: 'Aldeewan Persons Export',
        text: 'Export of all persons.',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(e.toString()))),
        );
      }
    }
  }
}

