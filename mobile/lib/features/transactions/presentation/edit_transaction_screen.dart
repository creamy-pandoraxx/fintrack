import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../categories/presentation/category_controller.dart';
import '../../wallets/presentation/wallet_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import 'transaction_controller.dart';
import 'transaction_form_fields.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime? _selectedDate;
  bool _didPopulate = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletControllerProvider.notifier).loadWallets();
      ref.read(categoryControllerProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _populate(Transaction transaction) {
    if (_didPopulate) {
      return;
    }

    _titleController.text = transaction.title;
    _amountController.text = MoneyFormatter.formatNumber(transaction.amount);
    _noteController.text = transaction.note ?? '';
    _selectedType = transaction.type;
    _selectedWalletId = transaction.wallet?.id;
    _selectedCategoryId = transaction.category?.id;
    _selectedDate = transaction.transactionDate;
    _didPopulate = true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      setState(() {});
      return;
    }

    final success = await ref
        .read(transactionControllerProvider.notifier)
        .updateTransaction(
          widget.transactionId,
          TransactionInput(
            walletId: _selectedWalletId!,
            categoryId: _selectedCategoryId!,
            type: _selectedType,
            amount: MoneyFormatter.parseGroupedNumber(_amountController.text)!,
            title: _titleController.text,
            note: _noteController.text,
            transactionDate: _selectedDate!,
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/transactions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionDetail = ref.watch(
      transactionDetailProvider(widget.transactionId),
    );
    final transactionState = ref.watch(transactionControllerProvider);
    final walletState = ref.watch(walletControllerProvider);
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit transaction')),
      body: SafeArea(
        child: transactionDetail.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: 'Could not load this transaction.',
            onRetry: () =>
                ref.invalidate(transactionDetailProvider(widget.transactionId)),
          ),
          data: (transaction) {
            _populate(transaction);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TransactionFormFields(
                      titleController: _titleController,
                      amountController: _amountController,
                      noteController: _noteController,
                      selectedType: _selectedType,
                      selectedWalletId: _selectedWalletId,
                      selectedCategoryId: _selectedCategoryId,
                      selectedDate: _selectedDate,
                      wallets: walletState.wallets,
                      incomeCategories: categoryState.incomeCategories,
                      expenseCategories: categoryState.expenseCategories,
                      onTypeChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedCategoryId = null;
                        });
                      },
                      onWalletChanged: (value) {
                        setState(() {
                          _selectedWalletId = value;
                        });
                      },
                      onCategoryChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      onDateChanged: (value) {
                        setState(() {
                          _selectedDate = value;
                        });
                      },
                    ),
                    if (transactionState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        transactionState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: transactionState.isMutating ? null : _submit,
                      icon: transactionState.isMutating
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
}
