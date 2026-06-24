import { z } from "zod";

const idSchema = z.string().uuid();
const monthSchema = z.coerce.number().int().min(1).max(12);
const yearSchema = z.coerce.number().int().min(2000).max(2100);
const limitAmountSchema = z.number().positive().max(999999999);

export const listBudgetsQuerySchema = z
  .object({
    month: monthSchema,
    year: yearSchema
  })
  .strict();

export const createBudgetSchema = z
  .object({
    categoryId: idSchema,
    month: monthSchema,
    year: yearSchema,
    limitAmount: limitAmountSchema
  })
  .strict();

export const updateBudgetSchema = z
  .object({
    limitAmount: limitAmountSchema
  })
  .strict();

export type ListBudgetsQuery = z.infer<typeof listBudgetsQuerySchema>;
export type CreateBudgetInput = z.infer<typeof createBudgetSchema>;
export type UpdateBudgetInput = z.infer<typeof updateBudgetSchema>;
