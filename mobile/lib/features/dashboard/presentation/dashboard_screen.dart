import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_spacing.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../activity/data/activity_repository.dart';
import '../../activity/domain/activity_feed_item.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../finance_tips/data/finance_tips_repository.dart';
import '../../finance_tips/domain/finance_tip.dart';
import '../../transactions/domain/transaction.dart';
import '../../wallets/presentation/wallet_controller.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_controller.dart';

const _monthLabels = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshDashboard);
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      ref.read(dashboardControllerProvider.notifier).loadSummary(),
      ref.read(walletControllerProvider.notifier).loadWallets(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final summary = dashboardState.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: dashboardState.isLoading ? null : _refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (dashboardState.isLoading && summary == null) {
              return const LoadingView();
            }

            if (dashboardState.errorMessage != null && summary == null) {
              return ErrorView(
                message: dashboardState.errorMessage!,
                onRetry: _refreshDashboard,
              );
            }

            if (summary == null) {
              return const LoadingView();
            }

            return RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _GreetingSection(period: dashboardState.period),
                  const SizedBox(height: AppSpacing.md),
                  _PeriodSelector(
                    month: dashboardState.period.month,
                    year: dashboardState.period.year,
                    isLoading: dashboardState.isLoading,
                    onPrevious: () => ref
                        .read(dashboardControllerProvider.notifier)
                        .showPreviousMonth(),
                    onNext: () => ref
                        .read(dashboardControllerProvider.notifier)
                        .showNextMonth(),
                  ),
                  if (dashboardState.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _InlineError(message: dashboardState.errorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _WalletEmptyPrompt(),
                  _TotalBalanceCard(totalBalance: summary.totalBalance),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryGrid(summary: summary),
                  const SizedBox(height: AppSpacing.md),
                  _QuickActions(),
                  const SizedBox(height: AppSpacing.md),
                  _FinanceTipCard(),
                  const SizedBox(height: AppSpacing.md),
                  _ExpenseBreakdownCard(items: summary.expenseByCategory),
                  const SizedBox(height: AppSpacing.md),
                  _BudgetPreviewCard(items: summary.budgetSummary),
                  const SizedBox(height: AppSpacing.md),
                  _RecentTransactionsCard(
                    transactions: summary.recentTransactions,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ActivityPreviewCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GreetingSection extends ConsumerWidget {
  const _GreetingSection({required this.period});

  final DashboardPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name?.trim();
    final greetingName = name == null || name.isEmpty ? 'there' : name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, $greetingName',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Here is your ${_formatPeriod(period.month, period.year)} money snapshot.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: isLoading ? null : onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                _formatPeriod(month, year),
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
        ),
      ),
    );
  }
}

