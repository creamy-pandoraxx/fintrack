import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/app_user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

class AuthRepository {
  const AuthRepository({required this.dio, required this.firebaseAuth});

  final Dio dio;
  final FirebaseAuth firebaseAuth;

  Future<AppUser?> restoreSession() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return null;
      }

      await currentUser.getIdToken();
      return syncUser();
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseMessage(error), statusCode: null);
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return syncUser();
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseMessage(error), statusCode: null);
    }
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      return syncUser(name: name.trim());
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseMessage(error), statusCode: null);
    }
  }

  Future<void> logout() {
    return firebaseAuth.signOut();
  }

  Future<AppUser> syncUser({String? name}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/sync',
        data: name == null || name.trim().isEmpty
            ? <String, dynamic>{}
            : <String, dynamic>{'name': name.trim()},
      );

      final responseBody = response.data;
      final userJson = responseBody?['data'];

      if (userJson is! Map) {
        throw const ApiException('Invalid user response from server.');
      }

      return AppUser.fromJson(Map<String, dynamic>.from(userJson));
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseMessage(error), statusCode: null);
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

  String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
