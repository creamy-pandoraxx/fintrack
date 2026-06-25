import 'package:flutter/material.dart';

import '../../../app/constants/app_spacing.dart';
import '../domain/category.dart';
import 'category_validators.dart';

class CategoryFormFields extends StatelessWidget {
  const CategoryFormFields({
    super.key,
    required this.nameController,
    required this.iconController,
    required this.colorController,
    required this.selectedType,
    required this.onTypeChanged,
    this.typeEnabled = true,
  });

  final TextEditingController nameController;
  final TextEditingController iconController;
  final TextEditingController colorController;
  final CategoryType selectedType;
  final ValueChanged<CategoryType> onTypeChanged;
  final bool typeEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Category name'),
          validator: CategoryValidators.requiredName,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<CategoryType>(
          initialValue: selectedType,
          decoration: const InputDecoration(labelText: 'Category type'),
          items: CategoryType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: typeEnabled
              ? (value) {
                  if (value != null) {
                    onTypeChanged(value);
                  }
                }
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: iconController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Icon name',
            hintText: 'food, salary, transport',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: colorController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Color',
            hintText: '#22C55E',
          ),
          validator: CategoryValidators.optionalColor,
        ),
      ],
    );
  }
}
