import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/category_icon_circle.dart';
import '../../../core/widgets/category_progress_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../domain/budget.dart';
import 'budget_controller.dart';
import 'budget_form_fields.dart';

class BudgetListScreen extends ConsumerStatefulWidget {
  const BudgetListScreen({super.key});

  @override
  ConsumerState<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends ConsumerState<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(budgetControllerProvider.notifier).loadBudgets();
    });
  }

  Future<void> _confirmDelete(Budget budget) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete budget?'),
          content: Text('${budget.category.name} budget will be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final success = await ref
        .read(budgetControllerProvider.notifier)
        .deleteBudget(budget.id);

    if (!mounted || success) {
      return;
    }

    final message = ref.read(budgetControllerProvider).errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetControllerProvider);
    final period = budgetState.period;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: budgetState.isMutating
            ? null
            : () => context.push(
                '/budgets/add?month=${period.month}&year=${period.year}',
              ),
        icon: const Icon(Icons.add),
        label: const Text('Add budget'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _PeriodSelector(
                month: period.month,
                year: period.year,
                isLoading: budgetState.isLoading,
                onPrevious: () => ref
                    .read(budgetControllerProvider.notifier)
                    .showPreviousMonth(),
                onNext: () =>
                    ref.read(budgetControllerProvider.notifier).showNextMonth(),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (budgetState.isLoading && budgetState.budgets.isEmpty) {
                    return const LoadingView();
                  }

                  if (budgetState.errorMessage != null &&
                      budgetState.budgets.isEmpty) {
                    return ErrorView(
                      message: budgetState.errorMessage!,
                      onRetry: () => ref
                          .read(budgetControllerProvider.notifier)
                          .loadBudgets(),
                    );
                  }

                  if (budgetState.budgets.isEmpty) {
                    return EmptyState(
                      title: 'No budgets yet',
                      message:
                          'Create a monthly spending limit for a category.',
                      action: FilledButton.icon(
                        onPressed: () => context.push(
                          '/budgets/add?month=${period.month}&year=${period.year}',
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add budget'),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(budgetControllerProvider.notifier)
                        .loadBudgets(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount: budgetState.budgets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final budget = budgetState.budgets[index];
                        return _BudgetTile(
                          budget: budget,
                          onEdit: () =>
                              context.push('/budgets/${budget.id}/edit'),
                          onDelete: () => _confirmDelete(budget),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.month,
    required this.year,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final int month;
  final int year;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: isLoading ? null : onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            formatBudgetPeriod(month, year),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: isLoading ? null : onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isOverBudget = budget.usagePercentage >= 100;
    final remainingLabel = isOverBudget ? 'Over budget' : 'Remaining';
    final remainingAmount = budget.remainingAmount.abs();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CategoryIconCircle(
                  iconKey: budget.category.icon,
                  colorHex: budget.category.color,
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatBudgetPeriod(budget.month, budget.year),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BudgetMetric(
                    label: 'Used',
                    value: MoneyFormatter.formatIdr(budget.usedAmount),
                  ),
                ),
                Text(
                  '${budget.usagePercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isOverBudget ? AppColors.danger : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            CategoryProgressBar(
              percentage: budget.usagePercentage,
              colorHex: budget.category.color,
              height: 12,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BudgetMetric(
                    label: 'Limit',
                    value: MoneyFormatter.formatIdr(budget.limitAmount),
                  ),
                ),
                Expanded(
                  child: _BudgetMetric(
                    label: remainingLabel,
                    value: MoneyFormatter.formatIdr(remainingAmount),
                    valueColor: isOverBudget ? AppColors.danger : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
