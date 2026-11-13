import type { RequestHandler } from "express";

import { errorResponse } from "../utils/api-response";

type RateLimiterOptions = {
  windowMs: number;
  max: number;
  now?: () => number;
};

type Counter = {
  count: number;
  resetAt: number;
};

// Upper bound on tracked clients so the map cannot grow without limit.
const MAX_TRACKED_KEYS = 10_000;

// Fixed-window, per-IP rate limiter.
//
// State lives in this process only. On several instances (or serverless) the
// effective limit is per instance, so treat it as a brake on bursts and abuse,
// not a hard guarantee. Use an edge/gateway limit for a strict guarantee.
export const createRateLimiter = ({
  windowMs,
  max,
  now = Date.now
}: RateLimiterOptions): RequestHandler => {
  const counters = new Map<string, Counter>();

  const prune = (current: number) => {
    for (const [key, counter] of counters) {
      if (counter.resetAt <= current) {
        counters.delete(key);
      }
    }

    // Still too large (many active clients): drop the oldest entries.
    while (counters.size > MAX_TRACKED_KEYS) {
      const oldest = counters.keys().next().value;
      if (oldest === undefined) break;
      counters.delete(oldest);
    }
  };

  return (req, res, next) => {
    const current = now();
    const key = req.ip ?? "unknown";

    let counter = counters.get(key);

    if (!counter || counter.resetAt <= current) {
      counter = { count: 0, resetAt: current + windowMs };
      counters.set(key, counter);

      if (counters.size > MAX_TRACKED_KEYS) {
        prune(current);
      }
    }

    counter.count += 1;

    const remaining = Math.max(0, max - counter.count);
    res.setHeader("RateLimit-Limit", String(max));
    res.setHeader("RateLimit-Remaining", String(remaining));
    res.setHeader(
      "RateLimit-Reset",
      String(Math.ceil((counter.resetAt - current) / 1000))
    );

    if (counter.count > max) {
      res.setHeader(
        "Retry-After",
        String(Math.max(1, Math.ceil((counter.resetAt - current) / 1000)))
      );
      return res.status(429).json(errorResponse("Too many requests"));
    }

    return next();
  };
};
