import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_controller.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import 'budget_controller.dart';
import 'budget_form_fields.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  const EditBudgetScreen({super.key, required this.budgetId});

  final String budgetId;

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitAmountController = TextEditingController();
  late final TextEditingController _yearController;
  String? _selectedCategoryId;
  int? _selectedMonth;
  bool _didPopulate = false;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController();
    Future.microtask(() {
      ref.read(categoryControllerProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _limitAmountController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _populate(Budget budget) {
    if (_didPopulate) {
      return;
    }

    _limitAmountController.text = MoneyFormatter.formatNumber(
      budget.limitAmount,
    );
    _yearController.text = budget.year.toString();
    _selectedCategoryId = budget.category.id;
    _selectedMonth = budget.month;
    _didPopulate = true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(budgetControllerProvider.notifier)
        .updateBudget(
          widget.budgetId,
          UpdateBudgetInput(
            limitAmount: MoneyFormatter.parseGroupedNumber(
              _limitAmountController.text,
            )!,
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/budgets');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetDetail = ref.watch(budgetDetailProvider(widget.budgetId));
    final budgetState = ref.watch(budgetControllerProvider);
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit budget')),
      body: SafeArea(
        child: budgetDetail.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: 'Could not load this budget.',
            onRetry: () =>
                ref.invalidate(budgetDetailProvider(widget.budgetId)),
          ),
          data: (budget) {
            _populate(budget);
            final categories = _expenseCategoriesWithCurrent(
              categoryState.expenseCategories,
              budget,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BudgetFormFields(
                      limitAmountController: _limitAmountController,
                      yearController: _yearController,
                      selectedCategoryId: _selectedCategoryId,
                      selectedMonth: _selectedMonth,
                      expenseCategories: categories,
                      onCategoryChanged: (_) {},
                      onMonthChanged: (_) {},
                      categoryEnabled: false,
                      periodEnabled: false,
                    ),
                    if (budgetState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        budgetState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: budgetState.isMutating ? null : _submit,
                      icon: budgetState.isMutating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Category> _expenseCategoriesWithCurrent(
    List<Category> expenseCategories,
    Budget budget,
  ) {
    if (expenseCategories.any(
      (category) => category.id == budget.category.id,
    )) {
      return expenseCategories;
    }

    return [
      Category(
        id: budget.category.id,
        name: budget.category.name,
        type: CategoryType.expense,
        icon: budget.category.icon,
        color: budget.category.color,
        isDefault: false,
      ),
      ...expenseCategories,
    ];
  }
}