class _WalletEmptyPrompt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    if (walletState.isLoading ||
        walletState.errorMessage != null ||
        walletState.wallets.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _EmptyPromptCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No wallets yet',
        message: 'Create a wallet so your dashboard has a balance to track.',
        actionLabel: 'Manage wallets',
        onPressed: () => context.push('/wallets'),
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
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                MoneyFormatter.formatIdr(totalBalance),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: [
        _SummaryMetricCard(
          title: 'Income',
          value: MoneyFormatter.formatIdr(summary.monthlyIncome),
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
        _SummaryMetricCard(
          title: 'Expense',
          value: MoneyFormatter.formatIdr(summary.monthlyExpense),
          icon: Icons.trending_down,
          color: AppColors.danger,
        ),
        _SummaryMetricCard(
          title: 'Net cash flow',
          value: MoneyFormatter.formatIdr(summary.netCashFlow),
          icon: Icons.swap_vert,
          color: summary.netCashFlow >= 0
              ? AppColors.success
              : AppColors.danger,
        ),
        _SummaryMetricCard(
          title: 'Transactions',
          value: summary.monthlyTransactionCount.toString(),
          icon: Icons.receipt_long_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(icon, size: 18),
            ),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallets',
            onPressed: () => context.push('/wallets'),
          ),
          _QuickActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Transactions',
            onPressed: () => context.push('/transactions'),
          ),
          _QuickActionButton(
            icon: Icons.pie_chart_outline,
            label: 'Budgets',
            onPressed: () => context.push('/budgets'),
          ),
          _QuickActionButton(
            icon: Icons.person_outline,
            label: 'Profile',
            onPressed: () => context.push('/settings'),
          ),
          _QuickActionButton(
            icon: Icons.notifications_none,
            label: 'Activity',
            onPressed: () => context.push('/activity'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({required this.items});

  final List<ExpenseByCategory> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPromptCard(
        icon: Icons.donut_large_outlined,
        title: 'No expense breakdown yet',
        message: 'Add expense transactions to see where your money goes.',
        actionLabel: 'Add transaction',
        onPressed: () => context.push('/transactions/add'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Expense breakdown',
              actionLabel: 'View all',
              onAction: () => context.push('/transactions'),
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ExpenseBreakdownRow(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBreakdownRow extends StatelessWidget {
  const _ExpenseBreakdownRow({required this.item});

  final ExpenseByCategory item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.percentage / 100).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.categoryName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              MoneyFormatter.formatIdr(item.amount),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${item.percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _BudgetPreviewCard extends StatelessWidget {
  const _BudgetPreviewCard({required this.items});

  final List<DashboardBudgetSummary> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPromptCard(
        icon: Icons.pie_chart_outline,
        title: 'No budgets yet',
        message: 'Set a monthly category limit to track spending progress.',
        actionLabel: 'Manage budgets',
        onPressed: () => context.push('/budgets'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Budget progress',
              actionLabel: 'View all',
              onAction: () => context.push('/budgets'),
            ),
            const SizedBox(height: AppSpacing.md),
            ...items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _BudgetPreviewRow(item: item),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BudgetPreviewRow extends StatelessWidget {
  const _BudgetPreviewRow({required this.item});

  final DashboardBudgetSummary item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.usagePercentage / 100).clamp(0.0, 1.0).toDouble();
    final remainingLabel = item.remainingAmount < 0 ? 'Over' : 'Remaining';
    final remainingAmount = item.remainingAmount.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.categoryName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              '${item.usagePercentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${MoneyFormatter.formatIdr(item.usedAmount)} used of ${MoneyFormatter.formatIdr(item.limitAmount)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '$remainingLabel ${MoneyFormatter.formatIdr(remainingAmount)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.transactions});

  final List<DashboardRecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _EmptyPromptCard(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions yet',
        message: 'Add your first income or expense to populate the dashboard.',
        actionLabel: 'Add transaction',
        onPressed: () => context.push('/transactions/add'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Recent transactions',
              actionLabel: 'View all',
              onAction: () => context.push('/transactions'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...transactions.map(
              (transaction) => _RecentTransactionTile(
                transaction: transaction,
                onTap: () => context.push('/transactions/${transaction.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceTipCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipState = ref.watch(activeFinanceTipsProvider);
    final tip = tipState.when(
      data: (tips) => tips.firstOrNull ?? fallbackFinanceTip,
      error: (error, stackTrace) => fallbackFinanceTip,
      loading: () => fallbackFinanceTip,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.tips_and_updates_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(tip.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityPreviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityFeedPreviewProvider);

    return activityState.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => _EmptyPromptCard(
        icon: Icons.notifications_off_outlined,
        title: 'Activity feed unavailable',
        message: 'Realtime activity will appear here when Firestore is ready.',
        actionLabel: 'Open activity',
        onPressed: () => context.push('/activity'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyPromptCard(
            icon: Icons.notifications_none,
            title: 'No recent activity',
            message: 'Account activity will appear here in realtime.',
            actionLabel: 'Open activity',
            onPressed: () => context.push('/activity'),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'Recent activity',
                  actionLabel: 'View all',
                  onAction: () => context.push('/activity'),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...items.map((item) => _ActivityPreviewRow(item: item)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityPreviewRow extends StatelessWidget {
  const _ActivityPreviewRow({required this.item});

  final ActivityFeedItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.notifications_none)),
      title: Text(item.title),
      subtitle: Text(
        [
          if (item.message.isNotEmpty) item.message,
          _formatActivityDate(item.createdAt),
        ].join(' - '),
      ),
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({
    required this.transaction,
    required this.onTap,
  });

  final DashboardRecentTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.success : AppColors.danger;
    final amountPrefix = isIncome ? '+' : '-';
    final details = [
      transaction.category?.name ?? 'No category',
      transaction.wallet?.name ?? 'No wallet',
      DateFormatter.formatDisplay(transaction.transactionDate),
    ].join(' - ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _parseColor(transaction.category?.color),
        child: Icon(isIncome ? Icons.trending_up : Icons.trending_down),
      ),
      title: Text(transaction.title),
      subtitle: Text(details),
      trailing: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$amountPrefix${MoneyFormatter.formatIdr(transaction.amount)}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: amountColor),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyPromptCard extends StatelessWidget {
  const _EmptyPromptCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonal(
                      onPressed: onPressed,
                      child: Text(actionLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPeriod(int month, int year) {
  return '${_monthLabels[month - 1]} $year';
}

String _formatActivityDate(DateTime? value) {
  if (value == null) {
    return 'Just now';
  }

  return DateFormatter.formatDisplay(value);
}

Color? _parseColor(String? value) {
  final normalized = value?.replaceFirst('#', '');
  if (normalized == null || normalized.length != 6) {
    return null;
  }

  final colorValue = int.tryParse('FF$normalized', radix: 16);
  if (colorValue == null) {
    return null;
  }

  return Color(colorValue);
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
