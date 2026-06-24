import { Router } from "express";

import { successResponse } from "../../utils/api-response";

export const healthRouter = Router();

healthRouter.get("/health", (_req, res) => {
  return res.status(200).json(
    successResponse("Health check passed", {
      status: "ok",
      service: "fintrack-backend"
    })
  );
});
