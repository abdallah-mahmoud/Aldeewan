import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_statement_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_flow_report.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/error_handler.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';
import 'package:intl/intl.dart';
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          if (_tabController.index == 0)
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), width: 1),
              ),
              labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.all(4.w),
              tabs: [
                Tab(text: l10n.personStatement),
                Tab(text: l10n.cashFlow),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const ExportReportTip(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PersonStatementReport(),
                CashFlowReport(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    try {
      final persons = ref.read(ledgerProvider).value?.persons ?? [];
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
          SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(ErrorHandler.getUserFriendlyErrorMessage(e, AppLocalizations.of(context)!)))),
        );
      }
    }
  }
}

