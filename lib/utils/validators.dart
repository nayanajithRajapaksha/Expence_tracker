class Validators {
  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }

    if (value.trim().length < 2) {
      return 'Title must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Title must be less than 50 characters';
    }

    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value.trim());

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }
}