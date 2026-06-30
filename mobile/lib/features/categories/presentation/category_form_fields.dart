import 'package:flutter/material.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/widgets/category_icon_picker.dart';
import '../../../core/widgets/color_palette_picker.dart';
import '../domain/category.dart';
import 'category_validators.dart';

class CategoryFormFields extends StatelessWidget {
  const CategoryFormFields({
    super.key,
    required this.nameController,
    required this.selectedType,
    required this.selectedIconKey,
    required this.selectedColorHex,
    required this.onTypeChanged,
    required this.onIconChanged,
    required this.onColorChanged,
    this.typeEnabled = true,
  });

  final TextEditingController nameController;
  final CategoryType selectedType;
  final String selectedIconKey;
  final String selectedColorHex;
  final ValueChanged<CategoryType> onTypeChanged;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<String> onColorChanged;
  final bool typeEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Details', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
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
        const SizedBox(height: AppSpacing.lg),
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Use one visual identity everywhere this category appears.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        CategoryIconPicker(
          selectedIconKey: selectedIconKey,
          selectedColorHex: selectedColorHex,
          onSelected: onIconChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        ColorPalettePicker(
          selectedColorHex: selectedColorHex,
          onSelected: onColorChanged,
        ),
      ],
    );
  }
}
