import { getApps, initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

import { env } from "./env";

const getFirebaseCredentials = () => {
  const { projectId, clientEmail, privateKey } = env.firebase;

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error("Firebase Admin environment variables are not configured.");
  }

  return {
    projectId,
    clientEmail,
    privateKey
  };
};

export const getFirebaseAuth = () => {
  if (!getApps().length) {
    initializeApp({
      credential: cert(getFirebaseCredentials())
    });
  }

  return getAuth();
};
