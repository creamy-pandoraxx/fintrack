import type { RequestHandler } from "express";

import { getFirebaseAuth } from "../config/firebase";
import { errorResponse } from "../utils/api-response";

const getBearerToken = (authorizationHeader: string | undefined) => {
  if (!authorizationHeader?.startsWith("Bearer ")) {
    return null;
  }

  const token = authorizationHeader.slice("Bearer ".length).trim();

  return token.length > 0 ? token : null;
};

export const authMiddleware: RequestHandler = async (req, res, next) => {
  const token = getBearerToken(req.headers.authorization);

  if (!token) {
    return res.status(401).json(errorResponse("Unauthorized"));
  }

  try {
    const decodedToken = await getFirebaseAuth().verifyIdToken(token);

    if (!decodedToken.email) {
      return res.status(401).json(errorResponse("Unauthorized"));
    }

    req.auth = {
      firebaseUid: decodedToken.uid,
      email: decodedToken.email
    };

    return next();
  } catch {
    return res.status(401).json(errorResponse("Unauthorized"));
  }
};
