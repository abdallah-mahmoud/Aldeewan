import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/category_provider.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/category_selector.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final categories = ref.watch(categoryProvider);
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0.##');

    // Filter budgets
    final now = DateTime.now();
    final activeBudgets = budgetState.budgets.where((b) {
      return b.endDate.isAfter(now) || b.endDate.isAtSameMomentAs(now);
    }).toList();

    final historyBudgets = budgetState.budgets.where((b) {
      return b.endDate.isBefore(now) && !b.endDate.isAtSameMomentAs(now);
    }).toList();
    
    // Sort history by date descending
    historyBudgets.sort((a, b) => b.endDate.compareTo(a.endDate));

    // Calculate totals for ACTIVE only
    double totalLimit = 0;
    double totalSpent = 0;
    List<PieChartSectionData> chartSections = [];

    for (var b in activeBudgets) {
      totalLimit += b.amountLimit;
      totalSpent += b.currentSpent;
      
      if (b.currentSpent > 0) {
        final category = categories.firstWhere(
          (c) => c.name == b.category,
          orElse: () => categories.firstWhere((c) => c.id == 'other'),
        );
        chartSections.add(PieChartSectionData(
          color: category.color,
          value: b.currentSpent,
          radius: 14,
          showTitle: false,
          badgeWidget: _Badge(
            category.icon,
            size: 20,
            borderColor: category.color,
          ),
          badgePositionPercentageOffset: 1.5,
        ));
      }
    }
    
    // Add Remaining Section
    if (totalLimit > totalSpent) {
      chartSections.add(PieChartSectionData(
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
        value: totalLimit - totalSpent,
        radius: 12,
        showTitle: false,
      ));
    } else if (chartSections.isEmpty && totalLimit > 0) {
       // No spent yet, full remaining
       chartSections.add(PieChartSectionData(
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
        value: totalLimit,
        radius: 12,
        showTitle: false,
      ));
    }

    double totalProgress = totalLimit > 0 ? totalSpent / totalLimit : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgets),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: budgetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Active Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Summary Card
                      Container(
                        padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Semantics(
                          label: l10n.budgetUsage((totalProgress * 100).toStringAsFixed(0)),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Stack(
                              children: [
                                PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 35,
                                  startDegreeOffset: -90,
                                  sections: chartSections,
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutQuad,
                              ),
                              Center(
                                child: Text(
                                  '${(totalProgress * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.budgetSummary,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '$currency ${formatter.format(totalSpent)} / $currency ${formatter.format(totalLimit)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                l10n.totalSpent,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Budget alert tip
                  const BudgetAlertTip(),
                  
                  // Budget List
                  if (activeBudgets.isEmpty)
                    EmptyState(
                      message: l10n.noEntriesYet,
                      icon: LucideIcons.wallet,
                      actionLabel: l10n.createBudget,
                      onAction: () => _showAddBudgetDialog(context, ref),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeBudgets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final budget = activeBudgets[index];
                        final category = categories.firstWhere(
                          (c) => c.name == budget.category,
                          orElse: () => categories.firstWhere((c) => c.id == 'other'),
                        );
                        final progress = budget.amountLimit > 0 ? budget.currentSpent / budget.amountLimit : 0.0;
                        final isOverBudget = progress > 1.0;

                        return InkWell(
                          onTap: () => context.push('/budgets/${budget.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isOverBudget ? theme.colorScheme.errorContainer : category.color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isOverBudget ? LucideIcons.alertTriangle : category.icon, 
                                        color: isOverBudget ? theme.colorScheme.error : category.color, 
                                        size: 20
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            CategoryHelper.getLocalizedCategory(budget.category, l10n),
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            isOverBudget 
                                              ? l10n.overBudget 
                                              : '$currency ${formatter.format(budget.amountLimit - budget.currentSpent)} ${l10n.remaining}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isOverBudget ? theme.colorScheme.error : theme.textTheme.bodySmall?.color,
                                              fontWeight: isOverBudget ? FontWeight.bold : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: isOverBudget ? theme.colorScheme.error : category.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // History Tab
              historyBudgets.isEmpty
                  ? EmptyState(
                      message: l10n.noEntriesYet,
                      icon: LucideIcons.history,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyBudgets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final budget = historyBudgets[index];
                        final category = categories.firstWhere(
                          (c) => c.name == budget.category,
                          orElse: () => categories.firstWhere((c) => c.id == 'other'),
                        );
                        final progress = budget.amountLimit > 0 ? budget.currentSpent / budget.amountLimit : 0.0;
                        final isOverBudget = progress > 1.0;
                        final dateFormat = DateFormat.yMMMM(Localizations.localeOf(context).languageCode);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(category.icon, color: Colors.grey, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${CategoryHelper.getLocalizedCategory(budget.category, l10n)} (${dateFormat.format(budget.startDate)})',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color),
                                        ),
                                        Text(
                                          '${l10n.spent}: $currency ${formatter.format(budget.currentSpent)} / ${formatter.format(budget.amountLimit)}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isOverBudget)
                                    Icon(LucideIcons.alertTriangle, color: theme.colorScheme.error, size: 16),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetDialog(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.createBudget),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    Category? selectedCategory;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createBudget),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => CategorySelector(
                      onSelected: (category) {
                        setState(() => selectedCategory = category);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      if (selectedCategory != null) ...[
                        Icon(selectedCategory!.icon, color: selectedCategory!.color, size: 20),
                        const SizedBox(width: 8),
                        Text(selectedCategory!.name),
                      ] else
                        Text(l10n.category), // "Select Category"
                      const Spacer(),
                      const Icon(LucideIcons.chevronDown, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: l10n.monthlyLimit),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (selectedCategory == null) return;
                
                final budget = BudgetModel(
                  ObjectId(),
                  selectedCategory!.name,
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
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.6,
          color: borderColor,
        ),
      ),
    );
  }
}
