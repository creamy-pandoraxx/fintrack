# FinTrack

FinTrack is a full-stack mobile personal finance tracker portfolio project.

The project is planned as:

- `backend/` - Node.js, Express, TypeScript REST API
- `mobile/` - Flutter mobile app
- `docs/` - product and technical documentation

## Current Milestone

This repository currently contains the backend API foundation and mobile Flutter foundation:

- Backend Express TypeScript project structure
- Health check endpoint
- Backend environment example
- Prisma setup placeholder
- Mobile Flutter app structure with Riverpod, Dio, router, Firebase packages, and base UI states
- PostgreSQL Docker Compose setup

Mobile auth UI is not implemented yet.

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

Prisma is scaffolded but financial models are intentionally deferred to the Prisma schema milestone.

Available placeholder commands:

```bash
cd backend
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

## Documentation

Project documentation lives in `docs/`:

- `API_SPEC.MD`
- `DEVELOPMENT_PLAN.md`
- `PRD.md`
- `TECHNICAL_REQUIRMENTS.md`
