enum WalletType {
  cash('cash', 'Cash'),
  bank('bank', 'Bank'),
  eWallet('e-wallet', 'E-wallet'),
  savings('savings', 'Savings'),
  other('other', 'Other');

  const WalletType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static WalletType fromApiValue(String value) {
    return WalletType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => WalletType.other,
    );
  }
}

class Wallet {
  const Wallet({
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
  final WalletType type;
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final bool isArchived;
}
