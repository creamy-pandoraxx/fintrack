import { Prisma, TransactionType, type PrismaClient } from "@prisma/client";

import { prisma } from "../../config/prisma";
import { HttpError } from "../../utils/http-error";
import { getCurrentUser } from "../users/user.service";
import type {
  CreateTransactionInput,
  ListTransactionsQuery,
  UpdateTransactionInput
} from "./transaction.schema";

type PrismaTransactionClient = Parameters<
  Parameters<PrismaClient["$transaction"]>[0]
>[0];

const getSignedAmount = (
  type: TransactionType,
  amount: Prisma.Decimal
): Prisma.Decimal => {
  return type === TransactionType.INCOME ? amount : amount.negated();
};

const getReverseSignedAmount = (
  type: TransactionType,
  amount: Prisma.Decimal
): Prisma.Decimal => {
  return getSignedAmount(type, amount).negated();
};

const findTransactionForUser = async (
  firebaseUid: string,
  transactionId: string
) => {
  const transaction = await prisma.transaction.findFirst({
    where: {
      id: transactionId,
      user: {
        firebaseUid
      }
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
    }
  });

  if (!transaction) {
    throw new HttpError(404, "Transaction not found");
  }

  return transaction;
};

const assertWalletAndCategory = async (
  tx: PrismaTransactionClient,
  userId: string,
  walletId: string,
  categoryId: string,
  type: TransactionType
) => {
  const [wallet, category] = await Promise.all([
    tx.wallet.findFirst({
      where: {
        id: walletId,
        userId,
        isArchived: false
      }
    }),
    tx.category.findFirst({
      where: {
        id: categoryId,
        userId
      }
    })
  ]);

  if (!wallet) {
    throw new HttpError(404, "Wallet not found");
  }

  if (!category) {
    throw new HttpError(404, "Category not found");
  }

  if (category.type !== type) {
    throw new HttpError(422, "Category type must match transaction type", [
      {
        field: "categoryId",
        message: "Category type must match transaction type"
      }
    ]);
  }
};

const updateWalletBalance = async (
  tx: PrismaTransactionClient,
  walletId: string,
  amountChange: Prisma.Decimal
) => {
  return tx.wallet.update({
    where: {
      id: walletId
    },
    data: {
      currentBalance: {
        increment: amountChange
      }
    }
  });
};

export const listTransactions = async (
  firebaseUid: string,
  query: ListTransactionsQuery
) => {
  const where: Prisma.TransactionWhereInput = {
    type: query.type,
    walletId: query.walletId,
    categoryId: query.categoryId,
    user: {
      firebaseUid
    },
    transactionDate: {
      gte: query.startDate,
      lte: query.endDate
    },
    OR: query.search
      ? [
          {
            title: {
              contains: query.search,
              mode: "insensitive"
            }
          },
          {
            note: {
              contains: query.search,
              mode: "insensitive"
            }
          }
        ]
      : undefined
  };

  const skip = (query.page - 1) * query.limit;

  const [items, total] = await prisma.$transaction([
    prisma.transaction.findMany({
      where,
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
      skip,
      take: query.limit
    }),
    prisma.transaction.count({ where })
  ]);

  return {
    items,
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit)
    }
  };
};

export const createTransaction = async (
  firebaseUid: string,
  input: CreateTransactionInput
) => {
  const user = await getCurrentUser(firebaseUid);
  const amount = new Prisma.Decimal(input.amount);

  return prisma.$transaction(async (tx) => {
    await assertWalletAndCategory(
      tx,
      user.id,
      input.walletId,
      input.categoryId,
      input.type
    );

    const transaction = await tx.transaction.create({
      data: {
        userId: user.id,
        walletId: input.walletId,
        categoryId: input.categoryId,
        type: input.type,
        amount,
        title: input.title,
        note: input.note,
        transactionDate: input.transactionDate
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
      }
    });

    await updateWalletBalance(tx, input.walletId, getSignedAmount(input.type, amount));

    return transaction;
  });
};

export const getTransactionById = async (
  firebaseUid: string,
  transactionId: string
) => {
  return findTransactionForUser(firebaseUid, transactionId);
};

export const updateTransaction = async (
  firebaseUid: string,
  transactionId: string,
  input: UpdateTransactionInput
) => {
  const user = await getCurrentUser(firebaseUid);
  const amount = new Prisma.Decimal(input.amount);

  return prisma.$transaction(async (tx) => {
    const existingTransaction = await tx.transaction.findFirst({
      where: {
        id: transactionId,
        userId: user.id
      }
    });

    if (!existingTransaction) {
      throw new HttpError(404, "Transaction not found");
    }

    await assertWalletAndCategory(
      tx,
      user.id,
      input.walletId,
      input.categoryId,
      input.type
    );

    await updateWalletBalance(
      tx,
      existingTransaction.walletId,
      getReverseSignedAmount(existingTransaction.type, existingTransaction.amount)
    );
    await updateWalletBalance(
      tx,
      input.walletId,
      getSignedAmount(input.type, amount)
    );

    return tx.transaction.update({
      where: {
        id: transactionId
      },
      data: {
        walletId: input.walletId,
        categoryId: input.categoryId,
        type: input.type,
        amount,
        title: input.title,
        note: input.note,
        transactionDate: input.transactionDate
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
      }
    });
  });
};

export const deleteTransaction = async (
  firebaseUid: string,
  transactionId: string
) => {
  const user = await getCurrentUser(firebaseUid);

  await prisma.$transaction(async (tx) => {
    const existingTransaction = await tx.transaction.findFirst({
      where: {
        id: transactionId,
        userId: user.id
      }
    });

    if (!existingTransaction) {
      throw new HttpError(404, "Transaction not found");
    }

    await updateWalletBalance(
      tx,
      existingTransaction.walletId,
      getReverseSignedAmount(existingTransaction.type, existingTransaction.amount)
    );

    await tx.transaction.delete({
      where: {
        id: transactionId
      }
    });
  });
};
