import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
import '../../../core/utils/app_color_utils.dart';
import '../../../core/utils/category_icon_mapper.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import 'category_controller.dart';
import 'category_form_fields.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key, this.initialType = CategoryType.expense});

  final CategoryType initialType;

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late CategoryType _selectedType;
  String _selectedIconKey = CategoryIconMapper.defaultKey;
  String _selectedColorHex = AppColorUtils.fallbackHex;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedIconKey = widget.initialType == CategoryType.income
        ? 'salary'
        : CategoryIconMapper.defaultKey;
    _selectedColorHex = widget.initialType == CategoryType.income
        ? '#22C55E'
        : '#3B82F6';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(categoryControllerProvider.notifier)
        .createCategory(
          CreateCategoryInput(
            name: _nameController.text,
            type: _selectedType,
            icon: _selectedIconKey,
            color: _selectedColorHex,
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
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add category')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  onTypeChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
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
                  label: const Text('Create category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
