import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../wallets/presentation/wallet_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';

final transactionControllerProvider =
    NotifierProvider<TransactionController, TransactionState>(
      TransactionController.new,
    );

final transactionDetailProvider = FutureProvider.family<Transaction, String>((
  ref,
  transactionId,
) async {
  final cachedTransaction = ref
      .watch(transactionControllerProvider)
      .transactions
      .where((transaction) => transaction.id == transactionId)
      .firstOrNull;

  if (cachedTransaction != null) {
    return cachedTransaction;
  }

  return ref.watch(transactionRepositoryProvider).getTransaction(transactionId);
});

class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.filter = const TransactionListFilter(),
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final List<Transaction> transactions;
  final TransactionListFilter filter;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  TransactionState copyWith({
    List<Transaction>? transactions,
    TransactionListFilter? filter,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TransactionController extends Notifier<TransactionState> {
  @override
  TransactionState build() => const TransactionState();

  Future<void> loadTransactions({TransactionListFilter? filter}) async {
    final nextFilter = filter ?? state.filter;
    state = state.copyWith(
      filter: nextFilter,
      isLoading: true,
      clearError: true,
    );

    try {
      final transactions = await ref
          .read(transactionRepositoryProvider)
          .listTransactions(filter: nextFilter);
      state = state.copyWith(
        transactions: transactions,
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

  Future<bool> createTransaction(TransactionInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      final createdTransaction = await ref
          .read(transactionRepositoryProvider)
          .createTransaction(input);
      await _refreshAfterMutation(
        fallbackTransactions: _prependIfVisible(createdTransaction),
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

  Future<bool> updateTransaction(String id, TransactionInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref
          .read(transactionRepositoryProvider)
          .updateTransaction(id, input);
      await _refreshAfterMutation(
        fallbackTransactions: _replaceIfVisible(
          id,
          _fallbackUpdatedTransaction(id, input),
        ),
      );
      ref.invalidate(transactionDetailProvider(id));
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      await _refreshAfterMutation(fallbackTransactions: _removeById(id));
      ref.invalidate(transactionDetailProvider(id));
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<void> _refreshAfterMutation({
    required List<Transaction> fallbackTransactions,
  }) async {
    final transactions = await _reloadTransactionsOrFallback(
      fallbackTransactions,
    );
    state = state.copyWith(
      transactions: transactions,
      isMutating: false,
      clearError: true,
    );
    try {
      await ref.read(walletControllerProvider.notifier).loadWallets();
    } catch (_) {
      // Wallet refresh is best-effort; the transaction mutation already succeeded.
    }
  }

  Future<List<Transaction>> _reloadTransactionsOrFallback(
    List<Transaction> fallbackTransactions,
  ) async {
    try {
      return await ref
          .read(transactionRepositoryProvider)
          .listTransactions(filter: state.filter);
    } catch (_) {
      return fallbackTransactions;
    }
  }

  List<Transaction> _prependIfVisible(Transaction transaction) {
    if (!_matchesFilter(transaction)) {
      return state.transactions;
    }

    return [transaction, ...state.transactions];
  }

  List<Transaction> _replaceIfVisible(String id, Transaction transaction) {
    final withoutExisting = state.transactions
        .where((item) => item.id != id)
        .toList();

    if (!_matchesFilter(transaction)) {
      return withoutExisting;
    }

    return [transaction, ...withoutExisting];
  }

  Transaction _fallbackUpdatedTransaction(String id, TransactionInput input) {
    final existingTransaction = state.transactions
        .where((transaction) => transaction.id == id)
        .firstOrNull;
    final existingWallet = existingTransaction?.wallet;
    final existingCategory = existingTransaction?.category;

    return Transaction(
      id: id,
      type: input.type,
      amount: input.amount,
      title: input.title,
      note: input.note,
      transactionDate: input.transactionDate,
      wallet: existingWallet?.id == input.walletId ? existingWallet : null,
      category: existingCategory?.id == input.categoryId
          ? existingCategory
          : null,
    );
  }

  List<Transaction> _removeById(String id) {
    return state.transactions
        .where((transaction) => transaction.id != id)
        .toList();
  }

  bool _matchesFilter(Transaction transaction) {
    final filter = state.filter;

    if (filter.type != null && transaction.type != filter.type) {
      return false;
    }

    if (filter.thisMonth) {
      final now = DateTime.now();
      final date = transaction.transactionDate;
      if (date.year != now.year || date.month != now.month) {
        return false;
      }
    }

    final search = filter.search?.trim().toLowerCase();
    if (search != null && search.isNotEmpty) {
      final title = transaction.title.toLowerCase();
      final note = transaction.note?.toLowerCase() ?? '';
      if (!title.contains(search) && !note.contains(search)) {
        return false;
      }
    }

    return true;
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
