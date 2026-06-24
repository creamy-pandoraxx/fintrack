import { Prisma, TransactionType } from "@prisma/client";

import { prisma } from "../../config/prisma";
import { HttpError } from "../../utils/http-error";
import { getMonthDateRange } from "../../utils/month-range";
import { getCurrentUser } from "../users/user.service";
import type {
  CreateBudgetInput,
  ListBudgetsQuery,
  UpdateBudgetInput
} from "./budget.schema";

const budgetInclude = {
  category: {
    select: {
      id: true,
      name: true,
      icon: true,
      color: true
    }
  }
} as const;

const findBudgetForUser = async (firebaseUid: string, budgetId: string) => {
  const budget = await prisma.budget.findFirst({
    where: {
      id: budgetId,
      user: {
        firebaseUid
      }
    },
    include: budgetInclude
  });

  if (!budget) {
    throw new HttpError(404, "Budget not found");
  }

  return budget;
};

const assertExpenseCategory = async (userId: string, categoryId: string) => {
  const category = await prisma.category.findFirst({
    where: {
      id: categoryId,
      userId
    }
  });

  if (!category) {
    throw new HttpError(404, "Category not found");
  }

  if (category.type !== TransactionType.EXPENSE) {
    throw new HttpError(422, "Budget category must be an expense category", [
      {
        field: "categoryId",
        message: "Budget category must be an expense category"
      }
    ]);
  }
};

export const getBudgetUsedAmounts = async (
  userId: string,
  categoryIds: string[],
  month: number,
  year: number
) => {
  if (categoryIds.length === 0) {
    return new Map<string, Prisma.Decimal>();
  }

  const { startDate, endDate } = getMonthDateRange(month, year);
  const groupedTransactions = await prisma.transaction.groupBy({
    by: ["categoryId"],
    orderBy: {
      categoryId: "asc"
    },
    where: {
      userId,
      categoryId: {
        in: categoryIds
      },
      type: TransactionType.EXPENSE,
      transactionDate: {
        gte: startDate,
        lt: endDate
      }
    },
    _sum: {
      amount: true
    }
  });

  return new Map(
    groupedTransactions.map((item) => [
      item.categoryId,
      item._sum.amount ?? new Prisma.Decimal(0)
    ])
  );
};

export const listBudgets = async (
  firebaseUid: string,
  query: ListBudgetsQuery
) => {
  const user = await getCurrentUser(firebaseUid);
  const budgets = await prisma.budget.findMany({
    where: {
      userId: user.id,
      month: query.month,
      year: query.year
    },
    include: budgetInclude,
    orderBy: {
      createdAt: "asc"
    }
  });

  const usedAmountByCategoryId = await getBudgetUsedAmounts(
    user.id,
    budgets.map((budget) => budget.categoryId),
    query.month,
    query.year
  );

  return { budgets, usedAmountByCategoryId };
};

export const createBudget = async (
  firebaseUid: string,
  input: CreateBudgetInput
) => {
  const user = await getCurrentUser(firebaseUid);
  await assertExpenseCategory(user.id, input.categoryId);

  try {
    return await prisma.budget.create({
      data: {
        userId: user.id,
        categoryId: input.categoryId,
        month: input.month,
        year: input.year,
        limitAmount: new Prisma.Decimal(input.limitAmount)
      },
      include: budgetInclude
    });
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === "P2002"
    ) {
      throw new HttpError(
        409,
        "Budget already exists for this category and month"
      );
    }

    throw error;
  }
};

export const updateBudget = async (
  firebaseUid: string,
  budgetId: string,
  input: UpdateBudgetInput
) => {
  await findBudgetForUser(firebaseUid, budgetId);

  return prisma.budget.update({
    where: {
      id: budgetId
    },
    data: {
      limitAmount: new Prisma.Decimal(input.limitAmount)
    },
    include: budgetInclude
  });
};

export const deleteBudget = async (firebaseUid: string, budgetId: string) => {
  await findBudgetForUser(firebaseUid, budgetId);

  await prisma.budget.delete({
    where: {
      id: budgetId
    }
  });
};
