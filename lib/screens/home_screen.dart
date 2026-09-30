import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_summary.dart';
import '../widgets/expense_chart.dart';
import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();

  late final Stream<List<Expense>> _expenseStream;

  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  bool get _hasFilters =>
      _selectedCategory != null ||
      _startDate != null ||
      _endDate != null;

  @override
  void initState() {
    super.initState();

    _expenseStream = _expenseService.getExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  List<Expense> _filterExpenses(
    List<Expense> expenses,
    String searchQuery,
  ) {
    return expenses.where((expense) {
      // Search by title
      if (searchQuery.isNotEmpty &&
          !expense.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              )) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null &&
          expense.category != _selectedCategory) {
        return false;
      }

      // Start date filter
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

      // End date filter
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
      return '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
          ' - '
          '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    }

    if (_startDate != null) {
      return 'From ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
    }

    return 'Until ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            final bool invalidDateRange =
                tempStartDate != null &&
                tempEndDate != null &&
                tempEndDate!.isBefore(tempStartDate!);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
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
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
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
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate:
                                    tempStartDate ?? DateTime.now(),
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
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate:
                                    tempEndDate ?? DateTime.now(),
                              );

                              if (picked != null) {
                                setSheetState(() {
                                  tempEndDate = picked;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.event,
                            ),
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

                    const SizedBox(height: 12),

                    // Invalid date range message
                    if (invalidDateRange)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Invalid date range. '
                                'End date cannot be before start date.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              // Validate date range
                              if (tempStartDate != null &&
                                  tempEndDate != null &&
                                  tempEndDate!
                                      .isBefore(tempStartDate!)) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invalid date range: '
                                      'End date cannot be before '
                                      'start date.',
                                    ),
                                    behavior:
                                        SnackBarBehavior.floating,
                                  ),
                                );

                                return;
                              }

                              Navigator.pop(context);

                              setState(() {
                                _selectedCategory = tempCategory;
                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                              });
                            },
                            child: const Text(
                              'Apply Filters',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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

    final String userEmail =
        _currentUser?.email ?? 'User';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              userEmail,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),

        actions: [
          // Refresh
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),

          // Logout
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseStream,

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
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

          final allExpenses =
              snapshot.data ?? [];

          return ValueListenableBuilder<String>(
            valueListenable: _searchQuery,

            builder: (
              context,
              searchQuery,
              child,
            ) {
              final filteredExpenses =
                  _filterExpenses(
                allExpenses,
                searchQuery,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});

                  await Future.delayed(
                    const Duration(
                      milliseconds: 500,
                    ),
                  );
                },

                child: ListView(
                  controller: _scrollController,

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    100,
                  ),

                  children: [
                    // Summary
                    ExpenseSummary(
                      expenses: allExpenses,
                    ),

                    const SizedBox(height: 16),

                    // Chart
                    ExpenseChart(
                      expenses: allExpenses,
                    ),

                    const SizedBox(height: 24),

                    // Search
                    TextField(
                      controller: _searchController,

                      onChanged: (value) {
                        _searchQuery.value =
                            value.trim();
                      },

                      decoration: InputDecoration(
                        hintText:
                            'Search expenses...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        suffixIcon:
                            searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController
                                          .clear();

                                      _searchQuery.value =
                                          '';
                                    },
                                    icon:
                                        const Icon(
                                      Icons.clear,
                                    ),
                                  )
                                : null,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Expense history header
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Expense History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        IconButton.filledTonal(
                          tooltip:
                              'Filter expenses',

                          onPressed:
                              _showFilterSheet,

                          icon: Badge(
                            isLabelVisible:
                                _hasFilters,

                            label:
                                const Text(''),

                            child: const Icon(
                              Icons.filter_list,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Active filters
                    if (_hasFilters) ...[
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedCategory !=
                              null)
                            Chip(
                              label: Text(
                                _selectedCategory!,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory =
                                      null;
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
                                const Text(
                              'Clear all',
                            ),
                            onPressed:
                                _clearFilters,
                          ),
                        ],
                      ),
                    ],

                    // Search results count
                    if (searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Text(
                        '${filteredExpenses.length} '
                        'result'
                        '${filteredExpenses.length == 1 ? '' : 's'} '
                        'found',

                        style: TextStyle(
                          color:
                              theme.colorScheme
                                  .outline,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Empty state
                    if (filteredExpenses.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 80,
                        ),

                        child: Column(
                          children: [
                            Icon(
                              searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : _hasFilters
                                      ? Icons
                                          .filter_alt_off_outlined
                                      : Icons
                                          .receipt_long_outlined,

                              size: 64,

                              color:
                                  theme.colorScheme
                                      .primary,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            Text(
                              searchQuery.isNotEmpty
                                  ? 'No expenses found'
                                  : _hasFilters
                                      ? 'No matching expenses'
                                      : 'No expenses yet',

                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              searchQuery.isNotEmpty
                                  ? 'Try a different search term.'
                                  : _hasFilters
                                      ? 'Try changing your filters.'
                                      : 'Start tracking your spending today.',

                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        ),
                      )

                    // Expense list
                    else
                      ...filteredExpenses.map(
                        (expense) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            child: ExpenseCard(
                              expense: expense,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // Add Expense
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

        label: const Text(
          'Add Expense',
        ),
      ),
    );
  }
}
