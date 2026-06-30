import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

const _unset = Object();

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Object? user = _unset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: identical(user, _unset) ? this.user : user as AppUser?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return user != null;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await ref.read(authRepositoryProvider).logout();
    state = state.copyWith(user: null, isLoading: false, clearError: true);
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = state.copyWith(user: null, isLoading: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
