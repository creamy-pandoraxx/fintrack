import 'package:flutter/material.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/grouped_number_input_formatter.dart';
import '../../categories/domain/category.dart';
import 'budget_validators.dart';

const monthLabels = [
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

String formatBudgetPeriod(int month, int year) {
  return '${monthLabels[month - 1]} $year';
}

class BudgetFormFields extends StatelessWidget {
  const BudgetFormFields({
    super.key,
    required this.limitAmountController,
    required this.yearController,
    required this.selectedCategoryId,
    required this.selectedMonth,
    required this.expenseCategories,
    required this.onCategoryChanged,
    required this.onMonthChanged,
    this.categoryEnabled = true,
    this.periodEnabled = true,
  });

  final TextEditingController limitAmountController;
  final TextEditingController yearController;
  final String? selectedCategoryId;
  final int? selectedMonth;
  final List<Category> expenseCategories;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<int?> onMonthChanged;
  final bool categoryEnabled;
  final bool periodEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveCategoryId =
        expenseCategories.any((category) => category.id == selectedCategoryId)
        ? selectedCategoryId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: effectiveCategoryId,
          decoration: const InputDecoration(labelText: 'Expense category'),
          items: expenseCategories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: categoryEnabled ? onCategoryChanged : null,
          validator: BudgetValidators.requiredCategory,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue:
                    selectedMonth != null &&
                        selectedMonth! >= 1 &&
                        selectedMonth! <= 12
                    ? selectedMonth
                    : null,
                decoration: const InputDecoration(labelText: 'Month'),
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(monthLabels[index]),
                  ),
                ),
                onChanged: periodEnabled ? onMonthChanged : null,
                validator: BudgetValidators.requiredMonth,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: yearController,
                enabled: periodEnabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: BudgetValidators.requiredYear,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: limitAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [GroupedNumberInputFormatter()],
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Limit amount'),
          validator: BudgetValidators.requiredLimitAmount,
        ),
      ],
    );
  }
}
