import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/app_color_utils.dart';
import '../../../core/utils/category_icon_mapper.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import 'category_controller.dart';
import 'category_form_fields.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CategoryType _selectedType = CategoryType.expense;
  String _selectedIconKey = CategoryIconMapper.defaultKey;
  String _selectedColorHex = AppColorUtils.fallbackHex;
  bool _didPopulate = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _populate(Category category) {
    if (_didPopulate) {
      return;
    }

    _nameController.text = category.name;
    _selectedIconKey = CategoryIconMapper.normalizeKey(category.icon);
    _selectedColorHex =
        AppColorUtils.normalizeHex(category.color) ?? AppColorUtils.fallbackHex;
    _selectedType = category.type;
    _didPopulate = true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(categoryControllerProvider.notifier)
        .updateCategory(
          widget.categoryId,
          UpdateCategoryInput(
            name: _nameController.text,
            icon: _selectedIconKey,
            color: _selectedColorHex,
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/categories');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetail = ref.watch(categoryDetailProvider(widget.categoryId));
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit category')),
      body: SafeArea(
        child: categoryDetail.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorView(
            message: 'Could not load this category.',
            onRetry: () =>
                ref.invalidate(categoryDetailProvider(widget.categoryId)),
          ),
          data: (category) {
            _populate(category);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CategoryFormFields(
                      nameController: _nameController,
                      selectedType: _selectedType,
                      selectedIconKey: _selectedIconKey,
                      selectedColorHex: _selectedColorHex,
                      typeEnabled: false,
                      onTypeChanged: (_) {},
                      onIconChanged: (value) {
                        setState(() {
                          _selectedIconKey = value;
                        });
                      },
                      onColorChanged: (value) {
                        setState(() {
                          _selectedColorHex = value;
                        });
                      },
                    ),
                    if (categoryState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        categoryState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: categoryState.isMutating ? null : _submit,
                      icon: categoryState.isMutating
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
