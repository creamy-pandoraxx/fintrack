import '../../../core/utils/money_formatter.dart';

class WalletValidators {
  const WalletValidators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wallet name is required.';
    }

    return null;
  }

  static String? requiredCurrency(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Currency is required.';
    }

    if (value.trim().length != 3) {
      return 'Currency must use 3 letters.';
    }

    return null;
  }

  static String? requiredInitialBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Initial balance is required.';
    }

    final amount = MoneyFormatter.parseGroupedNumber(value);
    if (amount == null) {
      return 'Initial balance must be numeric.';
    }

    if (amount < 0) {
      return 'Initial balance cannot be negative.';
    }

    return null;
  }
}
