import { TransactionType } from "@prisma/client";
import { z } from "zod";

const categoryNameSchema = z.string().trim().min(1).max(100);
const iconSchema = z.string().trim().min(1).max(50).nullable().optional();
const colorSchema = z
  .string()
  .trim()
  .regex(/^#[0-9A-Fa-f]{6}$/, "Color must be a valid hex color")
  .nullable()
  .optional();

export const categoryTypeSchema = z.nativeEnum(TransactionType);

export const listCategoriesQuerySchema = z
  .object({
    type: categoryTypeSchema.optional()
  })
  .strict();

export const createCategorySchema = z
  .object({
    name: categoryNameSchema,
    type: categoryTypeSchema,
    icon: iconSchema,
    color: colorSchema
  })
  .strict();

export const updateCategorySchema = z
  .object({
    name: categoryNameSchema.optional(),
    icon: iconSchema,
    color: colorSchema
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: "At least one field is required"
  });

export type ListCategoriesQuery = z.infer<typeof listCategoriesQuerySchema>;
export type CreateCategoryInput = z.infer<typeof createCategorySchema>;
export type UpdateCategoryInput = z.infer<typeof updateCategorySchema>;
