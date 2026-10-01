import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseChart extends StatefulWidget {
  final List<Expense> expenses;

  const ExpenseChart({
    super.key,
    required this.expenses,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  bool _showPieChart = true;

  String? _selectedMonth;


  final Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
    'Entertainment': Colors.pink,
    'Health': Colors.green,
    'Education': Colors.teal,
    'Other': Colors.grey,
  };


  @override
  void didUpdateWidget(
    covariant ExpenseChart oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final months = _getAvailableMonths();

    if (_selectedMonth != null &&
        !months.contains(_selectedMonth)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _selectedMonth =
              months.isNotEmpty ? months.last : null;
        });
      });
    }
  }


  List<String> _getAvailableMonths() {
    final months = <String>{};

    for (final expense in widget.expenses) {
      months.add(
        _monthKey(expense.date),
      );
    }

    final result = months.toList()
      ..sort();

    return result;
  }


  String _monthKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}';
  }


  String _formatMonth(String key) {
    final parts = key.split('-');

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[month - 1]} $year';
  }


  Map<String, Map<String, double>>
      _getMonthlyCategorySpending() {
    final result =
        <String, Map<String, double>>{};

    for (final expense in widget.expenses) {
      final month =
          _monthKey(expense.date);

      result.putIfAbsent(
        month,
        () => <String, double>{},
      );

      result[month]![expense.category] =
          (result[month]![expense.category] ??
                  0) +
              expense.amount;
    }

    return result;
  }


  Map<String, double>
      _getSelectedMonthCategories(
    String selectedMonth,
  ) {
    final categorySpending =
        <String, double>{};

    for (final expense in widget.expenses) {
      if (_monthKey(expense.date) ==
          selectedMonth) {
        categorySpending[expense.category] =
            (categorySpending[
                        expense.category] ??
                    0) +
                expense.amount;
      }
    }

    return categorySpending;
  }


  Color _getCategoryColor(
    String category,
  ) {
    return _categoryColors[category] ??
        Colors.grey;
  }


  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }


  @override
  Widget build(BuildContext context) {
    final months = _getAvailableMonths();


    if (widget.expenses.isEmpty ||
        months.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey,
              ),

              const SizedBox(height: 12),

              Text(
                'No chart data for the selected filters.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }


    final selectedMonth =
        (_selectedMonth != null &&
                months.contains(
                    _selectedMonth))
            ? _selectedMonth!
            : months.last;


    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Expense Analytics',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Category and monthly spending analysis',
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            // PIE / GRAPH SWITCH

            SizedBox(
              width: double.infinity,
              child:
                  SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(
                      Icons
                          .pie_chart_outline,
                    ),
                    label:
                        Text('Pie Chart'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(
                      Icons.bar_chart,
                    ),
                    label:
                        Text('Graph'),
                  ),
                ],
                selected: {
                  _showPieChart
                },
                onSelectionChanged:
                    (selection) {
                  setState(() {
                    _showPieChart =
                        selection.first;
                  });
                },
              ),
            ),

            const SizedBox(height: 18),


            if (_showPieChart) ...[
              const Text(
                'Select Month',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),


              DropdownButtonFormField<
                  String>(
                initialValue: selectedMonth,
                decoration:
                    const InputDecoration(
                  prefixIcon: Icon(
                    Icons
                        .calendar_month_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                items: months.map(
                  (month) {
                    return DropdownMenuItem<
                        String>(
                      value: month,
                      child: Text(
                        _formatMonth(
                            month),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedMonth =
                        value;
                  });
                },
              ),

              const SizedBox(height: 24),


              _buildPieChart(
                selectedMonth,
              ),
            ]


            else ...[
              const SizedBox(height: 10),

              _buildMonthlyGraph(),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildPieChart(
    String selectedMonth,
  ) {
    final categorySpending =
        _getSelectedMonthCategories(
      selectedMonth,
    );

    if (categorySpending.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No expenses for this month.',
          ),
        ),
      );
    }

    final entries =
        categorySpending.entries.toList();

    final total =
        entries.fold<double>(
      0,
      (sum, entry) =>
          sum + entry.value,
    );

    return Column(
      children: [

        SizedBox(
          height: 270,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,

              centerSpaceRadius: 50,

              sections:
                  entries.map(
                (entry) {
                  final percentage =
                      (entry.value /
                              total) *
                          100;

                  return PieChartSectionData(
                    value:
                        entry.value,

                    // IMPORTANT:
                    // Each category gets
                    // its own color.
                    color:
                        _getCategoryColor(
                      entry.key,
                    ),

                    title:
                        '${percentage.toStringAsFixed(1)}%',

                    radius: 90,

                    titleStyle:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.white,
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ),

        const SizedBox(height: 18),


        ...entries.map(
          (entry) {
            final percentage =
                (entry.value /
                        total) *
                    100;

            return Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 6,
              ),
              child: Row(
                children: [

                  Container(
                    width: 14,
                    height: 14,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          _getCategoryColor(
                        entry.key,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),


                  Expanded(
                    child: Text(
                      entry.key,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),


                  Text(
                    'Rs. ${entry.value.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),


                  SizedBox(
                    width: 52,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      textAlign:
                          TextAlign.end,
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildMonthlyGraph() {
    final monthlyCategories =
        _getMonthlyCategorySpending();

    final entries =
        monthlyCategories.entries.toList()
          ..sort(
            (a, b) =>
                a.key.compareTo(b.key),
          );

    if (entries.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No monthly spending data.',
          ),
        ),
      );
    }


    final monthlyTotals =
        entries.map(
      (monthEntry) {
        return monthEntry.value
            .values
            .fold<double>(
          0,
          (sum, value) =>
              sum + value,
        );
      },
    ).toList();

    final maxAmount =
        monthlyTotals.reduce(
      (a, b) => a > b ? a : b,
    );


    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Spending',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Category breakdown for each month',
          style: TextStyle(
            fontSize: 12,
            color:
                Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),


        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(

              maxY: maxAmount == 0
                  ? 100
                  : maxAmount * 1.2,


              barTouchData:
                  BarTouchData(
                enabled: true,

                touchTooltipData:
                    BarTouchTooltipData(
                  getTooltipItem:
                      (
                    group,
                    groupIndex,
                    rod,
                    rodIndex,
                  ) {
                    final month =
                        entries[group.x];

                    final total =
                        month.value
                            .values
                            .fold<double>(
                          0,
                          (sum, value) =>
                              sum + value,
                        );

                    return BarTooltipItem(
                      '${_formatMonth(month.key)}\n'
                      'Total: Rs. ${total.toStringAsFixed(2)}',
                      const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),


              titlesData:
                  FlTitlesData(
                // Top
                topTitles:
                    const AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        false,
                  ),
                ),

                // Right
                rightTitles:
                    const AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        false,
                  ),
                ),

                // Left
                leftTitles:
                    AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        true,
                    reservedSize:
                        55,
                    getTitlesWidget:
                        (value, meta) {
                      return Text(
                        _formatAmount(
                          value,
                        ),
                        style:
                            const TextStyle(
                          fontSize:
                              10,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom
                bottomTitles:
                    AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        true,
                    reservedSize:
                        45,
                    getTitlesWidget:
                        (value, meta) {
                      final index =
                          value.toInt();

                      if (index <
                              0 ||
                          index >=
                              entries
                                  .length) {
                        return const SizedBox
                            .shrink();
                      }

                      final month =
                          _formatMonth(
                        entries[index]
                            .key,
                      );

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 8,
                        ),
                        child: Text(
                          month.substring(
                            0,
                            3,
                          ),
                          style:
                              const TextStyle(
                            fontSize:
                                10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),


              gridData:
                  FlGridData(
                show: true,
                drawVerticalLine:
                    false,
              ),


              borderData:
                  FlBorderData(
                show: false,
              ),


              barGroups:
                  List.generate(
                entries.length,
                (index) {
                  final categoryData =
                      entries[index].value;

                  final stackItems =
                      <BarChartRodStackItem>[];

                  double fromY = 0;


                  for (final categoryEntry
                      in categoryData
                          .entries) {
                    final toY =
                        fromY +
                            categoryEntry
                                .value;

                    stackItems.add(
                      BarChartRodStackItem(
                        fromY,
                        toY,
                        _getCategoryColor(
                          categoryEntry
                              .key,
                        ),
                      ),
                    );

                    fromY = toY;
                  }

                  return BarChartGroupData(
                    x: index,

                    barRods: [
                      BarChartRodData(
                        toY: fromY,

                        width: 30,

                        borderRadius:
                            BorderRadius
                                .circular(
                          4,
                        ),

                        // IMPORTANT:
                        // This creates the
                        // multi-colour stacked
                        // bar.
                        rodStackItems:
                            stackItems,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),


        const Text(
          'Categories',
          style: TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 16,
          runSpacing: 10,
          children:
              _categoryColors.keys.map(
            (category) {
              // Only show categories that
              // actually exist in the data.
              final hasData =
                  entries.any(
                (month) =>
                    month.value
                        .containsKey(
                  category,
                ),
              );

              if (!hasData) {
                return const SizedBox
                    .shrink();
              }

              return Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(
                      color:
                          _getCategoryColor(
                        category,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    category,
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),

        const SizedBox(height: 18),


        ...entries.map(
          (entry) {
            final total =
                entry.value.values
                    .fold<double>(
              0,
              (sum, value) =>
                  sum + value,
            );

            return Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatMonth(
                        entry.key,
                      ),
                    ),
                  ),

                  Text(
                    'Rs. ${total.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}