import assert from "node:assert/strict";
import { test } from "node:test";

import { getExclusiveNextDay, getMonthDateRange } from "./month-range";

test("getMonthDateRange covers a whole UTC month, end exclusive", () => {
  const { startDate, endDate } = getMonthDateRange(2, 2026);

  assert.equal(startDate.toISOString(), "2026-02-01T00:00:00.000Z");
  assert.equal(endDate.toISOString(), "2026-03-01T00:00:00.000Z");
});

test("getMonthDateRange rolls December into the next year", () => {
  const { endDate } = getMonthDateRange(12, 2026);

  assert.equal(endDate.toISOString(), "2027-01-01T00:00:00.000Z");
});

test("getExclusiveNextDay returns midnight UTC of the following day", () => {
  const next = getExclusiveNextDay(new Date("2026-01-31T18:30:00.000Z"));

  assert.equal(next.toISOString(), "2026-02-01T00:00:00.000Z");
});
