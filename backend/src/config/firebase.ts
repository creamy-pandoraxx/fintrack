import { getApps, initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

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

const getFirebaseApp = () => {
  if (!getApps().length) {
    return initializeApp({
      credential: cert(getFirebaseCredentials())
    });
  }

  return getApps()[0];
};

export const getFirebaseAuth = () => {
  return getAuth(getFirebaseApp());
};

export const getFirebaseFirestore = () => {
  return getFirestore(getFirebaseApp());
};
