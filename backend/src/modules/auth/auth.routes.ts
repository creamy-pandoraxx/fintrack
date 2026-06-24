import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import { validateBody } from "../../middleware/validate.middleware";
import { syncUserController } from "./auth.controller";
import { syncUserSchema } from "./auth.schema";

export const authRouter = Router();

authRouter.post(
  "/auth/sync",
  authMiddleware,
  validateBody(syncUserSchema),
  syncUserController
);
