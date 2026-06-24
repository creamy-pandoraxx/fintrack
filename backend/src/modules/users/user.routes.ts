import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import { validateBody } from "../../middleware/validate.middleware";
import {
  getCurrentUserController,
  updateCurrentUserController
} from "./user.controller";
import { updateUserSchema } from "./user.schema";

export const userRouter = Router();

userRouter.get("/users/me", authMiddleware, getCurrentUserController);
userRouter.patch(
  "/users/me",
  authMiddleware,
  validateBody(updateUserSchema),
  updateCurrentUserController
);
