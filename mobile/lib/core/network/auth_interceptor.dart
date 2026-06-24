import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  const AuthInterceptor({required this.tokenProvider});

  final TokenProvider tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
