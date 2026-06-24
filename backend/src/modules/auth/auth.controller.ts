import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import { syncUser } from "./auth.service";
import type { SyncUserInput } from "./auth.schema";

export const syncUserController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const user = await syncUser({
      firebaseUid: auth.firebaseUid,
      email: auth.email,
      input: req.body as SyncUserInput
    });

    return res
      .status(200)
      .json(successResponse("User synced successfully", user));
  }
);
