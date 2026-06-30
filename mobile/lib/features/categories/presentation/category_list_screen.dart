import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/widgets/category_icon_circle.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../domain/category.dart';
import 'category_controller.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryControllerProvider.notifier).loadCategories();
    });
  }

  Future<void> _confirmDelete(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text(
            '${category.name} will be permanently deleted if it has no transactions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final success = await ref
        .read(categoryControllerProvider.notifier)
        .deleteCategory(category.id);

    if (!mounted || success) {
      return;
    }

    final message = ref.read(categoryControllerProvider).errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryControllerProvider);

    return DefaultTabController(
      length: CategoryType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Expense'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                final type = CategoryType.values[tabController.index];
                return FloatingActionButton.extended(
                  onPressed: categoryState.isMutating
                      ? null
                      : () => context.push(
                          '/categories/add?type=${type.apiValue}',
                        ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add category'),
                );
              },
            );
          },
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (categoryState.isLoading &&
                  categoryState.allCategories.isEmpty) {
                return const LoadingView();
              }

              if (categoryState.errorMessage != null &&
                  categoryState.allCategories.isEmpty) {
                return ErrorView(
                  message: categoryState.errorMessage!,
                  onRetry: () => ref
                      .read(categoryControllerProvider.notifier)
                      .loadCategories(),
                );
              }

              return TabBarView(
                children: [
                  _CategoryTab(
                    type: CategoryType.income,
                    categories: categoryState.incomeCategories,
                    onDelete: _confirmDelete,
                  ),
                  _CategoryTab(
                    type: CategoryType.expense,
                    categories: categoryState.expenseCategories,
                    onDelete: _confirmDelete,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  const _CategoryTab({
    required this.type,
    required this.categories,
    required this.onDelete,
  });

  final CategoryType type;
  final List<Category> categories;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return EmptyState(
        title: 'No ${type.label.toLowerCase()} categories yet',
        message: 'Create a category to organize your transactions later.',
        action: FilledButton.icon(
          onPressed: () =>
              context.push('/categories/add?type=${type.apiValue}'),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(categoryControllerProvider.notifier).loadCategories(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryTile(
            category: category,
            onTap: () => context.push('/categories/${category.id}/edit'),
            onDelete: () => onDelete(category),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CategoryIconCircle(
          iconKey: category.icon,
          colorHex: category.color,
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          [category.type.label, if (category.isDefault) 'Default'].join(' | '),
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
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
