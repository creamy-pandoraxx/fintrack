export type AuthenticatedUser = {
  firebaseUid: string;
  email: string;
};

declare global {
  namespace Express {
    interface Request {
      auth?: AuthenticatedUser;
    }
  }
}
