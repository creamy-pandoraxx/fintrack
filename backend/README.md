# FinTrack Backend

The FinTrack backend is a protected REST API built with Express and TypeScript. It owns financial business rules, validates requests with Zod, verifies Firebase ID tokens, and persists authoritative data through Prisma and PostgreSQL.

## Implemented Scope

- Public health check.
- Firebase-authenticated user synchronization and profile management.
- Permanent account deletion across PostgreSQL, Firebase Auth, and the user's Firestore activity feed.
- Wallet CRUD with archive-based deletion.
- Income and expense category CRUD with guarded deletion.
- Transaction CRUD with pagination/filters and atomic wallet balance updates.
- Monthly expense budget CRUD and usage calculations.
- Dashboard totals, category breakdown, budget summary, and recent transactions.
- Best-effort summary activity events written to Firestore after supported mutations.
- Consistent success/error responses, centralized error handling, and Zod validation.

There are no backend login or registration endpoints. Firebase Authentication is handled by the mobile client, and this API accepts only verified Firebase ID tokens.

## Architecture

```text
src/
|-- config/       # Environment, Prisma singleton, Firebase Admin
|-- middleware/   # Firebase auth, Zod validation, error handling
|-- modules/      # Feature routes, controllers, services, schemas
|-- routes/       # Root and /api/v1 route composition
|-- types/        # Express request authentication extension
|-- utils/        # API responses, HttpError, async handler
|-- app.ts        # Express application
`-- server.ts     # Configurable HTTP listener
```

Controllers translate HTTP requests and responses. Services own database and business rules. Prisma transactions protect balance-changing operations. Authentication identity comes from `req.auth`, never from a request body `userId`.

## Data Ownership

PostgreSQL is the source of truth for:

- users;
- wallets;
- categories;
- transactions;
- budgets.

Firestore contains summary-only activity feed documents. It is not used to calculate balances, budgets, or dashboard totals. Finance tips are read directly by Flutter and are not backend financial records.

## Prerequisites

- Current Node.js LTS and npm
- Docker Desktop, or another PostgreSQL 16-compatible instance
- A Firebase project and Firebase Admin service account

## Environment Variables

Create a local environment file:

```powershell
Copy-Item .env.example .env
```

| Variable | Required | Development value/purpose |
| --- | --- | --- |
| `NODE_ENV` | No | Defaults to `development` |
| `HOST` | No | `127.0.0.1`; use `0.0.0.0` for LAN device testing |
| `PORT` | No | Defaults to `3000` |
| `DATABASE_URL` | Yes | Prisma PostgreSQL connection string |
| `FIREBASE_PROJECT_ID` | Yes | Firebase project used by the mobile app |
| `FIREBASE_CLIENT_EMAIL` | Yes | Firebase Admin service-account email |
| `FIREBASE_PRIVATE_KEY` | Yes | Service-account private key with `\n` escapes |

Development template:

```env
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
DATABASE_URL="postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public"
FIREBASE_PROJECT_ID="your-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-...@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="<escaped-service-account-private-key>"
```

Never commit `.env`, service-account JSON files, private keys, or real ID tokens.

Generate the Admin credential from **Firebase Console > Project settings > Service accounts > Generate new private key**. Map its `project_id`, `client_email`, and `private_key` values to the variables above, preserve newlines as `\n`, and store the downloaded JSON outside the repository.

## PostgreSQL with Docker

From the repository root:

```powershell
docker compose up -d
docker compose ps
```

The Compose configuration maps host port `5433` to container port `5432`. The backend running on Windows therefore connects to `localhost:5433`.

Stop the container without deleting its named volume:

```powershell
docker compose down
```

## Install and Run

From `backend/`:

```powershell
npm install
npx prisma migrate dev
npm run prisma:generate
npm run typecheck
npm run dev
```

The API defaults to `http://127.0.0.1:3000`. Verify it with:

```powershell
Invoke-RestMethod http://localhost:3000/health
```

For a physical Android device on the same LAN:

```powershell
$env:HOST="0.0.0.0"
npm run dev
```

Only expose the development server on a trusted private network. Use HTTPS and production infrastructure for a deployed build.

## Prisma Commands

| Command | Purpose |
| --- | --- |
| `npx prisma migrate dev` | Apply/create development migrations |
| `npx prisma migrate deploy` | Apply committed migrations in deployment environments |
| `npm run prisma:generate` | Generate Prisma Client |
| `npx prisma validate` | Validate schema and environment configuration |
| `npm run prisma:format` | Format `schema.prisma` |

On Windows, stop running backend processes if Prisma Client generation reports an `EPERM` rename error for `query_engine-windows.dll.node`.

## API Conventions

All feature endpoints use `/api/v1`. The health route is intentionally outside that prefix.

```json
{
  "success": true,
  "message": "Wallets retrieved successfully",
  "data": []
}
```

Errors follow the same envelope:

```json
{
  "success": false,
  "message": "Unauthorized",
  "errors": []
}
```

Protected calls require:

```http
Authorization: Bearer <firebase_id_token>
```

The middleware verifies the token with Firebase Admin and rejects missing, invalid, revoked, or deleted-user tokens with `401`.

## Route Summary

| Area | Routes |
| --- | --- |
| Health | `GET /health` |
| Auth sync | `POST /api/v1/auth/sync` |
| User | `GET`, `PATCH`, `DELETE /api/v1/users/me` |
| Wallet | `GET`, `POST /api/v1/wallets`; `GET`, `PATCH`, `DELETE /api/v1/wallets/:id` |
| Category | `GET`, `POST /api/v1/categories`; `PATCH`, `DELETE /api/v1/categories/:id` |
| Transaction | `GET`, `POST /api/v1/transactions`; `GET`, `PATCH`, `DELETE /api/v1/transactions/:id` |
| Budget | `GET`, `POST /api/v1/budgets`; `PATCH`, `DELETE /api/v1/budgets/:id` |
| Dashboard | `GET /api/v1/dashboard/summary?month=&year=` |

See [../docs/API_SPEC.MD](../docs/API_SPEC.MD) for the detailed contract. A generated Swagger/OpenAPI UI is not implemented yet.

## Verification

```powershell
npm run typecheck
npm run build
npm run prisma:generate
npx prisma validate
```

The current backend does not yet have a dedicated automated API integration test suite; this remains a documented MVP limitation.
