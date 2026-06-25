import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet.dart';
import 'wallet_controller.dart';
import 'wallet_form_fields.dart';

class EditWalletScreen extends ConsumerStatefulWidget {
  const EditWalletScreen({super.key, required this.walletId});

  final String walletId;

  @override
  ConsumerState<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends ConsumerState<EditWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _currencyController = TextEditingController();
  WalletType _selectedType = WalletType.cash;
  bool _didPopulate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _populate(Wallet wallet) {
    if (_didPopulate) {
      return;
    }

    _nameController.text = wallet.name;
    _initialBalanceController.text = MoneyFormatter.formatNumber(
      wallet.initialBalance,
    );
    _currencyController.text = wallet.currency;
    _selectedType = wallet.type;
    _didPopulate = true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(walletControllerProvider.notifier)
        .updateWallet(
          widget.walletId,
          UpdateWalletInput(
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
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/wallets');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletDetail = ref.watch(walletDetailProvider(widget.walletId));
    final walletState = ref.watch(walletControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit wallet')),
      body: SafeArea(
        child: walletDetail.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: 'Could not load this wallet.',
            onRetry: () =>
                ref.invalidate(walletDetailProvider(widget.walletId)),
          ),
          data: (wallet) {
            _populate(wallet);

            return SingleChildScrollView(
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
