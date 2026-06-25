class MoneyFormatter {
  const MoneyFormatter._();

  static String formatNumber(num value) {
    return _groupDigits(value.abs().round().toString());
  }

  static String formatIdr(num value, {String currency = 'IDR'}) {
    final isNegative = value < 0;
    final amount = formatNumber(value);

    final sign = isNegative ? '-' : '';
    if (currency.toUpperCase() == 'IDR') {
      return '${sign}Rp$amount';
    }

    return '${currency.toUpperCase()} $sign$amount';
  }

  static double? parseGroupedNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }

    return double.tryParse(digits);
  }

  static String _groupDigits(String digits) {
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;
      buffer.write(digits[index]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
