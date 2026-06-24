import { z } from "zod";

const walletNameSchema = z.string().trim().min(1).max(100);
const walletTypeSchema = z.string().trim().min(1).max(50);
const currencySchema = z
  .string()
  .trim()
  .length(3)
  .transform((value) => value.toUpperCase());
const moneySchema = z.number().min(0).max(999999999);

export const createWalletSchema = z
  .object({
    name: walletNameSchema,
    type: walletTypeSchema,
    initialBalance: moneySchema,
    currency: currencySchema.optional().default("IDR")
  })
  .strict();

export const updateWalletSchema = z
  .object({
    name: walletNameSchema.optional(),
    type: walletTypeSchema.optional(),
    currency: currencySchema.optional()
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: "At least one field is required"
  });

export type CreateWalletInput = z.infer<typeof createWalletSchema>;
export type UpdateWalletInput = z.infer<typeof updateWalletSchema>;
