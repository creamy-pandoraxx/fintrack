import { z } from "zod";

export const syncUserSchema = z.object({
  name: z.string().trim().min(1).optional()
});

export type SyncUserInput = z.infer<typeof syncUserSchema>;
