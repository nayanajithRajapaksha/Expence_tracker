import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseChart({
    super.key,
    required this.expenses,
  });

  Color _getCategoryColor(
    BuildContext context,
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.pink;
      case 'Bills':
        return Colors.red;
      case 'Education':
        return Colors.indigo;
      case 'Health':
        return Colors.green;
      case 'Entertainment':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final monthlyExpenses = expenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month;
    }).toList();

    final Map<String, double> categoryTotals = {};

    for (final expense in monthlyExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) +
              expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final sections = categoryTotals.entries.map((entry) {
      final percentage = entry.value / total * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: _getCategoryColor(
          context,
          entry.key,
        ),
        radius: 65,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Spending Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Spending distribution by category',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .outline,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 45,
                  sectionsSpace: 3,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: categoryTotals.entries.map(
                (entry) {
                  final color =
                      _getCategoryColor(
                    context,
                    entry.key,
                  );

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
