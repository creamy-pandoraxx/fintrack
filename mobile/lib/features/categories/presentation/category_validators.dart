class CategoryValidators {
  const CategoryValidators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name is required.';
    }

    return null;
  }

  static String? optionalColor(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final colorPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');
    if (!colorPattern.hasMatch(trimmed)) {
      return 'Use a hex color like #22C55E.';
    }

    return null;
  }
}
