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

const getErrorCode = (error: unknown): string => {
  if (typeof error === "object" && error !== null && "code" in error) {
    return String((error as { code: unknown }).code);
  }

  return "unknown";
};

export const authMiddleware: RequestHandler = async (req, res, next) => {
  const token = getBearerToken(req.headers.authorization);

  if (!token) {
    return res.status(401).json(errorResponse("Unauthorized"));
  }

  try {
    const decodedToken = await getFirebaseAuth().verifyIdToken(token, true);

    if (!decodedToken.email) {
      return res.status(401).json(errorResponse("Unauthorized"));
    }

    req.auth = {
      firebaseUid: decodedToken.uid,
      email: decodedToken.email
    };

    return next();
  } catch (error) {
    const code = getErrorCode(error);

    // Invalid, expired or revoked tokens are a client problem: answer 401 and
    // log only the error code, never the token or the full error.
    if (code.startsWith("auth/")) {
      console.warn(`Token verification failed (${code})`);
      return res.status(401).json(errorResponse("Unauthorized"));
    }

    // Anything else (misconfigured credentials, network failure) is a server
    // problem and must not be reported to the client as "Unauthorized".
    return next(error);
  }
};
