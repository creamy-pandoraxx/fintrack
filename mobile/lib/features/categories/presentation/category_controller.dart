import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';

final categoryControllerProvider =
    NotifierProvider<CategoryController, CategoryState>(CategoryController.new);

final categoryDetailProvider = FutureProvider.family<Category, String>((
  ref,
  categoryId,
) async {
  final cachedCategory = ref
      .watch(categoryControllerProvider)
      .allCategories
      .where((category) => category.id == categoryId)
      .firstOrNull;

  if (cachedCategory != null) {
    return cachedCategory;
  }

  final categories = await ref
      .watch(categoryRepositoryProvider)
      .listCategories();
  return categories.firstWhere((category) => category.id == categoryId);
});

class CategoryState {
  const CategoryState({
    this.incomeCategories = const [],
    this.expenseCategories = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  List<Category> get allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];

  List<Category> categoriesForType(CategoryType type) {
    return switch (type) {
      CategoryType.income => incomeCategories,
      CategoryType.expense => expenseCategories,
    };
  }

  CategoryState copyWith({
    List<Category>? incomeCategories,
    List<Category>? expenseCategories,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CategoryController extends Notifier<CategoryState> {
  @override
  CategoryState build() => const CategoryState();

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(categoryRepositoryProvider);
      final results = await Future.wait([
        repository.listCategories(type: CategoryType.income),
        repository.listCategories(type: CategoryType.expense),
      ]);

      state = state.copyWith(
        incomeCategories: results[0],
        expenseCategories: results[1],
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

  Future<bool> createCategory(CreateCategoryInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(categoryRepositoryProvider).createCategory(input);
      await _refreshAfterMutation();
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageFrom(error),
      );
      return false;
    }
  }

  Future<bool> updateCategory(String id, UpdateCategoryInput input) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      final updatedCategory = await ref
          .read(categoryRepositoryProvider)
          .updateCategory(id, input);

      state = _replaceCategory(
        updatedCategory,
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

  Future<bool> deleteCategory(String id) async {
    state = state.copyWith(isMutating: true, clearError: true);

    try {
      await ref.read(categoryRepositoryProvider).deleteCategory(id);
      await _refreshAfterMutation();
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

  Future<void> _refreshAfterMutation() async {
    final repository = ref.read(categoryRepositoryProvider);
    final results = await Future.wait([
      repository.listCategories(type: CategoryType.income),
      repository.listCategories(type: CategoryType.expense),
    ]);

    state = state.copyWith(
      incomeCategories: results[0],
      expenseCategories: results[1],
      isMutating: false,
      clearError: true,
    );
  }

  CategoryState _replaceCategory(Category updatedCategory) {
    return state.copyWith(
      incomeCategories: state.incomeCategories
          .map(
            (category) =>
                category.id == updatedCategory.id ? updatedCategory : category,
          )
          .toList(),
      expenseCategories: state.expenseCategories
          .map(
            (category) =>
                category.id == updatedCategory.id ? updatedCategory : category,
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
