import assert from "node:assert/strict";
import { test } from "node:test";

import { HttpError } from "../utils/http-error";
import { asResponse, createFakeResponse, fakeRequest } from "../test-utils/http";
import { errorMiddleware } from "./error.middleware";

const handle = (error: unknown) => {
  const res = createFakeResponse();
  errorMiddleware(error, fakeRequest(), asResponse(res), () => undefined);
  return res;
};

test("maps HttpError to its status and message", () => {
  const res = handle(new HttpError(404, "Wallet not found"));

  assert.equal(res.statusCode, 404);
  assert.deepEqual(res.body, {
    success: false,
    message: "Wallet not found",
    errors: []
  });
});

test("answers 400 for malformed JSON bodies", () => {
  const error = Object.assign(new SyntaxError("Unexpected token"), {
    type: "entity.parse.failed",
    status: 400,
    statusCode: 400
  });

  const res = handle(error);

  assert.equal(res.statusCode, 400);
  assert.equal((res.body as { message: string }).message, "Invalid request body");
});

test("answers 413 for oversized bodies", () => {
  const error = Object.assign(new Error("request entity too large"), {
    type: "entity.too.large",
    status: 413,
    statusCode: 413
  });

  const res = handle(error);

  assert.equal(res.statusCode, 413);
  assert.equal((res.body as { message: string }).message, "Request body too large");
});

test("hides details of unexpected errors behind a generic 500", (t) => {
  t.mock.method(console, "error", () => undefined);

  const res = handle(new Error("database password is hunter2"));

  assert.equal(res.statusCode, 500);
  assert.equal(
    (res.body as { message: string }).message,
    "Internal server error"
  );
});
