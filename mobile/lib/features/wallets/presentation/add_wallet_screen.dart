import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet.dart';
import 'wallet_controller.dart';
import 'wallet_form_fields.dart';

class AddWalletScreen extends ConsumerStatefulWidget {
  const AddWalletScreen({super.key});

  @override
  ConsumerState<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends ConsumerState<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
  final _currencyController = TextEditingController(text: 'IDR');
  WalletType _selectedType = WalletType.cash;

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(walletControllerProvider.notifier)
        .createWallet(
          CreateWalletInput(
            name: _nameController.text,
            type: _selectedType,
            initialBalance: MoneyFormatter.parseGroupedNumber(
              _initialBalanceController.text,
            )!,
            currency: _currencyController.text,
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
    final walletState = ref.watch(walletControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add wallet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WalletFormFields(
                  nameController: _nameController,
                  initialBalanceController: _initialBalanceController,
                  currencyController: _currencyController,
                  selectedType: _selectedType,
                  onTypeChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                if (walletState.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    walletState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: walletState.isMutating ? null : _submit,
                  icon: walletState.isMutating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Create wallet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
