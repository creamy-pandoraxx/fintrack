import { z } from "zod";

export const updateUserSchema = z.object({
  name: z.string().trim().min(1).optional(),
  photoUrl: z.string().url().nullable().optional()
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
