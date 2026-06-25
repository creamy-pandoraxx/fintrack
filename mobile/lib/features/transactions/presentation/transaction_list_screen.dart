import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import 'transaction_controller.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionControllerProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Transaction transaction) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text('${transaction.title} will be permanently deleted.'),
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
        .read(transactionControllerProvider.notifier)
        .deleteTransaction(transaction.id);

    if (!mounted || success) {
      return;
    }

    final message = ref.read(transactionControllerProvider).errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _applyFilter(TransactionListFilter filter) {
    ref
        .read(transactionControllerProvider.notifier)
        .loadTransactions(
          filter: filter.copyWith(search: _searchController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: transactionState.isMutating
            ? null
            : () => context.push('/transactions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionControllerProvider.notifier)
                              .loadTransactions(
                                filter: transactionState.filter.copyWith(
                                  search: '',
                                ),
                              );
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    onSubmitted: (value) {
                      ref
                          .read(transactionControllerProvider.notifier)
                          .loadTransactions(
                            filter: transactionState.filter.copyWith(
                              search: value,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected:
                              transactionState.filter.type == null &&
                              !transactionState.filter.thisMonth,
                          onSelected: () =>
                              _applyFilter(const TransactionListFilter()),
                        ),
                        _FilterChip(
                          label: 'Income',
                          selected:
                              transactionState.filter.type ==
                              TransactionType.income,
                          onSelected: () => _applyFilter(
                            const TransactionListFilter(
                              type: TransactionType.income,
                            ),
                          ),
                        ),
                        _FilterChip(
                          label: 'Expense',
                          selected:
                              transactionState.filter.type ==
                              TransactionType.expense,
                          onSelected: () => _applyFilter(
                            const TransactionListFilter(
                              type: TransactionType.expense,
                            ),
                          ),
                        ),
                        _FilterChip(
                          label: 'This month',
                          selected: transactionState.filter.thisMonth,
                          onSelected: () => _applyFilter(
                            const TransactionListFilter(thisMonth: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (transactionState.isLoading &&
                      transactionState.transactions.isEmpty) {
                    return const LoadingView();
                  }

                  if (transactionState.errorMessage != null &&
                      transactionState.transactions.isEmpty) {
                    return ErrorView(
                      message: transactionState.errorMessage!,
                      onRetry: () => ref
                          .read(transactionControllerProvider.notifier)
                          .loadTransactions(),
                    );
                  }

                  if (transactionState.transactions.isEmpty) {
                    return EmptyState(
                      title: 'No transactions yet',
                      message: 'Add your first income or expense transaction.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/transactions/add'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add transaction'),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(transactionControllerProvider.notifier)
                        .loadTransactions(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount: transactionState.transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final transaction =
                            transactionState.transactions[index];
                        return _TransactionTile(
                          transaction: transaction,
                          onTap: () =>
                              context.push('/transactions/${transaction.id}'),
                          onEdit: () => context.push(
                            '/transactions/${transaction.id}/edit',
                          ),
                          onDelete: () => _confirmDelete(transaction),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.success : AppColors.danger;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(isIncome ? Icons.trending_up : Icons.trending_down),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          [
            transaction.category?.name ?? 'No category',
            transaction.wallet?.name ?? 'No wallet',
            DateFormatter.formatDisplay(transaction.transactionDate),
          ].join(' - '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amountPrefix${MoneyFormatter.formatIdr(transaction.amount)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: amountColor),
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
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
