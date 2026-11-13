import { z } from "zod";

export const updateUserSchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  photoUrl: z
    .string()
    .trim()
    .max(2048)
    .url()
    .refine((value) => value.startsWith("https://"), "photoUrl must use https")
    .nullable()
    .optional()
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
