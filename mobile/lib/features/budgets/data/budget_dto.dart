import '../domain/budget.dart';

class BudgetDto {
  const BudgetDto({
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
  final BudgetCategoryDto category;
  final int month;
  final int year;
  final double limitAmount;
  final double usedAmount;
  final double remainingAmount;
  final double usagePercentage;

  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    return BudgetDto(
      id: json['id'] as String,
      category: BudgetCategoryDto.fromJson(
        Map<String, dynamic>.from(json['category'] as Map),
      ),
      month: _asInt(json['month']),
      year: _asInt(json['year']),
      limitAmount: _asDouble(json['limitAmount']),
      usedAmount: _asDouble(json['usedAmount']),
      remainingAmount: _asDouble(json['remainingAmount']),
      usagePercentage: _asDouble(json['usagePercentage']),
    );
  }

  Budget toDomain() {
    return Budget(
      id: id,
      category: category.toDomain(),
      month: month,
      year: year,
      limitAmount: limitAmount,
      usedAmount: usedAmount,
      remainingAmount: remainingAmount,
      usagePercentage: usagePercentage,
    );
  }
}

class BudgetCategoryDto {
  const BudgetCategoryDto({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String? icon;
  final String? color;

  factory BudgetCategoryDto.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  BudgetCategory toDomain() {
    return BudgetCategory(id: id, name: name, icon: icon, color: color);
  }
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.parse(value.toString());
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.parse(value.toString());
}
