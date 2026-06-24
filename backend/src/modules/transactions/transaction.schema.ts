import { TransactionType } from "@prisma/client";
import { z } from "zod";

const idSchema = z.string().uuid();
const amountSchema = z.number().positive().max(999999999);
const titleSchema = z.string().trim().min(1).max(150);
const noteSchema = z.string().trim().max(500).nullable().optional();
const transactionDateSchema = z.coerce.date();

export const transactionTypeSchema = z.nativeEnum(TransactionType);

export const listTransactionsQuerySchema = z
  .object({
    type: transactionTypeSchema.optional(),
    walletId: idSchema.optional(),
    categoryId: idSchema.optional(),
    startDate: z.coerce.date().optional(),
    endDate: z.coerce.date().optional(),
    search: z.string().trim().min(1).max(100).optional(),
    page: z.coerce.number().int().positive().default(1),
    limit: z.coerce.number().int().positive().max(100).default(20)
  })
  .strict()
  .refine(
    (value) =>
      !value.startDate || !value.endDate || value.startDate <= value.endDate,
    {
      message: "startDate must be before or equal to endDate",
      path: ["startDate"]
    }
  );

export const createTransactionSchema = z
  .object({
    walletId: idSchema,
    categoryId: idSchema,
    type: transactionTypeSchema,
    amount: amountSchema,
    title: titleSchema,
    note: noteSchema,
    transactionDate: transactionDateSchema
  })
  .strict();

export const updateTransactionSchema = createTransactionSchema;

export type ListTransactionsQuery = z.infer<typeof listTransactionsQuerySchema>;
export type CreateTransactionInput = z.infer<typeof createTransactionSchema>;
export type UpdateTransactionInput = z.infer<typeof updateTransactionSchema>;
