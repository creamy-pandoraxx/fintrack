import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import {
  validateBody,
  validateQuery
} from "../../middleware/validate.middleware";
import {
  createCategoryController,
  deleteCategoryController,
  listCategoriesController,
  updateCategoryController
} from "./category.controller";
import {
  createCategorySchema,
  listCategoriesQuerySchema,
  updateCategorySchema
} from "./category.schema";

export const categoryRouter = Router();

categoryRouter.use(authMiddleware);

categoryRouter.get(
  "/categories",
  validateQuery(listCategoriesQuerySchema),
  listCategoriesController
);
categoryRouter.post(
  "/categories",
  validateBody(createCategorySchema),
  createCategoryController
);
categoryRouter.patch(
  "/categories/:id",
  validateBody(updateCategorySchema),
  updateCategoryController
);
categoryRouter.delete("/categories/:id", deleteCategoryController);
