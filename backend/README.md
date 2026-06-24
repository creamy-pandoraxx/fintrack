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
