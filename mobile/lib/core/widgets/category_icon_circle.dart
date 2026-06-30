import 'package:flutter/material.dart';

import '../utils/app_color_utils.dart';
import '../utils/category_icon_mapper.dart';

class CategoryIconCircle extends StatelessWidget {
  const CategoryIconCircle({
    super.key,
    this.iconKey,
    this.colorHex,
    this.size = 44,
  });

  final String? iconKey;
  final String? colorHex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColorUtils.fromHex(colorHex);
    final iconSize = size * 0.46;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColorUtils.softTint(color),
        border: Border.all(color: color.withAlpha(46)),
      ),
      alignment: Alignment.center,
      child: Icon(
        CategoryIconMapper.fromKey(iconKey),
        size: iconSize,
        color: color,
      ),
    );
  }
}
