import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/activity_repository.dart';
import '../domain/activity_feed_item.dart';

class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityFeed = ref.watch(activityFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity feed')),
      body: SafeArea(
        child: activityFeed.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: _messageFrom(error),
            onRetry: () => ref.invalidate(activityFeedProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'No activity yet',
                message:
                    'Account activity from the backend will appear here in realtime.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return ActivityFeedTile(item: items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class ActivityFeedTile extends StatelessWidget {
  const ActivityFeedTile({super.key, required this.item});

  final ActivityFeedItem item;

  @override
  Widget build(BuildContext context) {
    final amount = item.amount;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _activityColor(item),
          foregroundColor: Colors.white,
          child: Icon(_activityIcon(item), size: 18),
        ),
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.message.isNotEmpty) Text(item.message),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatActivityTime(item.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: amount == null
            ? null
            : Text(
                MoneyFormatter.formatIdr(amount),
                style: Theme.of(context).textTheme.titleSmall,
              ),
      ),
    );
  }
}

String _messageFrom(Object error) {
  if (error is ActivityFeedException) {
    return error.message;
  }

  return 'Activity feed is unavailable right now.';
}

IconData _activityIcon(ActivityFeedItem item) {
  return switch (item.type) {
    'transaction_created' => Icons.add_card_outlined,
    'transaction_updated' => Icons.edit_note_outlined,
    'transaction_deleted' => Icons.delete_outline,
    _ => Icons.notifications_none,
  };
}

Color _activityColor(ActivityFeedItem item) {
  if (item.transactionType == 'INCOME') {
    return AppColors.success;
  }

  if (item.transactionType == 'EXPENSE') {
    return AppColors.danger;
  }

  return AppColors.primary;
}

String _formatActivityTime(DateTime? value) {
  if (value == null) {
    return 'Just now';
  }

  final diff = DateTime.now().difference(value);
  if (diff.inMinutes < 1) {
    return 'Just now';
  }

  if (diff.inHours < 1) {
    return '${diff.inMinutes}m ago';
  }

  if (diff.inDays < 1) {
    return '${diff.inHours}h ago';
  }

  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }

  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
