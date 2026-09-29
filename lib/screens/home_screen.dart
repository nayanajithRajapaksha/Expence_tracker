import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_summary.dart';
import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();

  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _hasFilters {
    return _selectedCategory != null ||
        _startDate != null ||
        _endDate != null;
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      if (_selectedCategory != null &&
          expense.category != _selectedCategory) {
        return false;
      }

      if (_startDate != null) {
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );

        if (expense.date.isBefore(start)) {
          return false;
        }
      }

      if (_endDate != null) {
        final end = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );

        if (expense.date.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _dateFilterText() {
    if (_startDate != null && _endDate != null) {
      return '${_startDate!.day}/${_startDate!.month} - '
          '${_endDate!.day}/${_endDate!.month}';
    }

    if (_startDate != null) {
      return 'From ${_startDate!.day}/${_startDate!.month}';
    }

    return 'Until ${_endDate!.day}/${_endDate!.month}';
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _showFilterSheet() async {
    String? tempCategory = _selectedCategory;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Expenses',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: tempCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      DropdownMenuItem(
                        value: 'Food',
                        child: Text('Food'),
                      ),
                      DropdownMenuItem(
                        value: 'Transport',
                        child: Text('Transport'),
                      ),
                      DropdownMenuItem(
                        value: 'Shopping',
                        child: Text('Shopping'),
                      ),
                      DropdownMenuItem(
                        value: 'Bills',
                        child: Text('Bills'),
                      ),
                      DropdownMenuItem(
                        value: 'Education',
                        child: Text('Education'),
                      ),
                      DropdownMenuItem(
                        value: 'Health',
                        child: Text('Health'),
                      ),
                      DropdownMenuItem(
                        value: 'Entertainment',
                        child: Text('Entertainment'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        tempCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked =
                                await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate:
                                  tempStartDate ??
                                      DateTime.now(),
                            );

                            if (picked != null) {
                              setSheetState(() {
                                tempStartDate = picked;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_today,
                          ),
                          label: Text(
                            tempStartDate == null
                                ? 'Start date'
                                : '${tempStartDate!.day}/'
                                    '${tempStartDate!.month}/'
                                    '${tempStartDate!.year}',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked =
                                await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate:
                                  tempEndDate ??
                                      DateTime.now(),
                            );

                            if (picked != null) {
                              setSheetState(() {
                                tempEndDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                            tempEndDate == null
                                ? 'End date'
                                : '${tempEndDate!.day}/'
                                    '${tempEndDate!.month}/'
                                    '${tempEndDate!.year}',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearFilters();
                          },
                          child: const Text('Clear'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory =
                                  tempCategory;
                              _startDate = tempStartDate;
                              _endDate = tempEndDate;
                            });

                            Navigator.pop(context);
                          },
                          child:
                              const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage your spending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allExpenses = snapshot.data ?? [];

          final filteredExpenses =
              _filterExpenses(allExpenses);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});

              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                100,
              ),

              children: [
                ExpenseSummary(
                  expenses: allExpenses,
                ),

                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expense History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton.filledTonal(
                      tooltip: 'Filter expenses',
                      onPressed: _showFilterSheet,
                      icon: Badge(
                        isLabelVisible: _hasFilters,
                        label: const Text(''),
                        child: const Icon(
                          Icons.filter_list,
                        ),
                      ),
                    ),
                  ],
                ),



                if (_hasFilters) ...[
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text(
                            _selectedCategory!,
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),

                      if (_startDate != null ||
                          _endDate != null)
                        Chip(
                          label: Text(
                            _dateFilterText(),
                          ),
                          onDeleted: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                        ),

                      ActionChip(
                        label:
                            const Text('Clear all'),
                        onPressed: _clearFilters,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),



                if (filteredExpenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 80,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _hasFilters
                              ? Icons
                                  .filter_alt_off_outlined
                              : Icons
                                  .receipt_long_outlined,
                          size: 64,
                          color:
                              theme.colorScheme.primary,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          _hasFilters
                              ? 'No matching expenses'
                              : 'No expenses yet',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _hasFilters
                              ? 'Try changing your filters.'
                              : 'Start tracking your spending today.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredExpenses.map(
                    (expense) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ExpenseCard(
                        expense: expense,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),



      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ExpenseFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}