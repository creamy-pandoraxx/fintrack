import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import { validateQuery } from "../../middleware/validate.middleware";
import { getDashboardSummaryController } from "./dashboard.controller";
import { dashboardSummaryQuerySchema } from "./dashboard.schema";

export const dashboardRouter = Router();

dashboardRouter.use(authMiddleware);

dashboardRouter.get(
  "/dashboard/summary",
  validateQuery(dashboardSummaryQuerySchema),
  getDashboardSummaryController
);
