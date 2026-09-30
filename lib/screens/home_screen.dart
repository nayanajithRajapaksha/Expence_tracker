import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/expense_filter.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_summary.dart';
import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _searchController =
      TextEditingController();

  final ValueNotifier<String> _searchQuery =
      ValueNotifier<String>('');

  final ScrollController _scrollController =
      ScrollController();

  Stream<List<Expense>>? _expenseStream;

  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _setupExpenseStream();

    _searchController.addListener(() {
      _searchQuery.value =
          _searchController.text.trim();
    });
  }

  void _setupExpenseStream() {
    if (FirebaseAuth.instance.currentUser != null) {
      _expenseStream =
          _expenseService.getExpenses();
    } else {
      _expenseStream = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

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

  Future<void> _confirmLogout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  // ------------------------------------------------------------
  // FILTER HELPERS
  // ------------------------------------------------------------

  bool get _hasFilters {
    return _selectedCategory != null ||
        _startDate != null ||
        _endDate != null;
  }

  List<Expense> _filterExpenses(
    List<Expense> expenses,
  ) {
    return ExpenseFilter.filter(
      expenses: expenses,
      searchQuery: _searchQuery.value,
      selectedCategory: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  String _dateFilterText() {
    if (_startDate == null && _endDate == null) {
      return 'All dates';
    }

    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    if (_startDate != null && _endDate != null) {
      return '${formatDate(_startDate!)} - '
          '${formatDate(_endDate!)}';
    }

    if (_startDate != null) {
      return 'From ${formatDate(_startDate!)}';
    }

    return 'Until ${formatDate(_endDate!)}';
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  // ------------------------------------------------------------
  // FILTER BOTTOM SHEET
  // ------------------------------------------------------------

  Future<void> _showFilterSheet() async {
    String? temporaryCategory =
        _selectedCategory;

    DateTime? temporaryStartDate =
        _startDate;

    DateTime? temporaryEndDate =
        _endDate;

    final result =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            Future<void> selectStartDate() async {
              final selected =
                  await showDatePicker(
                context: context,
                initialDate:
                    temporaryStartDate ??
                        DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText:
                    'Select start date',
              );

              if (selected != null) {
                setModalState(() {
                  temporaryStartDate =
                      selected;
                });
              }
            }

            Future<void> selectEndDate() async {
              final selected =
                  await showDatePicker(
                context: context,
                initialDate:
                    temporaryEndDate ??
                        DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText:
                    'Select end date',
              );

              if (selected != null) {
                setModalState(() {
                  temporaryEndDate =
                      selected;
                });
              }
            }

            final invalidDateRange =
                temporaryStartDate != null &&
                    temporaryEndDate != null &&
                    temporaryEndDate!
                        .isBefore(
                      temporaryStartDate!,
                    );

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom:
                      MediaQuery.of(context)
                              .viewInsets
                              .bottom +
                          20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Expenses',
                              style:
                                  TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // CATEGORY
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String?>(
                        value:
                            temporaryCategory,
                        decoration:
                            const InputDecoration(
                          border:
                              OutlineInputBorder(),
                          hintText:
                              'All categories',
                        ),
                        items: [
                          const DropdownMenuItem<
                              String?>(
                            value: null,
                            child: Text(
                              'All categories',
                            ),
                          ),
                          ...AppConstants
                              .categories
                              .map(
                            (category) {
                              return DropdownMenuItem<
                                  String?>(
                                value: category,
                                child:
                                    Text(category),
                              );
                            },
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            temporaryCategory =
                                value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // START DATE
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      InkWell(
                        onTap: selectStartDate,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(
                            border:
                                OutlineInputBorder(),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                            ),
                          ),
                          child: Text(
                            temporaryStartDate ==
                                    null
                                ? 'Select start date'
                                : '${temporaryStartDate!.day.toString().padLeft(2, '0')}/'
                                    '${temporaryStartDate!.month.toString().padLeft(2, '0')}/'
                                    '${temporaryStartDate!.year}',
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // END DATE
                      const Text(
                        'End Date',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      InkWell(
                        onTap: selectEndDate,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(
                            border:
                                OutlineInputBorder(),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                            ),
                          ),
                          child: Text(
                            temporaryEndDate ==
                                    null
                                ? 'Select end date'
                                : '${temporaryEndDate!.day.toString().padLeft(2, '0')}/'
                                    '${temporaryEndDate!.month.toString().padLeft(2, '0')}/'
                                    '${temporaryEndDate!.year}',
                          ),
                        ),
                      ),

                      // INVALID DATE MESSAGE
                      if (invalidDateRange) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'End date cannot be before start date.',
                                style:
                                    TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 25),

                      // BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton(
                              onPressed: () {
                                setModalState(
                                  () {
                                    temporaryCategory =
                                        null;
                                    temporaryStartDate =
                                        null;
                                    temporaryEndDate =
                                        null;
                                  },
                                );
                              },
                              child:
                                  const Text(
                                'Clear',
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  invalidDateRange
                                      ? () {
                                          ScaffoldMessenger
                                              .of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text(
                                                'Please select a valid date range.',
                                              ),
                                            ),
                                          );
                                        }
                                      : () {
                                          Navigator.pop(
                                            context,
                                            true,
                                          );
                                        },
                              child:
                                  const Text(
                                'Apply',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _selectedCategory =
            temporaryCategory;

        _startDate =
            temporaryStartDate;

        _endDate =
            temporaryEndDate;
      });
    }
  }

  // ------------------------------------------------------------
  // ADD EXPENSE
  // ------------------------------------------------------------

  Future<void> _addExpense() async {
    if (_currentUser == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ExpenseFormScreen(),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    // Prevent temporary Firestore
    // permission errors during logout.
    if (user == null) {
      return const Scaffold(
        body: SizedBox.shrink(),
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
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _setupExpenseStream();
              });
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          IconButton(
            tooltip: 'Logout',
            onPressed: _confirmLogout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(35),

          child: Padding(
            padding:
                const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),

            child: Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                user.email ??
                    'Logged in user',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ),
          ),
        ),
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseStream,

        builder: (
          context,
          snapshot,
        ) {
          // Prevent Firestore error
          // after logout.
          if (FirebaseAuth
                  .instance
                  .currentUser ==
              null) {
            return const SizedBox.shrink();
          }

          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return ErrorState(
              message:
                  snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _setupExpenseStream();
                });
              },
            );
          }

          final allExpenses =
              snapshot.data ?? <Expense>[];

          return ValueListenableBuilder<
              String>(
            valueListenable:
                _searchQuery,

            builder: (
              context,
              searchQuery,
              child,
            ) {
              final currentExpenses =
                  _filterExpenses(
                allExpenses,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _setupExpenseStream();
                  });

                  await Future.delayed(
                    const Duration(
                      milliseconds: 300,
                    ),
                  );
                },

                child: CustomScrollView(
                  controller:
                      _scrollController,

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  slivers: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          16,
                          16,
                          0,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            // SUMMARY
                            ExpenseSummary(
                              expenses:
                                  allExpenses,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // SEARCH
                            TextField(
                              controller:
                                  _searchController,

                              textInputAction:
                                  TextInputAction
                                      .search,

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Search expenses by title...',

                                prefixIcon:
                                    const Icon(
                                  Icons.search,
                                ),

                                suffixIcon:
                                    searchQuery
                                            .isNotEmpty
                                        ? IconButton(
                                            onPressed:
                                                () {
                                              _searchController
                                                  .clear();
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
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // FILTER BUTTON
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      OutlinedButton
                                          .icon(
                                    onPressed:
                                        _showFilterSheet,

                                    icon:
                                        const Icon(
                                      Icons
                                          .filter_list,
                                    ),

                                    label: Text(
                                      _hasFilters
                                          ? 'Filters applied'
                                          : 'Filter',
                                    ),
                                  ),
                                ),

                                if (_hasFilters) ...[
                                  const SizedBox(
                                    width: 8,
                                  ),

                                  IconButton(
                                    tooltip:
                                        'Clear filters',

                                    onPressed:
                                        _clearFilters,

                                    icon:
                                        const Icon(
                                      Icons
                                          .clear_all,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // FILTER CHIPS
                            if (_hasFilters) ...[
                              const SizedBox(
                                height: 8,
                              ),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_selectedCategory !=
                                      null)
                                    Chip(
                                      avatar:
                                          const Icon(
                                        Icons.category,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _selectedCategory!,
                                      ),
                                    ),

                                  if (_startDate != null ||
                                      _endDate != null)
                                    Chip(
                                      avatar:
                                          const Icon(
                                        Icons.date_range,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _dateFilterText(),
                                      ),
                                    ),
                                ],
                              ),
                            ],

                            const SizedBox(
                              height: 20,
                            ),

                            // CHART
                            if (allExpenses
                                .isNotEmpty) ...[
                              ExpenseChart(
                                expenses:
                                    allExpenses,
                              ),

                              const SizedBox(
                                height: 20,
                              ),
                            ],

                            // RESULT COUNT
                            Text(
                              searchQuery.isNotEmpty ||
                                      _hasFilters
                                  ? '${currentExpenses.length} expense(s) found'
                                  : '${allExpenses.length} expense(s)',

                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // EMPTY / LIST
                    // ------------------------------------------------

                    if (currentExpenses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,

                        child:
                            _buildEmptyState(
                          hasAnyExpenses:
                              allExpenses
                                  .isNotEmpty,
                        ),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          8,
                          16,
                          100,
                        ),

                        sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate(
                            (
                              context,
                              index,
                            ) {
                              final expense =
                                  currentExpenses[
                                      index];

                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom: 10,
                                ),

                                child:
                                    ExpenseCard(
                                  expense:
                                      expense,
                                ),
                              );
                            },

                            childCount:
                                currentExpenses
                                    .length,
                          ),
                        ),
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
        onPressed: _addExpense,

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'Add Expense',
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState({
    required bool hasAnyExpenses,
  }) {
    final hasSearch =
        _searchQuery.value.isNotEmpty;

    final hasFilter = _hasFilters;

    String title;
    String subtitle;
    IconData icon;

    if (hasSearch || hasFilter) {
      title = 'No matching expenses';

      subtitle =
          'Try changing your search or filters.';

      icon = Icons.search_off;
    } else if (!hasAnyExpenses) {
      title = 'No expenses yet';

      subtitle =
          'Start tracking your spending by adding your first expense.';

      icon = Icons.receipt_long;
    } else {
      title = 'No expenses';

      subtitle =
          'There are no expenses to display.';

      icon = Icons.receipt_long;
    }

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 72,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              subtitle,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            if (!hasSearch &&
                !hasFilter) ...[
              const SizedBox(
                height: 20,
              ),

              FilledButton.icon(
                onPressed:
                    _addExpense,

                icon: const Icon(
                  Icons.add,
                ),

                label: const Text(
                  'Add Expense',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}