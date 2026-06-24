import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import type {
  CreateBudgetInput,
  ListBudgetsQuery,
  UpdateBudgetInput
} from "./budget.schema";
import { presentBudget, presentBudgets } from "./budget.presenter";
import {
  createBudget,
  deleteBudget,
  listBudgets,
  updateBudget
} from "./budget.service";

export const listBudgetsController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const result = await listBudgets(
      auth.firebaseUid,
      req.query as unknown as ListBudgetsQuery
    );

    return res
      .status(200)
      .json(
        successResponse(
          "Budgets retrieved successfully",
          presentBudgets(result.budgets, result.usedAmountByCategoryId)
        )
      );
  }
);

export const createBudgetController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const budget = await createBudget(
      auth.firebaseUid,
      req.body as CreateBudgetInput
    );

    return res
      .status(201)
      .json(successResponse("Budget created successfully", presentBudget(budget)));
  }
);

export const updateBudgetController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const budget = await updateBudget(
      auth.firebaseUid,
      req.params.id,
      req.body as UpdateBudgetInput
    );

    return res
      .status(200)
      .json(successResponse("Budget updated successfully", presentBudget(budget)));
  }
);

export const deleteBudgetController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    await deleteBudget(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(successResponse<null>("Budget deleted successfully", null));
  }
);
