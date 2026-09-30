import '../models/expense.dart';

class ExpenseFilter {
  ExpenseFilter._();

  static List<Expense> filter({
    required List<Expense> expenses,
    String searchQuery = '',
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = searchQuery.trim().toLowerCase();

    return expenses.where((expense) {
      // Search by title
      final matchesSearch =
          query.isEmpty ||
          expense.title.toLowerCase().contains(query);

      // Category filter
      final matchesCategory =
          selectedCategory == null ||
          expense.category == selectedCategory;

      // Start date filter
      bool matchesStartDate = true;

      if (startDate != null) {
        final start = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );

        matchesStartDate = !expense.date.isBefore(start);
      }

      // End date filter
      bool matchesEndDate = true;

      if (endDate != null) {
        final end = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );

        matchesEndDate = !expense.date.isAfter(end);
      }

      return matchesSearch &&
          matchesCategory &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();
  }
}