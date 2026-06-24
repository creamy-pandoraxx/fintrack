import type { RequestHandler } from "express";
import type { ZodSchema } from "zod";

import { errorResponse } from "../utils/api-response";

export const validateBody =
  <T>(schema: ZodSchema<T>): RequestHandler =>
  (req, res, next) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      return res.status(422).json(
        errorResponse(
          "Validation failed",
          result.error.issues.map((issue) => ({
            field: issue.path.join("."),
            message: issue.message
          }))
        )
      );
    }

    req.body = result.data;
    return next();
  };

export const validateQuery =
  <T>(schema: ZodSchema<T>): RequestHandler =>
  (req, res, next) => {
    const result = schema.safeParse(req.query);

    if (!result.success) {
      return res.status(422).json(
        errorResponse(
          "Validation failed",
          result.error.issues.map((issue) => ({
            field: issue.path.join("."),
            message: issue.message
          }))
        )
      );
    }

    req.query = result.data as typeof req.query;
    return next();
  };
