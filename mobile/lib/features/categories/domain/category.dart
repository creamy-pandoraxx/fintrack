enum CategoryType {
  income('INCOME', 'Income'),
  expense('EXPENSE', 'Expense');

  const CategoryType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CategoryType fromApiValue(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => CategoryType.expense,
    );
  }
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final bool isDefault;
}
