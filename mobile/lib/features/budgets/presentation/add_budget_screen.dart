import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../categories/presentation/category_controller.dart';
import '../data/budget_repository.dart';
import 'budget_controller.dart';
import 'budget_form_fields.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({
    super.key,
    required this.initialMonth,
    required this.initialYear,
  });

  final int initialMonth;
  final int initialYear;

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitAmountController = TextEditingController();
  late final TextEditingController _yearController;
  String? _selectedCategoryId;
  late int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _yearController = TextEditingController(
      text: widget.initialYear.toString(),
    );
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(budgetControllerProvider.notifier)
        .createBudget(
          CreateBudgetInput(
            categoryId: _selectedCategoryId!,
            month: _selectedMonth!,
            year: int.parse(_yearController.text.trim()),
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
    final categoryState = ref.watch(categoryControllerProvider);
    final budgetState = ref.watch(budgetControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add budget')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  expenseCategories: categoryState.expenseCategories,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  onMonthChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                ),
                if (categoryState.isLoading) ...[
                  const SizedBox(height: AppSpacing.md),
                  const LinearProgressIndicator(),
                ],
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
                  label: const Text('Create budget'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
