# FinTrack Backend

Express TypeScript REST API for FinTrack.

## Current Scope

The backend currently includes:

- Express app and server entrypoint
- Health check endpoint
- Environment configuration
- Centralized API response helpers
- Centralized error middleware
- Firebase Admin ID-token verification and authenticated user sync
- Prisma/PostgreSQL models and migration for users, wallets, categories, transactions, and budgets
- User, wallet, category, transaction, budget, and dashboard APIs
- Transactional wallet balance updates
- Firestore summary events for transaction changes, wallet creation, and budget creation/update

## Local Development

```bash
npm install
npx prisma migrate dev
npm run prisma:generate
npm run dev
```

By default, the API binds to `127.0.0.1:3000`. To test from a physical Android device on the same Wi-Fi network, set `HOST=0.0.0.0` before starting the backend.

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
HOST=127.0.0.1
PORT=3000
DATABASE_URL="postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public"
FIREBASE_PROJECT_ID=""
FIREBASE_CLIENT_EMAIL=""
FIREBASE_PRIVATE_KEY=""
```

Use the Firebase service account private key value for `FIREBASE_PRIVATE_KEY`. If storing it on one line, keep escaped newlines as `\n`.

## Firestore Scope

PostgreSQL remains the source of truth for all financial data. The backend writes summary-only activity events to `users/{firebaseUid}/activity_feed`; Firestore failures are logged without rolling back a successful PostgreSQL mutation. Finance tips are dynamic Firestore content read by the mobile app, not backend financial records.

Deploy Firestore rules and indexes from the `mobile/` directory as described in `mobile/README.md`.

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
