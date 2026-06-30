import 'package:fintrack_mobile/core/utils/app_color_utils.dart';
import 'package:fintrack_mobile/core/utils/category_icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryIconMapper', () {
    test('maps existing backend icon aliases to picker keys', () {
      expect(CategoryIconMapper.normalizeKey('utensils'), 'food');
      expect(CategoryIconMapper.normalizeKey('briefcase'), 'freelance');
      expect(CategoryIconMapper.normalizeKey('trending-up'), 'investment');
    });

    test('falls back safely for missing or unknown icon keys', () {
      expect(CategoryIconMapper.normalizeKey(null), 'other');
      expect(CategoryIconMapper.normalizeKey('unknown-icon'), 'other');
      expect(
        CategoryIconMapper.fromKey('unknown-icon'),
        Icons.category_outlined,
      );
    });
  });

  group('AppColorUtils', () {
    test('normalizes and converts valid category colors', () {
      expect(AppColorUtils.normalizeHex(' #3b82f6 '), '#3B82F6');
      expect(AppColorUtils.fromHex('#3B82F6'), const Color(0xFF3B82F6));
      expect(AppColorUtils.toHex(const Color(0xFF22C55E)), '#22C55E');
    });

    test('uses the fallback color for invalid values', () {
      expect(AppColorUtils.normalizeHex('blue'), isNull);
      expect(AppColorUtils.fromHex('not-a-color'), AppColorUtils.fallbackColor);
    });
  });
}
