class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String? icon;
  final String? color;
}

class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.month,
    required this.year,
    required this.limitAmount,
    required this.usedAmount,
    required this.remainingAmount,
    required this.usagePercentage,
  });

  final String id;
  final BudgetCategory category;
  final int month;
  final int year;
  final double limitAmount;
  final double usedAmount;
  final double remainingAmount;
  final double usagePercentage;
}
