import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import type { UpdateUserInput } from "./user.schema";
import {
  deleteCurrentUser,
  getCurrentUser,
  updateCurrentUser
} from "./user.service";

export const getCurrentUserController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const user = await getCurrentUser(auth.firebaseUid);

    return res
      .status(200)
      .json(successResponse("User profile retrieved successfully", user));
  }
);

export const updateCurrentUserController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const user = await updateCurrentUser(
      auth.firebaseUid,
      req.body as UpdateUserInput
    );

    return res
      .status(200)
      .json(successResponse("User profile updated successfully", user));
  }
);

export const deleteCurrentUserController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    await deleteCurrentUser(auth.firebaseUid);

    return res
      .status(200)
      .json(successResponse("Account deleted successfully", { deleted: true }));
  }
);
