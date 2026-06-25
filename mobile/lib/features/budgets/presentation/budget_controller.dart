import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';

final budgetControllerProvider =
    NotifierProvider<BudgetController, BudgetState>(BudgetController.new);

final budgetDetailProvider = FutureProvider.family<Budget, String>((
  ref,
  budgetId,
) async {
  final state = ref.watch(budgetControllerProvider);
  final cachedBudget = state.budgets
      .where((budget) => budget.id == budgetId)
      .firstOrNull;

  if (cachedBudget != null) {
    return cachedBudget;
  }

  final budgets = await ref
      .watch(budgetRepositoryProvider)
      .listBudgets(month: state.period.month, year: state.period.year);
  return budgets.firstWhere((budget) => budget.id == budgetId);
});

class BudgetState {
  const BudgetState({
    required this.period,
    this.budgets = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final BudgetPeriod period;
  final List<Budget> budgets;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  BudgetState copyWith({
    BudgetPeriod? period,
    List<Budget>? budgets,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      period: period ?? this.period,
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BudgetController extends Notifier<BudgetState> {
  @override
  BudgetState build() => BudgetState(period: BudgetPeriod.current());

  Future<void> loadBudgets({BudgetPeriod? period}) async {
    final targetPeriod = period ?? state.period;
    state = state.copyWith(
      period: targetPeriod,
      isLoading: true,
      clearError: true,
    );

    try {
      final budgets = await ref
          .read(budgetRepositoryProvider)
          .listBudgets(month: targetPeriod.month, year: targetPeriod.year);

      state = state.copyWith(
        budgets: budgets,
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

  Future<bool> createBudget(CreateBudgetInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(budgetRepositoryProvider).createBudget(input);
      await _refreshAfterMutation(
        BudgetPeriod(month: input.month, year: input.year),
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

  Future<bool> updateBudget(String id, UpdateBudgetInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      final updatedBudget = await ref
          .read(budgetRepositoryProvider)
          .updateBudget(id, input);

      state = _replaceBudget(
        updatedBudget,
      ).copyWith(isMutating: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(budgetRepositoryProvider).deleteBudget(id);
      await _refreshAfterMutation(state.period);
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<void> showPreviousMonth() =>
      loadBudgets(period: state.period.previous());

  Future<void> showNextMonth() => loadBudgets(period: state.period.next());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _refreshAfterMutation(BudgetPeriod period) async {
    final budgets = await ref
        .read(budgetRepositoryProvider)
        .listBudgets(month: period.month, year: period.year);

    state = state.copyWith(
      period: period,
      budgets: budgets,
      isMutating: false,
      clearError: true,
    );
  }

  BudgetState _replaceBudget(Budget updatedBudget) {
    return state.copyWith(
      budgets: state.budgets
          .map(
            (budget) => budget.id == updatedBudget.id ? updatedBudget : budget,
          )
          .toList(),
    );
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
