import '../domain/wallet.dart';

class WalletDto {
  const WalletDto({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    required this.currency,
    required this.isArchived,
  });

  final String id;
  final String name;
  final String type;
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final bool isArchived;

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      initialBalance: _parseMoney(json['initialBalance']),
      currentBalance: _parseMoney(json['currentBalance']),
      currency: (json['currency'] as String?) ?? 'IDR',
      isArchived: (json['isArchived'] as bool?) ?? false,
    );
  }

  Wallet toDomain() {
    return Wallet(
      id: id,
      name: name,
      type: WalletType.fromApiValue(type),
      initialBalance: initialBalance,
      currentBalance: currentBalance,
      currency: currency,
      isArchived: isArchived,
    );
  }

  static double _parseMoney(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
