import type { Category, Transaction, Wallet } from "@prisma/client";

type TransactionWithRelations = Transaction & {
  wallet?: Pick<Wallet, "id" | "name">;
  category?: Pick<Category, "id" | "name" | "icon" | "color">;
};

export const presentTransaction = (transaction: TransactionWithRelations) => ({
  ...transaction,
  amount: transaction.amount.toNumber()
});

export const presentTransactions = (transactions: TransactionWithRelations[]) =>
  transactions.map(presentTransaction);
