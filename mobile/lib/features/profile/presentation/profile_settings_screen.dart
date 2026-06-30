import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../features/auth/presentation/auth_controller.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your wallets, categories, transactions, '
          'budgets, and account. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final deleted = await ref
        .read(authControllerProvider.notifier)
        .deleteAccount();

    if (deleted && context.mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user?.name?.isNotEmpty == true ? user!.name! : 'FinTrack user',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user?.email ?? 'No email available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Wallets'),
                subtitle: const Text('Manage cash, bank, and savings wallets.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/wallets'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categories'),
                subtitle: const Text('Manage income and expense categories.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/categories'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pie_chart_outline),
                title: const Text('Budgets'),
                subtitle: const Text('Set monthly category spending limits.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/budgets'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none),
                title: const Text('Activity feed'),
                subtitle: const Text(
                  'View realtime account activity summaries.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/activity'),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () => _logout(context, ref),
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: authState.isLoading
                    ? null
                    : () => _deleteAccount(context, ref),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
