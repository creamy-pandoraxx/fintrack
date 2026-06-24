import type { Budget, Category } from "@prisma/client";
import { Prisma } from "@prisma/client";

type BudgetWithCategory = Budget & {
  category: Pick<Category, "id" | "name" | "icon" | "color">;
};

const toNumber = (value: Prisma.Decimal) => value.toNumber();

export const presentBudget = (
  budget: BudgetWithCategory,
  usedAmount = new Prisma.Decimal(0)
) => {
  const limitAmount = toNumber(budget.limitAmount);
  const used = toNumber(usedAmount);
  const remaining = limitAmount - used;
  const usagePercentage = limitAmount > 0 ? (used / limitAmount) * 100 : 0;

  return {
    id: budget.id,
    category: budget.category,
    month: budget.month,
    year: budget.year,
    limitAmount,
    usedAmount: used,
    remainingAmount: remaining,
    usagePercentage,
    createdAt: budget.createdAt,
    updatedAt: budget.updatedAt
  };
};

export const presentBudgets = (
  budgets: BudgetWithCategory[],
  usedAmountByCategoryId: Map<string, Prisma.Decimal>
) =>
  budgets.map((budget) =>
    presentBudget(
      budget,
      usedAmountByCategoryId.get(budget.categoryId) ?? new Prisma.Decimal(0)
    )
  );
