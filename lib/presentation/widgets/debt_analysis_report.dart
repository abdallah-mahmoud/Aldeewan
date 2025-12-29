import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';

// Date range filter provider
enum DebtDateRange { allTime, thisMonth }
final debtDateRangeProvider = StateProvider<DebtDateRange>((ref) => DebtDateRange.allTime);

class DebtAnalysisReport extends ConsumerWidget {
  const DebtAnalysisReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final dateRange = ref.watch(debtDateRangeProvider);
    
    final totalReceivable = ref.watch(totalReceivableProvider);
    final totalPayable = ref.watch(totalPayableProvider);
    final netPosition = totalReceivable - totalPayable;
    
    final ledgerState = ref.watch(ledgerProvider);
    
    return ledgerState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
      data: (state) {
        final notifier = ref.read(ledgerProvider.notifier);
        
        // Get persons with balances
        final personsWithBalance = state.persons.where((p) {
          final balance = notifier.calculatePersonBalance(p);
          return balance != 0;
        }).toList();
        
        // Separate into customers and suppliers
        final customersOwing = personsWithBalance.where((p) {
          final balance = notifier.calculatePersonBalance(p);
          return p.role == PersonRole.customer && balance > 0;
        }).toList();
        
        final suppliersOwed = personsWithBalance.where((p) {
          final balance = notifier.calculatePersonBalance(p);
          return p.role == PersonRole.supplier && balance > 0;
        }).toList();
        
        // Sort by absolute balance descending
        customersOwing.sort((a, b) {
          final balA = notifier.calculatePersonBalance(a).abs();
          final balB = notifier.calculatePersonBalance(b).abs();
          return balB.compareTo(balA);
        });
        
        suppliersOwed.sort((a, b) {
          final balA = notifier.calculatePersonBalance(a).abs();
          final balB = notifier.calculatePersonBalance(b).abs();
          return balB.compareTo(balA);
        });
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Filter
              Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.allTime),
                    selected: dateRange == DebtDateRange.allTime,
                    onSelected: (_) {
                      ref.read(debtDateRangeProvider.notifier).state = DebtDateRange.allTime;
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text(l10n.thisMonth),
                    selected: dateRange == DebtDateRange.thisMonth,
                    onSelected: (_) {
                      ref.read(debtDateRangeProvider.notifier).state = DebtDateRange.thisMonth;
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Export Button at top
              OutlinedButton.icon(
                onPressed: () => _exportReport(context, ref, customersOwing, suppliersOwed, notifier, currency),
                icon: const Icon(LucideIcons.download),
                label: Text(l10n.exportDebtReport),
              ),
              SizedBox(height: 16.h),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: l10n.totalReceivable,
                      value: CurrencyFormatter.format(totalReceivable, currency),
                      color: AppColors.success,
                      icon: LucideIcons.arrowDownCircle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SummaryCard(
                      label: l10n.totalPayable,
                      value: CurrencyFormatter.format(totalPayable, currency),
                      color: AppColors.error,
                      icon: LucideIcons.arrowUpCircle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Net Position Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.netPosition,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      CurrencyFormatter.format(netPosition, currency),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: netPosition >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      netPosition >= 0 ? l10n.customersOweYouMore : l10n.youOweSuppliersMore,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              // Comparison Bar Chart
              _ComparisonBarChart(
                receivable: totalReceivable,
                payable: totalPayable,
                currency: currency,
              ),
              SizedBox(height: 24.h),
              
              // Customers Section
              _SectionHeader(
                title: l10n.customersCount(customersOwing.length.toString()),
                color: AppColors.success,
              ),
              SizedBox(height: 8.h),
              if (customersOwing.isEmpty)
                _EmptySection(message: l10n.noEntriesYet)
              else
                ...customersOwing.map((person) => _PersonCard(
                  person: person,
                  balance: notifier.calculatePersonBalance(person),
                  isReceivable: true,
                  currency: currency,
                )),
              SizedBox(height: 24.h),
              
              // Suppliers Section
              _SectionHeader(
                title: l10n.suppliersCount(suppliersOwed.length.toString()),
                color: AppColors.error,
              ),
              SizedBox(height: 8.h),
              if (suppliersOwed.isEmpty)
                _EmptySection(message: l10n.noEntriesYet)
              else
                ...suppliersOwed.map((person) => _PersonCard(
                  person: person,
                  balance: notifier.calculatePersonBalance(person),
                  isReceivable: false,
                  currency: currency,
                )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportReport(
    BuildContext context,
    WidgetRef ref,
    List<Person> customers,
    List<Person> suppliers,
    LedgerNotifier notifier,
    String currency,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final rows = <List<dynamic>>[
        ['Name', 'Role', 'Balance', 'Type'],
      ];

      for (var p in customers) {
        final balance = notifier.calculatePersonBalance(p);
        rows.add([p.name, 'Customer', balance.abs(), 'Receivable']);
      }

      for (var p in suppliers) {
        final balance = notifier.calculatePersonBalance(p);
        rows.add([p.name, 'Supplier', balance.abs(), 'Payable']);
      }

      final fileName = 'debt_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      await CsvExporter.exportToCsv(
        fileName: fileName,
        rows: rows,
        subject: 'Aldeewan Debt Report',
        text: 'Export of debt balances.',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(24.w),
      alignment: Alignment.center,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  final double balance;
  final bool isReceivable;
  final String currency;

  const _PersonCard({
    required this.person,
    required this.balance,
    required this.isReceivable,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = isReceivable ? AppColors.success : AppColors.error;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 0,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () => context.push('/ledger/${person.id}'),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          person.name,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          person.role == PersonRole.customer ? l10n.customer : l10n.supplier,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          NumberFormat.currency(
            symbol: currency,
            decimalDigits: currency == 'SDG' ? 0 : 2,
          ).format(balance.abs()),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonBarChart extends StatelessWidget {
  final double receivable;
  final double payable;
  final String currency;

  const _ComparisonBarChart({
    required this.receivable,
    required this.payable,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final total = receivable + payable;
    final receivableRatio = total > 0 ? receivable / total : 0.5;
    final payableRatio = total > 0 ? payable / total : 0.5;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.debtBreakdown,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          
          // Receivable Bar
          _BarRow(
            label: l10n.totalReceivable,
            value: CurrencyFormatter.format(receivable, currency),
            ratio: receivableRatio,
            color: AppColors.success,
          ),
          SizedBox(height: 12.h),
          
          // Payable Bar
          _BarRow(
            label: l10n.totalPayable,
            value: CurrencyFormatter.format(payable, currency),
            ratio: payableRatio,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final String value;
  final double ratio;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 10.h,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
          ),
        ),
      ],
    );
  }
}
