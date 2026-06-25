import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_spacing.dart';
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
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  late CategoryType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
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
            icon: _iconController.text,
            color: _colorController.text,
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
                  iconController: _iconController,
                  colorController: _colorController,
                  selectedType: _selectedType,
                  onTypeChanged: (value) {
                    setState(() {
                      _selectedType = value;
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
