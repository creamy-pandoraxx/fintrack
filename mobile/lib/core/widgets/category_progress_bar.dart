import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../utils/app_color_utils.dart';

class CategoryProgressBar extends StatelessWidget {
  const CategoryProgressBar({
    super.key,
    required this.percentage,
    this.colorHex,
    this.height = 10,
  });

  final double percentage;
  final String? colorHex;
  final double height;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColorUtils.fromHex(colorHex);
    final isExceeded = percentage >= 100;
    final progressColor = isExceeded ? AppColors.danger : categoryColor;
    final value = (percentage / 100).clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        minHeight: height,
        value: value,
        color: progressColor,
        backgroundColor: AppColorUtils.softTint(progressColor, opacity: 0.1),
      ),
    );
  }
}
