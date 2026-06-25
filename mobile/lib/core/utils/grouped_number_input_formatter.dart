import 'package:flutter/services.dart';

import 'money_formatter.dart';

class GroupedNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final amount = MoneyFormatter.parseGroupedNumber(newValue.text);

    if (amount == null) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = MoneyFormatter.formatNumber(amount);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
