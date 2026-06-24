import { Prisma, TransactionType } from "@prisma/client";

import { prisma } from "../../config/prisma";
import { getMonthDateRange } from "../../utils/month-range";
import { presentBudgets } from "../budgets/budget.presenter";
import { getBudgetUsedAmounts } from "../budgets/budget.service";
import { presentTransactions } from "../transactions/transaction.presenter";
import { getCurrentUser } from "../users/user.service";
import type { DashboardSummaryQuery } from "./dashboard.schema";

const zero = new Prisma.Decimal(0);

const decimalToNumber = (value: Prisma.Decimal | null | undefined) =>
  (value ?? zero).toNumber();

export const getDashboardSummary = async (
  firebaseUid: string,
  query: DashboardSummaryQuery
) => {
  const user = await getCurrentUser(firebaseUid);
  const { startDate, endDate } = getMonthDateRange(query.month, query.year);

  const [
    walletBalance,
    monthlyTransactionSums,
    expenseByCategorySums,
    budgets,
    recentTransactions
  ] = await prisma.$transaction([
    prisma.wallet.aggregate({
      where: {
        userId: user.id,
        isArchived: false
      },
      _sum: {
        currentBalance: true
      }
    }),
    prisma.transaction.groupBy({
      by: ["type"],
      orderBy: {
        type: "asc"
      },
      where: {
        userId: user.id,
        transactionDate: {
          gte: startDate,
          lt: endDate
        }
      },
      _sum: {
        amount: true
      }
    }),
    prisma.transaction.groupBy({
      by: ["categoryId"],
      orderBy: {
        categoryId: "asc"
      },
      where: {
        userId: user.id,
        type: TransactionType.EXPENSE,
        transactionDate: {
          gte: startDate,
          lt: endDate
        }
      },
      _sum: {
        amount: true
      }
    }),
    prisma.budget.findMany({
      where: {
        userId: user.id,
        month: query.month,
        year: query.year
      },
      include: {
        category: {
          select: {
            id: true,
            name: true,
            icon: true,
            color: true
          }
        }
      },
      orderBy: {
        createdAt: "asc"
      }
    }),
    prisma.transaction.findMany({
      where: {
        userId: user.id
      },
      include: {
        wallet: {
          select: {
            id: true,
            name: true
          }
        },
        category: {
          select: {
            id: true,
            name: true,
            icon: true,
            color: true
          }
        }
      },
      orderBy: {
        transactionDate: "desc"
      },
      take: 5
    })
  ]);

  const incomeSum = monthlyTransactionSums.find(
    (item) => item.type === TransactionType.INCOME
  );
  const expenseSum = monthlyTransactionSums.find(
    (item) => item.type === TransactionType.EXPENSE
  );
  const monthlyIncome = decimalToNumber(incomeSum?._sum?.amount);
  const monthlyExpense = decimalToNumber(expenseSum?._sum?.amount);

  const categoryIds = expenseByCategorySums.map((item) => item.categoryId);
  const categories = await prisma.category.findMany({
    where: {
      id: {
        in: categoryIds
      },
      userId: user.id
    },
    select: {
      id: true,
      name: true
    }
  });
  const categoryById = new Map(
    categories.map((category) => [category.id, category])
  );

  const expenseByCategory = expenseByCategorySums.map((item) => {
    const amount = decimalToNumber(item._sum?.amount);
    const category = categoryById.get(item.categoryId);

    return {
      categoryId: item.categoryId,
      categoryName: category?.name ?? "Unknown",
      amount,
      percentage: monthlyExpense > 0 ? (amount / monthlyExpense) * 100 : 0
    };
  });

  const budgetUsedAmounts = await getBudgetUsedAmounts(
    user.id,
    budgets.map((budget) => budget.categoryId),
    query.month,
    query.year
  );

  return {
    totalBalance: decimalToNumber(walletBalance._sum.currentBalance),
    monthlyIncome,
    monthlyExpense,
    netCashFlow: monthlyIncome - monthlyExpense,
    expenseByCategory,
    budgetSummary: presentBudgets(budgets, budgetUsedAmounts).map((budget) => ({
      budgetId: budget.id,
      categoryName: budget.category.name,
      limitAmount: budget.limitAmount,
      usedAmount: budget.usedAmount,
      remainingAmount: budget.remainingAmount,
      usagePercentage: budget.usagePercentage
    })),
    recentTransactions: presentTransactions(recentTransactions)
  };
};
