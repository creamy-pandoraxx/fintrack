enum TransactionType {
  income('INCOME', 'Income'),
  expense('EXPENSE', 'Expense');

  const TransactionType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TransactionType fromApiValue(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class TransactionCategory {
  const TransactionCategory({
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

class TransactionWallet {
  const TransactionWallet({required this.id, required this.name});

  final String id;
  final String name;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    this.note,
    this.wallet,
    this.category,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String title;
  final String? note;
  final DateTime transactionDate;
  final TransactionWallet? wallet;
  final TransactionCategory? category;
}
