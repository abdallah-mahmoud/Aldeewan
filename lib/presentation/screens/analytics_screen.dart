import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_statement_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_flow_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/budget_list.dart';
import 'package:aldeewan_mobile/presentation/widgets/goal_list.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.personStatement),
            Tab(text: l10n.cashFlow),
            Tab(text: l10n.budgets),
            Tab(text: l10n.goals),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PersonStatementReport(),
          CashFlowReport(),
          BudgetList(),
          GoalList(),
        ],
      ),
      floatingActionButton: _buildFab(context, l10n),
    );
  }

  Widget? _buildFab(BuildContext context, AppLocalizations l10n) {
    if (_tabController.index == 2) {
      return FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      );
    } else if (_tabController.index == 3) {
      return FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createBudget),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: l10n.category),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: l10n.monthlyLimit),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ThousandsSeparatorInputFormatter(allowFraction: true)],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final budget = BudgetModel(
                ObjectId(),
                categoryController.text,
                double.tryParse(amountController.text.replaceAll(',', '')) ?? 0,
                0,
                DateTime(DateTime.now().year, DateTime.now().month, 1),
                DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
                isRecurring: true,
              );
              
              ref.read(budgetProvider.notifier).addBudget(budget);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createGoal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.goalName),
            ),
            TextField(
              controller: targetController,
              decoration: InputDecoration(labelText: l10n.targetAmount),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ThousandsSeparatorInputFormatter(allowFraction: true)],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final goal = SavingsGoalModel(
                ObjectId(),
                nameController.text,
                double.tryParse(targetController.text.replaceAll(',', '')) ?? 0,
                0,
              );
              
              ref.read(budgetProvider.notifier).addGoal(goal);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
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

