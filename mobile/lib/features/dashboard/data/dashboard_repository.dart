import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_summary_dto.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(dio: ref.watch(dioProvider));
});

class DashboardRepository {
  const DashboardRepository({required this.dio});

  final Dio dio;

  Future<DashboardSummary> getSummary(DashboardPeriod period) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/dashboard/summary',
        queryParameters: {'month': period.month, 'year': period.year},
      );

      final data = response.data?['data'];
      if (data is! Map) {
        throw const ApiException('Invalid dashboard response from server.');
      }

      return DashboardSummaryDto.fromJson(
        Map<String, dynamic>.from(data),
      ).toDomain();
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
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
