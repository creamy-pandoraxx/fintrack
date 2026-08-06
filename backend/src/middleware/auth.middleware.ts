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
  console.log("Authorization:", req.headers.authorization);
  const token = getBearerToken(req.headers.authorization);

  if (!token) {
    console.log("NO TOKEN");
    return res.status(401).json(errorResponse("Unauthorized"));
  }

  try {
    const decodedToken = await getFirebaseAuth().verifyIdToken(token, true);
    console.log("TOKEN VERIFIED:", decodedToken.uid);

    if (!decodedToken.email) {
      return res.status(401).json(errorResponse("Unauthorized"));
    }

    req.auth = {
      firebaseUid: decodedToken.uid,
      email: decodedToken.email
    };

    return next();
  } catch (e) {
    console.error(e);

    return res.status(401).json(errorResponse("Unauthorized"));
  }
};
