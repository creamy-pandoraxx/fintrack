import 'package:flutter/material.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/grouped_number_input_formatter.dart';
import '../../categories/domain/category.dart' as category_domain;
import '../../wallets/domain/wallet.dart';
import '../domain/transaction.dart';
import 'transaction_validators.dart';

class TransactionFormFields extends StatelessWidget {
  const TransactionFormFields({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.noteController,
    required this.selectedType,
    required this.selectedWalletId,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.wallets,
    required this.incomeCategories,
    required this.expenseCategories,
    required this.onTypeChanged,
    required this.onWalletChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final TransactionType selectedType;
  final String? selectedWalletId;
  final String? selectedCategoryId;
  final DateTime? selectedDate;
  final List<Wallet> wallets;
  final List<category_domain.Category> incomeCategories;
  final List<category_domain.Category> expenseCategories;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<String?> onWalletChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final filteredCategories = selectedType == TransactionType.income
        ? incomeCategories
        : expenseCategories;
    final effectiveWalletId =
        wallets.any((wallet) => wallet.id == selectedWalletId)
        ? selectedWalletId
        : null;
    final effectiveCategoryId =
        filteredCategories.any((category) => category.id == selectedCategoryId)
        ? selectedCategoryId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TransactionType>(
          segments: const [
            ButtonSegment(
              value: TransactionType.expense,
              label: Text('Expense'),
              icon: Icon(Icons.trending_down),
            ),
            ButtonSegment(
              value: TransactionType.income,
              label: Text('Income'),
              icon: Icon(Icons.trending_up),
            ),
          ],
          selected: {selectedType},
          onSelectionChanged: (selection) => onTypeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: TransactionValidators.requiredTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [GroupedNumberInputFormatter()],
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Amount'),
          validator: TransactionValidators.requiredAmount,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: effectiveWalletId,
          decoration: const InputDecoration(labelText: 'Wallet'),
          items: wallets
              .map(
                (wallet) => DropdownMenuItem(
                  value: wallet.id,
                  child: Text(wallet.name),
                ),
              )
              .toList(),
          onChanged: onWalletChanged,
          validator: (value) =>
              TransactionValidators.requiredSelection(value, 'Wallet'),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: effectiveCategoryId,
          decoration: const InputDecoration(labelText: 'Category'),
          items: filteredCategories
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
          validator: (value) =>
              TransactionValidators.requiredSelection(value, 'Category'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year - 10),
              lastDate: DateTime(now.year + 5),
            );

            if (pickedDate != null) {
              onDateChanged(pickedDate);
            }
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(
            selectedDate == null
                ? 'Choose transaction date'
                : DateFormatter.formatDisplay(selectedDate!),
          ),
        ),
        if (selectedDate == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Date is required.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: noteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
      ],
    );
  }
}
