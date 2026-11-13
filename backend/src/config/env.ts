import dotenv from "dotenv";

// quiet: dotenv 17+ prints a banner on every start otherwise.
dotenv.config({ quiet: true });

const parseInteger = (
  name: string,
  value: string | undefined,
  fallback: number,
  minimum: number
): number => {
  const parsed = Number(value ?? fallback);

  if (!Number.isInteger(parsed) || parsed < minimum) {
    throw new Error(
      minimum > 0
        ? `${name} must be a positive integer.`
        : `${name} must be a non-negative integer.`
    );
  }

  return parsed;
};

const parseList = (value: string | undefined): string[] =>
  (value ?? "")
    .split(",")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);

const nodeEnv = process.env.NODE_ENV ?? "development";

export const env = {
  nodeEnv,
  isProduction: nodeEnv === "production",
  host: process.env.HOST ?? "127.0.0.1",
  port: parseInteger("PORT", process.env.PORT, 3000, 1),
  databaseUrl: process.env.DATABASE_URL ?? "",
  // Number of reverse proxies in front of the API (0 = none). Needed so that
  // rate limiting sees the real client IP instead of the proxy address.
  trustProxy: parseInteger("TRUST_PROXY", process.env.TRUST_PROXY, 0, 0),
  // Browsers only. The mobile app does not need CORS, so it is off by default.
  corsOrigins: parseList(process.env.CORS_ORIGINS),
  rateLimit: {
    windowMs: parseInteger("RATE_LIMIT_WINDOW_MS", process.env.RATE_LIMIT_WINDOW_MS, 60_000, 1),
    max: parseInteger("RATE_LIMIT_MAX", process.env.RATE_LIMIT_MAX, 300, 1)
  },
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID ?? "",
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL ?? "",
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n") ?? ""
  }
};

// Fail fast at startup instead of returning 500s on the first request.
export const assertRequiredEnv = (): void => {
  const missing: string[] = [];

  if (!env.databaseUrl) missing.push("DATABASE_URL");
  if (!env.firebase.projectId) missing.push("FIREBASE_PROJECT_ID");
  if (!env.firebase.clientEmail) missing.push("FIREBASE_CLIENT_EMAIL");
  if (!env.firebase.privateKey) missing.push("FIREBASE_PRIVATE_KEY");

  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(", ")}`);
  }
};
