import 'package:fintrack_mobile/features/budgets/presentation/budget_form_fields.dart';
import 'package:fintrack_mobile/features/categories/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lays out and opens the category dropdown on a small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final limitController = TextEditingController();
    final yearController = TextEditingController(text: '2026');
    addTearDown(limitController.dispose);
    addTearDown(yearController.dispose);

    const category = Category(
      id: 'category-1',
      name: 'Household and monthly expenses',
      type: CategoryType.expense,
      isDefault: false,
      icon: 'home',
      color: '#3B82F6',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: BudgetFormFields(
                  limitAmountController: limitController,
                  yearController: yearController,
                  selectedCategoryId: category.id,
                  selectedMonth: 6,
                  expenseCategories: const [category],
                  onCategoryChanged: (_) {},
                  onMonthChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text(category.name), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
