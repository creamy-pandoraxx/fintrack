import 'package:flutter/material.dart';

import '../../app/constants/app_spacing.dart';
import '../utils/app_color_utils.dart';

class ColorPalettePicker extends StatelessWidget {
  const ColorPalettePicker({
    super.key,
    required this.selectedColorHex,
    required this.onSelected,
  });

  final String selectedColorHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalizedSelection =
        AppColorUtils.normalizeHex(selectedColorHex) ??
        AppColorUtils.fallbackHex;
    final palette =
        AppColorUtils.categoryPalette.any(
          (option) => option.hex == normalizedSelection,
        )
        ? AppColorUtils.categoryPalette
        : [
            AppColorOption(label: 'Current', hex: normalizedSelection),
            ...AppColorUtils.categoryPalette,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Category color', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose a color used consistently across reports and budgets.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: palette.map((option) {
            final color = AppColorUtils.fromHex(option.hex);
            final selected = option.hex == normalizedSelection;

            return Tooltip(
              message: option.label,
              child: Semantics(
                button: true,
                selected: selected,
                label: '${option.label} category color',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onSelected(option.hex),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
