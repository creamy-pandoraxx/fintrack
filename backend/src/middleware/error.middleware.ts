import type { ErrorRequestHandler } from "express";

import { errorResponse } from "../utils/api-response";

export const errorMiddleware: ErrorRequestHandler = (error, _req, res, _next) => {
  console.error(error);

  return res.status(500).json(errorResponse("Internal server error"));
};
