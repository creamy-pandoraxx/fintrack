import 'package:flutter/material.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

class CategoryIconMapper {
  const CategoryIconMapper._();

  static const defaultKey = 'other';

  static const options = <CategoryIconOption>[
    CategoryIconOption(key: 'food', label: 'Food', icon: Icons.restaurant),
    CategoryIconOption(
      key: 'transport',
      label: 'Transport',
      icon: Icons.directions_car,
    ),
    CategoryIconOption(
      key: 'shopping',
      label: 'Shopping',
      icon: Icons.shopping_bag_outlined,
    ),
    CategoryIconOption(
      key: 'bills',
      label: 'Bills',
      icon: Icons.receipt_long_outlined,
    ),
    CategoryIconOption(
      key: 'health',
      label: 'Health',
      icon: Icons.favorite_border,
    ),
    CategoryIconOption(
      key: 'education',
      label: 'Education',
      icon: Icons.school_outlined,
    ),
    CategoryIconOption(
      key: 'entertainment',
      label: 'Entertainment',
      icon: Icons.movie_outlined,
    ),
    CategoryIconOption(
      key: 'salary',
      label: 'Salary',
      icon: Icons.payments_outlined,
    ),
    CategoryIconOption(
      key: 'freelance',
      label: 'Freelance',
      icon: Icons.work_outline,
    ),
    CategoryIconOption(
      key: 'gift',
      label: 'Gift',
      icon: Icons.card_giftcard_outlined,
    ),
    CategoryIconOption(
      key: 'investment',
      label: 'Investment',
      icon: Icons.trending_up,
    ),
    CategoryIconOption(
      key: 'coffee',
      label: 'Coffee',
      icon: Icons.local_cafe_outlined,
    ),
    CategoryIconOption(key: 'home', label: 'Home', icon: Icons.home_outlined),
    CategoryIconOption(
      key: 'travel',
      label: 'Travel',
      icon: Icons.flight_outlined,
    ),
    CategoryIconOption(
      key: defaultKey,
      label: 'Other',
      icon: Icons.category_outlined,
    ),
  ];

  static const _aliases = <String, String>{
    'utensils': 'food',
    'restaurant': 'food',
    'car': 'transport',
    'shopping-bag': 'shopping',
    'receipt': 'bills',
    'heart-pulse': 'health',
    'graduation-cap': 'education',
    'film': 'entertainment',
    'briefcase': 'freelance',
    'trending-up': 'investment',
    'more-horizontal': defaultKey,
  };

  static String normalizeKey(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll('_', '-');
    if (normalized == null || normalized.isEmpty) {
      return defaultKey;
    }

    final canonical = _aliases[normalized] ?? normalized;
    return options.any((option) => option.key == canonical)
        ? canonical
        : defaultKey;
  }

  static IconData fromKey(String? value) {
    final key = normalizeKey(value);
    return options.firstWhere((option) => option.key == key).icon;
  }

  static String labelFor(String? value) {
    final key = normalizeKey(value);
    return options.firstWhere((option) => option.key == key).label;
  }
}
