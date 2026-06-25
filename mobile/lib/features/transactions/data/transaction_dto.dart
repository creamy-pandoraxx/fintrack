import '../domain/transaction.dart';

class TransactionDto {
  const TransactionDto({
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
  final String type;
  final double amount;
  final String title;
  final String? note;
  final DateTime transactionDate;
  final TransactionWallet? wallet;
  final TransactionCategory? category;

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: _parseAmount(json['amount']),
      title: json['title'] as String,
      note: json['note'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      wallet: _parseWallet(json['wallet']),
      category: _parseCategory(json['category']),
    );
  }

  Transaction toDomain() {
    return Transaction(
      id: id,
      type: TransactionType.fromApiValue(type),
      amount: amount,
      title: title,
      note: note,
      transactionDate: transactionDate,
      wallet: wallet,
      category: category,
    );
  }

  static double _parseAmount(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static TransactionWallet? _parseWallet(Object? value) {
    if (value is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    return TransactionWallet(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  static TransactionCategory? _parseCategory(Object? value) {
    if (value is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}
