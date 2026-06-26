import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity_feed_item.dart';

class ActivityFeedDto {
  const ActivityFeedDto({
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

  factory ActivityFeedDto.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return ActivityFeedDto(
      id: document.id,
      type: _asString(data['type']) ?? 'activity',
      title: _asString(data['title']) ?? 'Activity',
      message: _asString(data['message']) ?? '',
      amount: _asDouble(data['amount']),
      transactionType: _asString(data['transactionType']),
      categoryName: _asString(data['categoryName']),
      walletName: _asString(data['walletName']),
      createdAt: _asDateTime(data['createdAt']),
    );
  }

  ActivityFeedItem toDomain() {
    return ActivityFeedItem(
      id: id,
      type: type,
      title: title,
      message: message,
      amount: amount,
      transactionType: transactionType,
      categoryName: categoryName,
      walletName: walletName,
      createdAt: createdAt,
    );
  }
}

String? _asString(Object? value) {
  if (value is String) {
    return value;
  }

  return null;
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

DateTime? _asDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}
