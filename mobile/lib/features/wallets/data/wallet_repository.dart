import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/wallet.dart';
import 'wallet_dto.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(dio: ref.watch(dioProvider));
});

class CreateWalletInput {
  const CreateWalletInput({
    required this.name,
    required this.type,
    required this.initialBalance,
    this.currency = 'IDR',
  });

  final String name;
  final WalletType type;
  final double initialBalance;
  final String currency;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.apiValue,
      'initialBalance': initialBalance,
      'currency': currency.trim().toUpperCase(),
    };
  }
}

class UpdateWalletInput {
  const UpdateWalletInput({
    required this.name,
    required this.type,
    required this.initialBalance,
    this.currency = 'IDR',
  });

  final String name;
  final WalletType type;
  final double initialBalance;
  final String currency;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.apiValue,
      'initialBalance': initialBalance,
      'currency': currency.trim().toUpperCase(),
    };
  }
}

class WalletRepository {
  const WalletRepository({required this.dio});

  final Dio dio;

  Future<List<Wallet>> listWallets() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/wallets');
      final data = response.data?['data'];

      if (data is! List) {
        throw const ApiException('Invalid wallets response from server.');
      }

      return data
          .map((item) => WalletDto.fromJson(Map<String, dynamic>.from(item)))
          .map((dto) => dto.toDomain())
          .toList();
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Wallet> getWallet(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/wallets/$id');
      return _walletFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Wallet> createWallet(CreateWalletInput input) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/wallets',
        data: input.toJson(),
      );
      return _walletFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<Wallet> updateWallet(String id, UpdateWalletInput input) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '/wallets/$id',
        data: input.toJson(),
      );
      return _walletFromResponse(response.data);
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Future<void> deleteWallet(String id) async {
    try {
      await dio.delete<Map<String, dynamic>>('/wallets/$id');
    } on DioException catch (error) {
      throw _apiMessage(error);
    }
  }

  Wallet _walletFromResponse(Map<String, dynamic>? responseBody) {
    final walletJson = responseBody?['data'];

    if (walletJson is! Map) {
      throw const ApiException('Invalid wallet response from server.');
    }

    return WalletDto.fromJson(Map<String, dynamic>.from(walletJson)).toDomain();
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
