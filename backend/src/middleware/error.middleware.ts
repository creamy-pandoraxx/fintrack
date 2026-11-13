import type { ErrorRequestHandler } from "express";

import { errorResponse } from "../utils/api-response";
import { HttpError } from "../utils/http-error";

type BodyParserError = Error & {
  type: string;
  status?: number;
  statusCode?: number;
};

// Errors thrown by express.json(), e.g. malformed JSON or an oversized body.
// They are client mistakes, so they must be 4xx and must not be logged as faults.
const isBodyParserError = (error: unknown): error is BodyParserError =>
  error instanceof Error &&
  typeof (error as Partial<BodyParserError>).type === "string" &&
  (error as BodyParserError).type.startsWith("entity.");

export const errorMiddleware: ErrorRequestHandler = (error, _req, res, _next) => {
  if (error instanceof HttpError) {
    return res
      .status(error.statusCode)
      .json(errorResponse(error.message, error.errors));
  }

  if (isBodyParserError(error)) {
    const statusCode = error.statusCode ?? error.status ?? 400;
    const isTooLarge = statusCode === 413;

    return res
      .status(statusCode >= 400 && statusCode < 500 ? statusCode : 400)
      .json(
        errorResponse(isTooLarge ? "Request body too large" : "Invalid request body")
      );
  }

  console.error(error);

  return res.status(500).json(errorResponse("Internal server error"));
};
