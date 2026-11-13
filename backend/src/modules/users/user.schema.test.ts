import assert from "node:assert/strict";
import { test } from "node:test";

import { syncUserSchema } from "../auth/auth.schema";
import { updateUserSchema } from "./user.schema";

test("updateUserSchema trims the name and rejects empty or oversized names", () => {
  assert.equal(updateUserSchema.parse({ name: "  Zaky  " }).name, "Zaky");
  assert.equal(updateUserSchema.safeParse({ name: "   " }).success, false);
  assert.equal(updateUserSchema.safeParse({ name: "a".repeat(101) }).success, false);
});

test("updateUserSchema only accepts https photo URLs", () => {
  assert.equal(
    updateUserSchema.safeParse({ photoUrl: "https://example.com/a.png" }).success,
    true
  );
  assert.equal(updateUserSchema.safeParse({ photoUrl: null }).success, true);
  assert.equal(
    updateUserSchema.safeParse({ photoUrl: "http://example.com/a.png" }).success,
    false
  );
  assert.equal(
    updateUserSchema.safeParse({ photoUrl: "javascript:alert(1)" }).success,
    false
  );
});

test("syncUserSchema limits name length", () => {
  assert.equal(syncUserSchema.safeParse({}).success, true);
  assert.equal(syncUserSchema.safeParse({ name: "a".repeat(101) }).success, false);
});
