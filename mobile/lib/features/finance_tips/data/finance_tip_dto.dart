import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/finance_tip.dart';

class FinanceTipDto {
  const FinanceTipDto({
    required this.id,
    required this.title,
    required this.content,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isActive;
  final DateTime? createdAt;

  factory FinanceTipDto.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return FinanceTipDto(
      id: document.id,
      title: _asString(data['title']) ?? 'Finance tip',
      content: _asString(data['content']) ?? '',
      isActive: data['isActive'] == true,
      createdAt: _asDateTime(data['createdAt']),
    );
  }

  FinanceTip toDomain() {
    return FinanceTip(
      id: id,
      title: title,
      content: content,
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
