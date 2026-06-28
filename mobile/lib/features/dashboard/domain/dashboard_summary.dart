import '../../transactions/domain/transaction.dart';

class DashboardPeriod {
  const DashboardPeriod({required this.month, required this.year});

  final int month;
  final int year;

  factory DashboardPeriod.current() {
    final now = DateTime.now();
    return DashboardPeriod(month: now.month, year: now.year);
  }

  DashboardPeriod next() {
    final date = DateTime(year, month + 1);
    return DashboardPeriod(month: date.month, year: date.year);
  }

  DashboardPeriod previous() {
    final date = DateTime(year, month - 1);
    return DashboardPeriod(month: date.month, year: date.year);
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netCashFlow,
    required this.monthlyTransactionCount,
    required this.expenseByCategory,
    required this.budgetSummary,
    required this.recentTransactions,
  });

  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double netCashFlow;
  final int monthlyTransactionCount;
  final List<ExpenseByCategory> expenseByCategory;
  final List<DashboardBudgetSummary> budgetSummary;
  final List<DashboardRecentTransaction> recentTransactions;
}

class ExpenseByCategory {
  const ExpenseByCategory({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
}

class DashboardBudgetSummary {
  const DashboardBudgetSummary({
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
}

class DashboardRecentTransaction {
  const DashboardRecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    this.wallet,
    this.category,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String title;
  final DateTime transactionDate;
  final DashboardTransactionWallet? wallet;
  final DashboardTransactionCategory? category;
}

class DashboardTransactionWallet {
  const DashboardTransactionWallet({this.id, required this.name});

  final String? id;
  final String name;
}

class DashboardTransactionCategory {
  const DashboardTransactionCategory({
    this.id,
    required this.name,
    this.icon,
    this.color,
  });

  final String? id;
  final String name;
  final String? icon;
  final String? color;
}
