# FinTrack Backend

Express TypeScript REST API for FinTrack.

## Current Scope

This foundation includes:

- Express app and server entrypoint
- Health check endpoint
- Environment configuration
- Centralized API response helpers
- Centralized error middleware
- Prisma client and schema placeholders

Wallets, categories, transactions, budgets, Firebase auth, and Firestore are intentionally not implemented yet.

## Local Development

```bash
npm install
npm run dev
```

Health check:

```bash
curl http://localhost:3000/health
```

## PostgreSQL

Run PostgreSQL from the repository root:

```bash
docker compose up -d
```

The local database URL is documented in `.env.example`.

## Environment Variables

Required backend environment variables:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public"
FIREBASE_PROJECT_ID=""
FIREBASE_CLIENT_EMAIL=""
FIREBASE_PRIVATE_KEY=""
```

Use the Firebase service account private key value for `FIREBASE_PRIVATE_KEY`. If storing it on one line, keep escaped newlines as `\n`.

## Protected Route Usage

Firebase Auth login/register is handled by the mobile app. Backend routes that need authentication should use `authMiddleware` and read identity from `req.auth`, never from the request body.

```ts
import { Router } from "express";

import { authMiddleware } from "../middleware/auth.middleware";
import { successResponse } from "../utils/api-response";

const router = Router();

router.get("/api/v1/protected-example", authMiddleware, (req, res) => {
  return res.json(
    successResponse("Authenticated", {
      firebaseUid: req.auth?.firebaseUid,
      email: req.auth?.email
    })
  );
});
```
