import '../../../core/utils/money_formatter.dart';

class BudgetValidators {
  const BudgetValidators._();

  static String? requiredCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required.';
    }

    return null;
  }

  static String? requiredMonth(int? value) {
    if (value == null || value < 1 || value > 12) {
      return 'Choose a valid month.';
    }

    return null;
  }

  static String? requiredYear(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    if (year == null || year < 2000 || year > 2100) {
      return 'Enter a year from 2000 to 2100.';
    }

    return null;
  }

  static String? requiredLimitAmount(String? value) {
    final amount = MoneyFormatter.parseGroupedNumber(value ?? '');
    if (amount == null || amount <= 0) {
      return 'Limit amount must be greater than zero.';
    }

    return null;
  }
}
