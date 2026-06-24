import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import {
  validateBody,
  validateQuery
} from "../../middleware/validate.middleware";
import {
  createBudgetController,
  deleteBudgetController,
  listBudgetsController,
  updateBudgetController
} from "./budget.controller";
import {
  createBudgetSchema,
  listBudgetsQuerySchema,
  updateBudgetSchema
} from "./budget.schema";

export const budgetRouter = Router();

budgetRouter.use(authMiddleware);

budgetRouter.get(
  "/budgets",
  validateQuery(listBudgetsQuerySchema),
  listBudgetsController
);
budgetRouter.post(
  "/budgets",
  validateBody(createBudgetSchema),
  createBudgetController
);
budgetRouter.patch(
  "/budgets/:id",
  validateBody(updateBudgetSchema),
  updateBudgetController
);
budgetRouter.delete("/budgets/:id", deleteBudgetController);
