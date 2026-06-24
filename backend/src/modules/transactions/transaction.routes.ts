import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import {
  validateBody,
  validateQuery
} from "../../middleware/validate.middleware";
import {
  createTransactionController,
  deleteTransactionController,
  getTransactionByIdController,
  listTransactionsController,
  updateTransactionController
} from "./transaction.controller";
import {
  createTransactionSchema,
  listTransactionsQuerySchema,
  updateTransactionSchema
} from "./transaction.schema";

export const transactionRouter = Router();

transactionRouter.use(authMiddleware);

transactionRouter.get(
  "/transactions",
  validateQuery(listTransactionsQuerySchema),
  listTransactionsController
);
transactionRouter.post(
  "/transactions",
  validateBody(createTransactionSchema),
  createTransactionController
);
transactionRouter.get("/transactions/:id", getTransactionByIdController);
transactionRouter.patch(
  "/transactions/:id",
  validateBody(updateTransactionSchema),
  updateTransactionController
);
transactionRouter.delete("/transactions/:id", deleteTransactionController);
