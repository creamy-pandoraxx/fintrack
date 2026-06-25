import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/budget.dart';
import 'budget_dto.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(dio: ref.watch(dioProvider));
});

class BudgetPeriod {
  const BudgetPeriod({required this.month, required this.year});

  final int month;
  final int year;

  factory BudgetPeriod.current() {
    final now = DateTime.now();
    return BudgetPeriod(month: now.month, year: now.year);
  }

  BudgetPeriod next() {
    final date = DateTime(year, month + 1);
    return BudgetPeriod(month: date.month, year: date.year);
  }

  BudgetPeriod previous() {
    final date = DateTime(year, month - 1);
    return BudgetPeriod(month: date.month, year: date.year);
  }
}

class CreateBudgetInput {
  const CreateBudgetInput({
    required this.categoryId,
    required this.month,
    required this.year,
    required this.limitAmount,
  });

  final String categoryId;
  final int month;
  final int year;
  final double limitAmount;

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'limitAmount': limitAmount,
    };
  }
}

class UpdateBudgetInput {
  const UpdateBudgetInput({required this.limitAmount});

  final double limitAmount;

  Map<String, dynamic> toJson() {
    return {'limitAmount': limitAmount};
  }
}

class BudgetRepository {
  const BudgetRepository({required this.dio});

  final Dio dio;

  Future<List<Budget>> listBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/budgets',
        queryParameters: {'month': month, 'year': year},
      );
      final data = response.data?['data'];

      if (data is! List) {
        throw const ApiException('Invalid budgets response from server.');
      }

      return data
          .map((item) => BudgetDto.fromJson(Map<String, dynamic>.from(item)))
          .map((dto) => dto.toDomain())
          .toList();
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Budget> createBudget(CreateBudgetInput input) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/budgets',
        data: input.toJson(),
      );
      return _budgetFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Budget> updateBudget(String id, UpdateBudgetInput input) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '/budgets/$id',
        data: input.toJson(),
      );
      return _budgetFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await dio.delete<Map<String, dynamic>>('/budgets/$id');
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Budget _budgetFromResponse(Map<String, dynamic>? responseBody) {
    final budgetJson = responseBody?['data'];

    if (budgetJson is! Map) {
      throw const ApiException('Invalid budget response from server.');
    }

    return BudgetDto.fromJson(Map<String, dynamic>.from(budgetJson)).toDomain();
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
