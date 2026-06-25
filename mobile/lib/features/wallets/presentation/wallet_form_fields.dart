import 'package:flutter/material.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/grouped_number_input_formatter.dart';
import '../domain/wallet.dart';
import 'wallet_validators.dart';

class WalletFormFields extends StatelessWidget {
  const WalletFormFields({
    super.key,
    required this.nameController,
    required this.currencyController,
    required this.selectedType,
    required this.onTypeChanged,
    this.initialBalanceController,
    this.initialBalanceReadOnly = false,
  });

  final TextEditingController nameController;
  final TextEditingController currencyController;
  final TextEditingController? initialBalanceController;
  final bool initialBalanceReadOnly;
  final WalletType selectedType;
  final ValueChanged<WalletType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Wallet name'),
          validator: WalletValidators.requiredName,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<WalletType>(
          initialValue: selectedType,
          decoration: const InputDecoration(labelText: 'Wallet type'),
          items: WalletType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        if (initialBalanceController != null) ...[
          TextFormField(
            controller: initialBalanceController,
            readOnly: initialBalanceReadOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [GroupedNumberInputFormatter()],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Initial balance',
              helperText: initialBalanceReadOnly
                  ? 'Initial balance is locked after wallet creation.'
                  : null,
            ),
            validator: WalletValidators.requiredInitialBalance,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextFormField(
          controller: currencyController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Currency'),
          validator: WalletValidators.requiredCurrency,
        ),
      ],
    );
  }
}
