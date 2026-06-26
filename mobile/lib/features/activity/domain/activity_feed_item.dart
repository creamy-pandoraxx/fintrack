class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.amount,
    this.transactionType,
    this.categoryName,
    this.walletName,
    this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final double? amount;
  final String? transactionType;
  final String? categoryName;
  final String? walletName;
  final DateTime? createdAt;
}
