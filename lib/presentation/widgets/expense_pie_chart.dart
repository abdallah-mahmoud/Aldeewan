import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Transaction> transactions;

  const ExpensePieChart({super.key, required this.transactions});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpensesByCategory();
    
    if (groupedExpenses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No expenses to show')),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: [
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: _showingSections(groupedExpenses),
                ),
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Map<String, double> _groupExpensesByCategory() {
    final Map<String, double> map = {};
    for (final t in widget.transactions) {
      if (t.type == TransactionType.cashExpense || t.type == TransactionType.paymentMade) {
        final category = t.category ?? 'Uncategorized';
        map[category] = (map[category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  List<PieChartSectionData> _showingSections(Map<String, double> data) {
    final List<PieChartSectionData> sections = [];
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    data.forEach((category, amount) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (amount / total * 100).toStringAsFixed(1);

      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: amount,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
          child: Text(category, style: const TextStyle(color: Colors.black)),
        ) : null,
        badgePositionPercentageOffset: .98,
      ));
      i++;
    });

    return sections;
  }
}
