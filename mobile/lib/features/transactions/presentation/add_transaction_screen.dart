import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../categories/presentation/category_controller.dart';
import '../../wallets/presentation/wallet_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import 'transaction_controller.dart';
import 'transaction_form_fields.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime? _selectedDate = DateTime.now();

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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      setState(() {});
      return;
    }

    final success = await ref
        .read(transactionControllerProvider.notifier)
        .createTransaction(
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
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);
    final walletState = ref.watch(walletControllerProvider);
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  label: const Text('Create transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
