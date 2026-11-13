import assert from "node:assert/strict";
import { test } from "node:test";

import { asResponse, createFakeResponse, fakeRequest } from "../test-utils/http";
import { createRateLimiter } from "./rate-limit.middleware";

const run = (limiter: ReturnType<typeof createRateLimiter>, ip: string) => {
  const res = createFakeResponse();
  let nextCalled = false;

  limiter(fakeRequest(ip), asResponse(res), () => {
    nextCalled = true;
  });

  return { res, nextCalled };
};

test("allows requests up to the limit and then answers 429", () => {
  const limiter = createRateLimiter({ windowMs: 1000, max: 2, now: () => 0 });

  assert.equal(run(limiter, "1.1.1.1").nextCalled, true);
  assert.equal(run(limiter, "1.1.1.1").nextCalled, true);

  const blocked = run(limiter, "1.1.1.1");
  assert.equal(blocked.nextCalled, false);
  assert.equal(blocked.res.statusCode, 429);
  assert.equal(blocked.res.headers["Retry-After"], "1");
  assert.deepEqual(blocked.res.body, {
    success: false,
    message: "Too many requests",
    errors: []
  });
});

test("tracks each client IP separately", () => {
  const limiter = createRateLimiter({ windowMs: 1000, max: 1, now: () => 0 });

  assert.equal(run(limiter, "1.1.1.1").nextCalled, true);
  assert.equal(run(limiter, "1.1.1.1").nextCalled, false);
  assert.equal(run(limiter, "2.2.2.2").nextCalled, true);
});

test("starts a new window after windowMs", () => {
  let clock = 0;
  const limiter = createRateLimiter({ windowMs: 1000, max: 1, now: () => clock });

  assert.equal(run(limiter, "1.1.1.1").nextCalled, true);
  assert.equal(run(limiter, "1.1.1.1").nextCalled, false);

  clock = 1000;
  assert.equal(run(limiter, "1.1.1.1").nextCalled, true);
});

test("reports remaining requests in headers", () => {
  const limiter = createRateLimiter({ windowMs: 1000, max: 3, now: () => 0 });

  const first = run(limiter, "1.1.1.1");
  assert.equal(first.res.headers["RateLimit-Limit"], "3");
  assert.equal(first.res.headers["RateLimit-Remaining"], "2");
});
