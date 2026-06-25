import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/date_formatter.dart';
import '../domain/transaction.dart';
import 'transaction_dto.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(dio: ref.watch(dioProvider));
});

class TransactionListFilter {
  const TransactionListFilter({this.type, this.thisMonth = false, this.search});

  final TransactionType? type;
  final bool thisMonth;
  final String? search;

  Map<String, dynamic> toQueryParameters() {
    final query = <String, dynamic>{'page': 1, 'limit': 50};

    if (type != null) {
      query['type'] = type!.apiValue;
    }

    if (thisMonth) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month);
      final end = DateTime(now.year, now.month + 1, 0);
      query['startDate'] = DateFormatter.formatApiDate(start);
      query['endDate'] = DateFormatter.formatApiDate(end);
    }

    final trimmedSearch = search?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      query['search'] = trimmedSearch;
    }

    return query;
  }

  TransactionListFilter copyWith({
    TransactionType? type,
    bool clearType = false,
    bool? thisMonth,
    String? search,
  }) {
    return TransactionListFilter(
      type: clearType ? null : type ?? this.type,
      thisMonth: thisMonth ?? this.thisMonth,
      search: search ?? this.search,
    );
  }
}

class TransactionInput {
  const TransactionInput({
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.title,
    required this.transactionDate,
    this.note,
  });

  final String walletId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final String title;
  final String? note;
  final DateTime transactionDate;

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'categoryId': categoryId,
      'type': type.apiValue,
      'amount': amount,
      'title': title.trim(),
      'note': _nullableTrim(note),
      'transactionDate': DateFormatter.formatApiDate(transactionDate),
    };
  }
}

class TransactionRepository {
  const TransactionRepository({required this.dio});

  final Dio dio;

  Future<List<Transaction>> listTransactions({
    TransactionListFilter filter = const TransactionListFilter(),
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/transactions',
        queryParameters: filter.toQueryParameters(),
      );
      final items = response.data?['data']?['items'];

      if (items is! List) {
        throw const ApiException('Invalid transactions response from server.');
      }

      return items
          .map(
            (item) => TransactionDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .map((dto) => dto.toDomain())
          .toList();
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Transaction> getTransaction(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/transactions/$id');
      return _transactionFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Transaction> createTransaction(TransactionInput input) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/transactions',
        data: input.toJson(),
      );
      return _transactionFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<void> updateTransaction(String id, TransactionInput input) async {
    try {
      await dio.patch<Map<String, dynamic>>(
        '/transactions/$id',
        data: input.toJson(),
      );
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await dio.delete<Map<String, dynamic>>('/transactions/$id');
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Transaction _transactionFromResponse(Map<String, dynamic>? responseBody) {
    final transactionJson = responseBody?['data'];

    if (transactionJson is! Map) {
      throw const ApiException('Invalid transaction response from server.');
    }

    return TransactionDto.fromJson(
      Map<String, dynamic>.from(transactionJson),
    ).toDomain();
  }

  ApiException _apiMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(
        data['message'] as String,
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(
      'Could not reach the FinTrack API. Check that the backend is running.',
      statusCode: error.response?.statusCode,
    );
  }
}

String? _nullableTrim(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
