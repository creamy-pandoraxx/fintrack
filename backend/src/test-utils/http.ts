import type { Request, Response } from "express";

export type FakeResponse = {
  statusCode: number;
  headers: Record<string, string>;
  body: unknown;
  setHeader: (name: string, value: string) => FakeResponse;
  status: (code: number) => FakeResponse;
  json: (body: unknown) => FakeResponse;
};

export const createFakeResponse = (): FakeResponse => {
  const res: FakeResponse = {
    statusCode: 200,
    headers: {},
    body: undefined,
    setHeader(name, value) {
      res.headers[name] = value;
      return res;
    },
    status(code) {
      res.statusCode = code;
      return res;
    },
    json(body) {
      res.body = body;
      return res;
    }
  };

  return res;
};

export const asResponse = (res: FakeResponse): Response =>
  res as unknown as Response;

export const fakeRequest = (ip = "203.0.113.10"): Request =>
  ({ ip }) as unknown as Request;
