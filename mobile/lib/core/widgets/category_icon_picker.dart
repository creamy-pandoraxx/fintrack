import 'package:flutter/material.dart';

import '../../app/constants/app_spacing.dart';
import '../utils/category_icon_mapper.dart';
import 'category_icon_circle.dart';

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selectedIconKey,
    required this.selectedColorHex,
    required this.onSelected,
  });

  final String selectedIconKey;
  final String selectedColorHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalizedSelection = CategoryIconMapper.normalizeKey(
      selectedIconKey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CategoryIconCircle(
              iconKey: normalizedSelection,
              colorHex: selectedColorHex,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category icon',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CategoryIconMapper.labelFor(normalizedSelection),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
          ),
          itemCount: CategoryIconMapper.options.length,
          itemBuilder: (context, index) {
            final option = CategoryIconMapper.options[index];
            final selected = option.key == normalizedSelection;

            return Tooltip(
              message: option.label,
              child: Semantics(
                button: true,
                selected: selected,
                label: '${option.label} category icon',
                child: Material(
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelected(option.key),
                    child: Icon(
                      option.icon,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
