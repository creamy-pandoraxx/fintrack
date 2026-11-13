import assert from "node:assert/strict";
import { test } from "node:test";

import { asResponse, createFakeResponse, fakeRequest } from "../test-utils/http";
import { createSecurityHeaders } from "./security-headers.middleware";

const run = (hsts: boolean) => {
  const res = createFakeResponse();
  let nextCalled = false;

  createSecurityHeaders({ hsts })(fakeRequest(), asResponse(res), () => {
    nextCalled = true;
  });

  return { res, nextCalled };
};

test("sets hardening headers and never caches responses", () => {
  const { res, nextCalled } = run(false);

  assert.equal(nextCalled, true);
  assert.equal(res.headers["X-Content-Type-Options"], "nosniff");
  assert.equal(res.headers["X-Frame-Options"], "DENY");
  assert.equal(res.headers["Cache-Control"], "no-store");
  assert.equal(res.headers["Strict-Transport-Security"], undefined);
});

test("adds HSTS only when enabled", () => {
  assert.match(
    run(true).res.headers["Strict-Transport-Security"],
    /max-age=\d+/
  );
});
