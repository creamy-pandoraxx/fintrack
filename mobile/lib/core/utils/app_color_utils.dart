import 'package:flutter/material.dart';

class AppColorOption {
  const AppColorOption({required this.label, required this.hex});

  final String label;
  final String hex;
}

class AppColorUtils {
  const AppColorUtils._();

  static const fallbackHex = '#64748B';
  static const fallbackColor = Color(0xFF64748B);

  static const categoryPalette = <AppColorOption>[
    AppColorOption(label: 'Blue', hex: '#3B82F6'),
    AppColorOption(label: 'Indigo', hex: '#6366F1'),
    AppColorOption(label: 'Violet', hex: '#8B5CF6'),
    AppColorOption(label: 'Purple', hex: '#A855F7'),
    AppColorOption(label: 'Pink', hex: '#EC4899'),
    AppColorOption(label: 'Red', hex: '#EF4444'),
    AppColorOption(label: 'Orange', hex: '#F97316'),
    AppColorOption(label: 'Amber', hex: '#EAB308'),
    AppColorOption(label: 'Green', hex: '#22C55E'),
    AppColorOption(label: 'Teal', hex: '#14B8A6'),
    AppColorOption(label: 'Cyan', hex: '#06B6D4'),
    AppColorOption(label: 'Slate', hex: fallbackHex),
  ];

  static const chartFallbacks = <Color>[
    Color(0xFF2563EB),
    Color(0xFF0D9488),
    Color(0xFFD97706),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
  ];

  static Color fromHex(String? value, {Color fallback = fallbackColor}) {
    final normalized = normalizeHex(value);
    if (normalized == null) {
      return fallback;
    }

    return Color(int.parse('FF${normalized.substring(1)}', radix: 16));
  }

  static String? normalizeHex(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || !RegExp(r'^#[0-9A-F]{6}$').hasMatch(normalized)) {
      return null;
    }

    return normalized;
  }

  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color softTint(Color color, {double opacity = 0.12}) {
    final alpha = (255 * opacity.clamp(0.0, 1.0)).round();
    return Color.alphaBlend(color.withAlpha(alpha), Colors.white);
  }
}
