import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import type { DashboardSummaryQuery } from "./dashboard.schema";
import { getDashboardSummary } from "./dashboard.service";

export const getDashboardSummaryController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const summary = await getDashboardSummary(
      auth.firebaseUid,
      req.query as unknown as DashboardSummaryQuery
    );

    return res
      .status(200)
      .json(successResponse("Dashboard summary retrieved successfully", summary));
  }
);
