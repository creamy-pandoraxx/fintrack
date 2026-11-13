import cors from "cors";
import express from "express";

import { env } from "./config/env";
import { errorMiddleware } from "./middleware/error.middleware";
import { createRateLimiter } from "./middleware/rate-limit.middleware";
import { createSecurityHeaders } from "./middleware/security-headers.middleware";
import routes from "./routes";
import { errorResponse } from "./utils/api-response";

export const app = express();

app.disable("x-powered-by");
app.set("trust proxy", env.trustProxy);

app.use(createSecurityHeaders({ hsts: env.isProduction }));

// The mobile client is not a browser and does not need CORS. Only enable it
// for an explicit allow-list of origins (CORS_ORIGINS), never for "*".
if (env.corsOrigins.length > 0) {
  app.use(
    cors({
      origin: env.corsOrigins,
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
      allowedHeaders: ["Authorization", "Content-Type"],
      maxAge: 600
    })
  );
}

app.use("/api/v1", createRateLimiter(env.rateLimit));
app.use(express.json({ limit: "100kb" }));

app.use(routes);

app.use((_req, res) => {
  res.status(404).json(errorResponse("Route not found"));
});

app.use(errorMiddleware);
