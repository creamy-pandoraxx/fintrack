# FinTrack

FinTrack is a full-stack mobile personal finance tracker portfolio project.

The repository is organized as:

- `backend/` - Node.js, Express, TypeScript REST API
- `mobile/` - Flutter mobile app
- `docs/` - product and technical documentation

## Current Milestone

This repository contains the working FinTrack MVP foundation and feature flows:

- Firebase Auth registration, login, session restore, backend user sync, and route guards
- Protected Express APIs for users, wallets, categories, transactions, budgets, and dashboard summaries
- Prisma/PostgreSQL financial models with transactional wallet balance updates
- Flutter wallet, category, transaction, budget, dashboard, profile, and activity screens
- Firestore activity summaries and dynamic finance tips
- PostgreSQL Docker Compose setup

## Architecture Direction

PostgreSQL is the source of truth for financial data:

- users
- wallets
- categories
- transactions
- budgets

Firestore is used only for realtime or semi-structured data:

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

The backend uses `PORT=3000` by default and binds to `HOST=127.0.0.1` by default. For physical-device Android testing on the same Wi-Fi network, run it with `HOST=0.0.0.0`.

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
postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public
```

Copy `backend/.env.example` to `backend/.env` when running the backend locally.

## Prisma

The Prisma schema and initial financial-data migration are included. Apply migrations and generate the client with:

```bash
cd backend
npx prisma migrate dev
npm run prisma:format
npm run prisma:generate
```

## Mobile

```bash
cd mobile
flutter pub get
flutter analyze
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Use `http://10.0.2.2:3000/api/v1` for the Android emulator. For a physical Android device on the same Wi-Fi network, start the backend with `HOST=0.0.0.0` and run:

```bash
flutter run --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

## Firebase And Firestore

Flutter Firebase client configuration is stored under `mobile/`. Firebase Admin service-account values belong only in `backend/.env` and must not be committed.

Deploy the activity-feed rules and finance-tip index from `mobile/`:

```bash
cd mobile
firebase deploy --only "firestore:rules,firestore:indexes" --project <FIREBASE_PROJECT_ID>
```

To add a finance tip in Firestore Console, create a document in `finance_tips` with `title` (string), `content` (string), `isActive` (boolean), and `createdAt` (timestamp). The dashboard reads active tips newest first and uses a local fallback when none are available.

## Documentation

Project documentation lives in `docs/`:

- `API_SPEC.MD`
- `DEVELOPMENT_PLAN.md`
- `PRD.md`
- `TECHNICAL_REQUIRMENTS.md`
