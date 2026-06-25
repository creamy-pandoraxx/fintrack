import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet.dart';

final walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(WalletController.new);

final walletDetailProvider = FutureProvider.family<Wallet, String>((
  ref,
  walletId,
) async {
  final cachedWallet = ref
      .watch(walletControllerProvider)
      .wallets
      .where((wallet) => wallet.id == walletId)
      .firstOrNull;

  if (cachedWallet != null) {
    return cachedWallet;
  }

  return ref.watch(walletRepositoryProvider).getWallet(walletId);
});

class WalletState {
  const WalletState({
    this.wallets = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final List<Wallet> wallets;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  double get totalBalance {
    return wallets.fold<double>(
      0,
      (total, wallet) => total + wallet.currentBalance,
    );
  }

  WalletState copyWith({
    List<Wallet>? wallets,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class WalletController extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  Future<void> loadWallets() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final wallets = await ref.read(walletRepositoryProvider).listWallets();
      state = state.copyWith(
        wallets: wallets,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
    }
  }

  Future<bool> createWallet(CreateWalletInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(walletRepositoryProvider).createWallet(input);
      final wallets = await ref.read(walletRepositoryProvider).listWallets();
      state = state.copyWith(
        wallets: wallets,
        isMutating: false,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> updateWallet(String id, UpdateWalletInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      final updatedWallet = await ref
          .read(walletRepositoryProvider)
          .updateWallet(id, input);
      final wallets = state.wallets
          .map((wallet) => wallet.id == id ? updatedWallet : wallet)
          .toList();
      state = state.copyWith(
        wallets: wallets,
        isMutating: false,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> deleteWallet(String id) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(walletRepositoryProvider).deleteWallet(id);
      final wallets = await ref.read(walletRepositoryProvider).listWallets();
      state = state.copyWith(
        wallets: wallets,
        isMutating: false,
        clearError: true,
      );
      ref.invalidate(walletDetailProvider(id));
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
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
