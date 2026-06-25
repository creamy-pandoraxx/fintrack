import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/category.dart';
import 'category_dto.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(dio: ref.watch(dioProvider));
});

class CreateCategoryInput {
  const CreateCategoryInput({
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.apiValue,
      'icon': _nullableTrim(icon),
      'color': _nullableTrim(color),
    };
  }
}

class UpdateCategoryInput {
  const UpdateCategoryInput({required this.name, this.icon, this.color});

  final String name;
  final String? icon;
  final String? color;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'icon': _nullableTrim(icon),
      'color': _nullableTrim(color),
    };
  }
}

class CategoryRepository {
  const CategoryRepository({required this.dio});

  final Dio dio;

  Future<List<Category>> listCategories({CategoryType? type}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/categories',
        queryParameters: type == null ? null : {'type': type.apiValue},
      );
      final data = response.data?['data'];

      if (data is! List) {
        throw const ApiException('Invalid categories response from server.');
      }

      return data
          .map((item) => CategoryDto.fromJson(Map<String, dynamic>.from(item)))
          .map((dto) => dto.toDomain())
          .toList();
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Category> createCategory(CreateCategoryInput input) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/categories',
        data: input.toJson(),
      );
      return _categoryFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Category> updateCategory(String id, UpdateCategoryInput input) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '/categories/$id',
        data: input.toJson(),
      );
      return _categoryFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await dio.delete<Map<String, dynamic>>('/categories/$id');
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Category _categoryFromResponse(Map<String, dynamic>? responseBody) {
    final categoryJson = responseBody?['data'];

    if (categoryJson is! Map) {
      throw const ApiException('Invalid category response from server.');
    }

    return CategoryDto.fromJson(
      Map<String, dynamic>.from(categoryJson),
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
