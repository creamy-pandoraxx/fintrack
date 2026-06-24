import type { Request } from "express";

import type { AuthenticatedUser } from "../types/express";
import { HttpError } from "./http-error";

export const getRequestAuth = (req: Request): AuthenticatedUser => {
  if (!req.auth) {
    throw new HttpError(401, "Unauthorized");
  }

  return req.auth;
};
