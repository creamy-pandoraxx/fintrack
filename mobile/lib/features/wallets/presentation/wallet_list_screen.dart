import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../domain/wallet.dart';
import 'wallet_controller.dart';

class WalletListScreen extends ConsumerStatefulWidget {
  const WalletListScreen({super.key});

  @override
  ConsumerState<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends ConsumerState<WalletListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletControllerProvider.notifier).loadWallets();
    });
  }

  Future<void> _confirmDelete(Wallet wallet) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive wallet?'),
          content: Text(
            '${wallet.name} will be archived and removed from your active wallet list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final success = await ref
        .read(walletControllerProvider.notifier)
        .deleteWallet(wallet.id);

    if (!mounted || success) {
      return;
    }

    final message = ref.read(walletControllerProvider).errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: walletState.isMutating
            ? null
            : () => context.push('/wallets/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add wallet'),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (walletState.isLoading && walletState.wallets.isEmpty) {
              return const LoadingView();
            }

            if (walletState.errorMessage != null &&
                walletState.wallets.isEmpty) {
              return ErrorView(
                message: walletState.errorMessage!,
                onRetry: () =>
                    ref.read(walletControllerProvider.notifier).loadWallets(),
              );
            }

            if (walletState.wallets.isEmpty) {
              return EmptyState(
                title: 'No wallets yet',
                message: 'Create a wallet to start tracking your balances.',
                action: FilledButton.icon(
                  onPressed: () => context.push('/wallets/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add wallet'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(walletControllerProvider.notifier).loadWallets(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: walletState.wallets.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _TotalBalanceCard(
                      totalBalance: walletState.totalBalance,
                    );
                  }

                  final wallet = walletState.wallets[index - 1];
                  return _WalletTile(
                    wallet: wallet,
                    onTap: () => context.push('/wallets/${wallet.id}/edit'),
                    onDelete: () => _confirmDelete(wallet),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.totalBalance});

  final double totalBalance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total balance',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              MoneyFormatter.formatIdr(totalBalance),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile({
    required this.wallet,
    required this.onTap,
    required this.onDelete,
  });

  final Wallet wallet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(_iconForType(wallet.type))),
        title: Text(wallet.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${wallet.type.label} - ${wallet.currency}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              MoneyFormatter.formatIdr(
                wallet.currentBalance,
                currency: wallet.currency,
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Archive')),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(WalletType type) {
    return switch (type) {
      WalletType.cash => Icons.payments_outlined,
      WalletType.bank => Icons.account_balance_outlined,
      WalletType.eWallet => Icons.account_balance_wallet_outlined,
      WalletType.savings => Icons.savings_outlined,
      WalletType.other => Icons.wallet_outlined,
    };
  }
}
