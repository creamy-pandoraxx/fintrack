import '../../transactions/domain/transaction.dart';
import '../domain/dashboard_summary.dart';

class DashboardSummaryDto {
  const DashboardSummaryDto({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netCashFlow,
    required this.expenseByCategory,
    required this.budgetSummary,
    required this.recentTransactions,
  });

  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double netCashFlow;
  final List<ExpenseByCategoryDto> expenseByCategory;
  final List<DashboardBudgetSummaryDto> budgetSummary;
  final List<DashboardRecentTransactionDto> recentTransactions;

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDto(
      totalBalance: _asDouble(json['totalBalance']),
      monthlyIncome: _asDouble(json['monthlyIncome']),
      monthlyExpense: _asDouble(json['monthlyExpense']),
      netCashFlow: _asDouble(json['netCashFlow']),
      expenseByCategory: _asList(
        json['expenseByCategory'],
        ExpenseByCategoryDto.fromJson,
      ),
      budgetSummary: _asList(
        json['budgetSummary'],
        DashboardBudgetSummaryDto.fromJson,
      ),
      recentTransactions: _asList(
        json['recentTransactions'],
        DashboardRecentTransactionDto.fromJson,
      ),
    );
  }

  DashboardSummary toDomain() {
    return DashboardSummary(
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      netCashFlow: netCashFlow,
      expenseByCategory: expenseByCategory
          .map((dto) => dto.toDomain())
          .toList(),
      budgetSummary: budgetSummary.map((dto) => dto.toDomain()).toList(),
      recentTransactions: recentTransactions
          .map((dto) => dto.toDomain())
          .toList(),
    );
  }
}

class ExpenseByCategoryDto {
  const ExpenseByCategoryDto({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  factory ExpenseByCategoryDto.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategoryDto(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: _asDouble(json['amount']),
      percentage: _asDouble(json['percentage']),
    );
  }

  ExpenseByCategory toDomain() {
    return ExpenseByCategory(
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
    );
  }
}

class DashboardBudgetSummaryDto {
  const DashboardBudgetSummaryDto({
    required this.budgetId,
    required this.categoryName,
    required this.limitAmount,
    required this.usedAmount,
    required this.remainingAmount,
    required this.usagePercentage,
  });

  final String budgetId;
  final String categoryName;
  final double limitAmount;
  final double usedAmount;
  final double remainingAmount;
  final double usagePercentage;

  factory DashboardBudgetSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardBudgetSummaryDto(
      budgetId: json['budgetId'] as String,
      categoryName: json['categoryName'] as String,
      limitAmount: _asDouble(json['limitAmount']),
      usedAmount: _asDouble(json['usedAmount']),
      remainingAmount: _asDouble(json['remainingAmount']),
      usagePercentage: _asDouble(json['usagePercentage']),
    );
  }

  DashboardBudgetSummary toDomain() {
    return DashboardBudgetSummary(
      budgetId: budgetId,
      categoryName: categoryName,
      limitAmount: limitAmount,
      usedAmount: usedAmount,
      remainingAmount: remainingAmount,
      usagePercentage: usagePercentage,
    );
  }
}

class DashboardRecentTransactionDto {
  const DashboardRecentTransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    this.wallet,
    this.category,
  });

  final String id;
  final String type;
  final double amount;
  final String title;
  final DateTime transactionDate;
  final DashboardTransactionWallet? wallet;
  final DashboardTransactionCategory? category;

  factory DashboardRecentTransactionDto.fromJson(Map<String, dynamic> json) {
    return DashboardRecentTransactionDto(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: _asDouble(json['amount']),
      title: json['title'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      wallet: _parseWallet(json['wallet']),
      category: _parseCategory(json['category']),
    );
  }

  DashboardRecentTransaction toDomain() {
    return DashboardRecentTransaction(
      id: id,
      type: TransactionType.fromApiValue(type),
      amount: amount,
      title: title,
      transactionDate: transactionDate,
      wallet: wallet,
      category: category,
    );
  }

  static DashboardTransactionWallet? _parseWallet(Object? value) {
    if (value is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    final name = json['name'];
    if (name is! String) {
      return null;
    }

    return DashboardTransactionWallet(id: json['id'] as String?, name: name);
  }

  static DashboardTransactionCategory? _parseCategory(Object? value) {
    if (value is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    final name = json['name'];
    if (name is! String) {
      return null;
    }

    return DashboardTransactionCategory(
      id: json['id'] as String?,
      name: name,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}

List<T> _asList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) mapper,
) {
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList();
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}
