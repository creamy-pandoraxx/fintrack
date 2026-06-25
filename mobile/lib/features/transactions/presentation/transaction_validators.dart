import '../../../core/utils/money_formatter.dart';

class TransactionValidators {
  const TransactionValidators._();

  static String? requiredTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required.';
    }

    return null;
  }

  static String? requiredAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }

    final amount = MoneyFormatter.parseGroupedNumber(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0.';
    }

    return null;
  }

  static String? requiredSelection(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }

    return null;
  }
}
