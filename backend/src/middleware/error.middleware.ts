import type { ErrorRequestHandler } from "express";

import { errorResponse } from "../utils/api-response";
import { HttpError } from "../utils/http-error";

export const errorMiddleware: ErrorRequestHandler = (error, _req, res, _next) => {
  if (error instanceof HttpError) {
    return res
      .status(error.statusCode)
      .json(errorResponse(error.message, error.errors));
  }

  console.error(error);

  return res.status(500).json(errorResponse("Internal server error"));
};
