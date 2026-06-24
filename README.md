# FinTrack

FinTrack is a full-stack mobile personal finance tracker portfolio project.

The project is planned as:

- `backend/` - Node.js, Express, TypeScript REST API
- `mobile/` - Flutter mobile app
- `docs/` - product and technical documentation

## Current Milestone

This repository currently contains the initial foundation only:

- Backend Express TypeScript project structure
- Health check endpoint
- Backend environment example
- Prisma setup placeholder
- Mobile Flutter folder structure placeholder
- PostgreSQL Docker Compose setup

Wallets, categories, transactions, budgets, Firebase Authentication, and Firestore are not implemented yet.

## Architecture Direction

PostgreSQL is the source of truth for financial data:

- users
- wallets
- categories
- transactions
- budgets

Firestore will be used later only for realtime or semi-structured data:

- activity feed
- notification logs
- finance tips
- remote config

The Flutter app will communicate with the backend through REST APIs. It must not directly write financial data to PostgreSQL.

## Backend

```bash
cd backend
npm install
npm run dev
```

Health check:

```bash
curl http://localhost:3000/health
```

TypeScript check:

```bash
npm run typecheck
```

## PostgreSQL With Docker

From the repository root:

```bash
docker compose up -d
```

The default local connection string is:

```txt
postgresql://fintrack:fintrack_password@localhost:5432/fintrack_db?schema=public
```

Copy `backend/.env.example` to `backend/.env` when running the backend locally.

## Prisma

Prisma is scaffolded but financial models are intentionally deferred to the Prisma schema milestone.

Available placeholder commands:

```bash
cd backend
npm run prisma:format
npm run prisma:generate
```

## Mobile

The `mobile/` directory is currently a placeholder for the future Flutter foundation milestone. A Flutter project has not been initialized yet.

## Documentation

Project documentation lives in `docs/`:

- `API_SPEC.MD`
- `DEVELOPMENT_PLAN.md`
- `PRD.md`
- `TECHNICAL_REQUIRMENTS.md`
