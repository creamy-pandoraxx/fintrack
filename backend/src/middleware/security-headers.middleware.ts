import type { RequestHandler } from "express";

type SecurityHeadersOptions = {
  // Only send HSTS when the API is served over HTTPS (normally production).
  hsts: boolean;
};

// Minimal hardening headers for a JSON-only API. Every response is private
// financial data, so it must never be cached by shared caches or the browser.
export const createSecurityHeaders = ({
  hsts
}: SecurityHeadersOptions): RequestHandler => {
  return (_req, res, next) => {
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("X-Frame-Options", "DENY");
    res.setHeader("Referrer-Policy", "no-referrer");
    res.setHeader("Cross-Origin-Resource-Policy", "same-origin");
    res.setHeader(
      "Content-Security-Policy",
      "default-src 'none'; frame-ancestors 'none'"
    );
    res.setHeader("Cache-Control", "no-store");

    if (hsts) {
      res.setHeader(
        "Strict-Transport-Security",
        "max-age=15552000; includeSubDomains"
      );
    }

    next();
  };
};
