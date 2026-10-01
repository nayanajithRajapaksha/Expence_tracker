import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/expense_filter.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_card.dart';
import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController =
      TextEditingController();

  // Keeps the exact scroll position when the UI rebuilds.
  final ScrollController _scrollController = ScrollController();

  // Search changes only notify the parts that need to update.
  final ValueNotifier<String> _searchNotifier =
      ValueNotifier<String>('');

  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchNotifier.value = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Expense> _filterExpenses(
    List<Expense> expenses,
    String searchText,
  ) {
    return ExpenseFilter.filter(
      expenses: expenses,
      searchQuery: searchText,
      selectedCategory: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  double _calculateThisMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses
        .where(
          (expense) =>
              expense.date.year == now.year &&
              expense.date.month == now.month,
        )
        .fold(
          0.0,
          (total, expense) => total + expense.amount,
        );
  }

  int _calculateThisMonthCount(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses.where(
      (expense) =>
          expense.date.year == now.year &&
          expense.date.month == now.month,
    ).length;
  }

  Future<void> _openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpenseFormScreen(),
      ),
    );
  }

  Future<void> _openEditExpense(Expense expense) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(
          expense: expense,
        ),
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _expenseService.deleteExpense(expense.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete expense: $e'),
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
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Expenses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String?>(
                      initialValue: tempCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon:
                            Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...[
                          'Food',
                          'Transport',
                          'Shopping',
                          'Bills',
                          'Entertainment',
                          'Health',
                          'Education',
                          'Other',
                        ].map(
                          (category) {
                            return DropdownMenuItem<String?>(
                              value: category,
                              child: Text(category),
                            );
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                      ),
                      title: const Text('Start Date'),
                      subtitle: Text(
                        tempStartDate == null
                            ? 'Not selected'
                            : _formatDate(tempStartDate!),
                      ),
                      trailing: tempStartDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setSheetState(() {
                                  tempStartDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              tempStartDate ??
                                  DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          setSheetState(() {
                            tempStartDate = date;

                            if (tempEndDate != null &&
                                tempEndDate!.isBefore(date)) {
                              tempEndDate = date;
                            }
                          });
                        }
                      },
                    ),

                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: const Text('End Date'),
                      subtitle: Text(
                        tempEndDate == null
                            ? 'Not selected'
                            : _formatDate(tempEndDate!),
                      ),
                      trailing: tempEndDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setSheetState(() {
                                  tempEndDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              tempEndDate ??
                                  tempStartDate ??
                                  DateTime.now(),
                          firstDate:
                              tempStartDate ??
                                  DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          setSheetState(() {
                            tempEndDate = date;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                tempCategory = null;
                                tempStartDate = null;
                                tempEndDate = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              // Remember current scroll position.
                              final currentOffset =
                                  _scrollController.hasClients
                                      ? _scrollController.offset
                                      : 0.0;

                              setState(() {
                                _selectedCategory =
                                    tempCategory;
                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                              });

                              Navigator.pop(context);

                              // Restore position after rebuild.
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) {
                                if (!_scrollController
                                    .hasClients) {
                                  return;
                                }

                                final maxOffset =
                                    _scrollController
                                        .position
                                        .maxScrollExtent;

                                _scrollController.jumpTo(
                                  currentOffset.clamp(
                                    0.0,
                                    maxOffset,
                                  ),
                                );
                              });
                            },
                            child: const Text('Apply'),
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

  void _clearAllFilters() {
    final currentOffset =
        _scrollController.hasClients
            ? _scrollController.offset
            : 0.0;

    _searchController.clear();

    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      final maxOffset =
          _scrollController.position.maxScrollExtent;

      _scrollController.jumpTo(
        currentOffset.clamp(0.0, maxOffset),
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  String _currentMonthName() {
    const months = [
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

    return months[DateTime.now().month - 1];
  }

  bool _hasActiveFilters(String searchText) {
    return searchText.trim().isNotEmpty ||
        _selectedCategory != null ||
        _startDate != null ||
        _endDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (FirebaseAuth.instance.currentUser == null) {
            return const SizedBox.shrink();
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          final allExpenses = snapshot.data ?? [];

          return ValueListenableBuilder<String>(
            valueListenable: _searchNotifier,
            builder: (context, searchText, _) {
              final filteredExpenses = _filterExpenses(
                allExpenses,
                searchText,
              );

              final filteredTotal =
                  _calculateTotal(filteredExpenses);

              final thisMonthTotal =
                  _calculateThisMonthTotal(allExpenses);

              final thisMonthCount =
                  _calculateThisMonthCount(allExpenses);

              final hasActiveFilters =
                  _hasActiveFilters(searchText);

              return RefreshIndicator(
                onRefresh: () async {
                  // Firestore stream automatically updates.
                  // No unnecessary rebuild is required.
                  await Future<void>.delayed(
                    const Duration(milliseconds: 300),
                  );
                },

                child: CustomScrollView(
                  key: const PageStorageKey(
                    'expense-home-scroll',
                  ),

                  controller: _scrollController,

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  slivers: [

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 20),


                            Card(
                              elevation: 2,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(12),
                                          decoration:
                                              BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .onPrimaryContainer,
                                            size: 28,
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              const Text(
                                                'This Month Expenses',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                _currentMonthName(),
                                                style: TextStyle(
                                                  color: Colors
                                                      .grey
                                                      .shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    Text(
                                      _formatCurrency(
                                        thisMonthTotal,
                                      ),
                                      style:
                                          const TextStyle(
                                        fontSize: 30,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '$thisMonthCount '
                                      'expense${thisMonthCount == 1 ? '' : 's'} this month',
                                      style: TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),


                            TextField(
                              controller: _searchController,
                              textInputAction:
                                  TextInputAction.search,
                              decoration: InputDecoration(
                                hintText:
                                    'Search expenses by title...',
                                prefixIcon:
                                    const Icon(Icons.search),

                                suffixIcon:
                                    searchText.isNotEmpty
                                        ? IconButton(
                                            tooltip:
                                                'Clear search',
                                            icon:
                                                const Icon(
                                              Icons.clear,
                                            ),
                                            onPressed: () {
                                              _searchController
                                                  .clear();
                                            },
                                          )
                                        : null,

                                border:
                                    const OutlineInputBorder(),

                                filled: true,
                              ),
                            ),

                            const SizedBox(height: 12),


                            Row(
                              children: [
                                Expanded(
                                  child:
                                      OutlinedButton.icon(
                                    onPressed:
                                        _showFilterSheet,
                                    icon: const Icon(
                                      Icons.filter_list,
                                    ),
                                    label: Text(
                                      hasActiveFilters
                                          ? 'Filters Applied'
                                          : 'Filter',
                                    ),
                                  ),
                                ),

                                if (hasActiveFilters) ...[
                                  const SizedBox(width: 8),

                                  IconButton(
                                    tooltip:
                                        'Clear filters',
                                    onPressed:
                                        _clearAllFilters,
                                    icon: const Icon(
                                      Icons.filter_alt_off,
                                    ),
                                  ),
                                ],
                              ],
                            ),


                            if (hasActiveFilters) ...[
                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_selectedCategory !=
                                      null)
                                    Chip(
                                      avatar: const Icon(
                                        Icons.category,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _selectedCategory!,
                                      ),
                                    ),

                                  if (_startDate != null)
                                    Chip(
                                      avatar: const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'From ${_formatDate(_startDate!)}',
                                      ),
                                    ),

                                  if (_endDate != null)
                                    Chip(
                                      avatar: const Icon(
                                        Icons.event,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'To ${_formatDate(_endDate!)}',
                                      ),
                                    ),

                                  if (searchText
                                      .trim()
                                      .isNotEmpty)
                                    Chip(
                                      avatar: const Icon(
                                        Icons.search,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '"${searchText.trim()}"',
                                      ),
                                    ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),


                            if (hasActiveFilters)
                              Card(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    18,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.filter_alt,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'Filtered Total',
                                              style: TextStyle(
                                                color: Colors
                                                    .grey
                                                    .shade600,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              _formatCurrency(
                                                filteredTotal,
                                              ),
                                              style:
                                                  const TextStyle(
                                                fontSize: 20,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            if (hasActiveFilters)
                              const SizedBox(height: 16),


                            if (filteredExpenses.isNotEmpty)
                              ExpenseChart(
                                key: const ValueKey(
                                  'expense-chart',
                                ),
                                expenses: filteredExpenses,
                              ),

                            if (filteredExpenses.isNotEmpty)
                              const SizedBox(height: 20),


                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Expenses',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                  '${filteredExpenses.length} item'
                                  '${filteredExpenses.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),


                    if (filteredExpenses.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  hasActiveFilters
                                      ? Icons
                                          .search_off_outlined
                                      : Icons
                                          .receipt_long_outlined,
                                  size: 64,
                                  color:
                                      Colors.grey.shade400,
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  hasActiveFilters
                                      ? 'No matching expenses'
                                      : 'No expenses yet',
                                  style:
                                      const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  hasActiveFilters
                                      ? 'Try changing your search or filters.'
                                      : 'Add your first expense to get started.',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600,
                                  ),
                                ),

                                if (hasActiveFilters) ...[
                                  const SizedBox(height: 16),

                                  OutlinedButton(
                                    onPressed:
                                        _clearAllFilters,
                                    child: const Text(
                                      'Clear Filters',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    else

                      SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, index) {
                            final expense =
                                filteredExpenses[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: ExpenseCard(
                                expense: expense,
                                onEdit: () => _openEditExpense(expense),
                                onDelete: () => _deleteExpense(expense),
                              ),
                            );
                          },
                          childCount:
                              filteredExpenses.length,
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),


      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

}