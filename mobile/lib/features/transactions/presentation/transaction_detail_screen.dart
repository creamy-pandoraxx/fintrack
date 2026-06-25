import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../domain/transaction.dart';
import 'transaction_controller.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionDetail = ref.watch(
      transactionDetailProvider(transactionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction detail'),
        actions: [
          IconButton(
            tooltip: 'Edit transaction',
            onPressed: () => context.push('/transactions/$transactionId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: transactionDetail.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: 'Could not load this transaction.',
            onRetry: () =>
                ref.invalidate(transactionDetailProvider(transactionId)),
          ),
          data: (transaction) {
            final isIncome = transaction.type == TransactionType.income;
            final amountColor = isIncome ? AppColors.success : AppColors.danger;
            final amountPrefix = isIncome ? '+' : '-';

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$amountPrefix${MoneyFormatter.formatIdr(transaction.amount)}',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: amountColor),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(label: 'Type', value: transaction.type.label),
                  _DetailRow(
                    label: 'Date',
                    value: DateFormatter.formatDisplay(
                      transaction.transactionDate,
                    ),
                  ),
                  _DetailRow(
                    label: 'Wallet',
                    value: transaction.wallet?.name ?? '-',
                  ),
                  _DetailRow(
                    label: 'Category',
                    value: transaction.category?.name ?? '-',
                  ),
                  if (transaction.note != null &&
                      transaction.note!.trim().isNotEmpty)
                    _DetailRow(label: 'Note', value: transaction.note!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
