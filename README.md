# FinTrack

FinTrack is a full-stack Android personal finance application built as a portfolio project. It combines a Flutter client, an authenticated Express API, PostgreSQL financial records, and a deliberately limited Firestore realtime layer.

> **Project status:** functional MVP. The core finance flows are implemented and automated checks pass, but production deployment, release signing, CI/CD, and broader device testing remain future work.

## Why This Project Exists

FinTrack demonstrates how a mobile product can keep a clean boundary between user experience, business logic, authentication, and persistence. The project was designed to show:

- feature-based Flutter architecture with Riverpod state management;
- secure REST integration using Firebase ID tokens;
- relational modeling and transactional balance updates with Prisma;
- purposeful use of SQL and NoSQL instead of treating them as interchangeable;
- practical Android development across emulator and physical-device environments;
- loading, empty, error, validation, and destructive-action states in the UI.

## MVP Features

- Email/password registration, login, session restoration, logout, and account deletion with Firebase Auth.
- Backend user synchronization and automatic default income/expense categories.
- Wallet create, read, update, and soft delete/archive.
- Custom income and expense categories with reusable icon and color selection.
- Transaction create, read, update, delete, pagination, search/filter controls, and transactional wallet balance updates.
- Monthly expense budgets with usage, remaining amount, and over-budget visualization.
- Dashboard totals, cash flow, expense pie chart, budget preview, and recent transactions.
- Realtime Firestore activity summaries created by the backend.
- Dynamic active finance tips from Firestore with a local fallback.
- Protected routes, consistent API responses, Zod validation, and user-scoped database access.

Not currently implemented: bank integrations, payment execution, recurring transactions, receipt uploads, offline-first synchronization, push notifications, multi-currency accounting, or production hosting.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Mobile | Flutter, Dart, Riverpod, Dio, go_router, fl_chart |
| Authentication | Firebase Authentication, Firebase Admin SDK |
| API | Node.js, TypeScript, Express, Zod |
| Relational data | PostgreSQL, Prisma ORM, Decimal money fields |
| Realtime content | Cloud Firestore |
| Local infrastructure | Docker Compose |

## Architecture

```mermaid
flowchart LR
    A[Flutter Android app] -->|Email and password| B[Firebase Auth]
    B -->|Firebase ID token| A
    A -->|REST + Bearer token| C[Express API]
    C -->|Verify token| D[Firebase Admin]
    C -->|Prisma queries and transactions| E[(PostgreSQL)]
    C -->|Summary activity events| F[(Cloud Firestore)]
    F -->|Own activity feed and active tips| A
```

The Flutter app keeps API calls in repositories and state transitions in Riverpod controllers/notifiers. Express modules own validation, authorization, and business rules. Every protected query derives identity from the verified Firebase token; request bodies are never trusted for `userId`.

### SQL vs NoSQL

**PostgreSQL is the financial source of truth.** It stores users, wallets, categories, transactions, and budgets. Relational constraints, Prisma transactions, UUID identifiers, and Decimal money fields support consistency where balances and ownership matter.

**Firestore is a supporting realtime channel only.** It stores summary activity events under `users/{firebaseUid}/activity_feed` and dynamic documents in `finance_tips`. Flutter does not write wallets, categories, transactions, or budgets to Firestore. Losing Firestore content would affect the feed and tips, not the authoritative financial ledger.

## Authentication Flow

1. Flutter registers or signs in with Firebase Authentication.
2. Firebase returns an ID token; the app does not manually persist it.
3. Dio obtains the current token and sends `Authorization: Bearer <firebase_id_token>`.
4. Firebase Admin verifies the token, including revoked-token checks.
5. `POST /api/v1/auth/sync` finds or creates the PostgreSQL user from the verified UID and email.
6. A newly synchronized user receives default income and expense categories.
7. Protected routes use the verified request identity and scope every database query to that user.

## Repository Structure

```text
fintrack/
|-- backend/
|   |-- prisma/              # Schema and SQL migrations
|   `-- src/
|       |-- config/          # Environment, Prisma, Firebase Admin
|       |-- middleware/      # Authentication, validation, errors
|       |-- modules/         # Auth, users, wallets, categories, etc.
|       |-- routes/          # API route aggregation
|       |-- types/           # Express request extensions
|       `-- utils/           # Responses, errors, async helpers
|-- mobile/
|   |-- android/             # Android platform configuration
|   `-- lib/
|       |-- app/             # Router, theme, shared app constants
|       |-- core/            # Network, Firebase, config, utilities
|       `-- features/        # Feature-based data/domain/presentation code
|-- docs/                    # PRD, API specification, plan, and QA notes
|-- docker-compose.yml
`-- README.md
```

## Prerequisites

- Git
- Docker Desktop with Docker Compose
- A current Node.js LTS release and npm
- Flutter SDK with Android tooling
- Android Studio or another configured Android SDK
- A Firebase project with Email/Password Authentication and Firestore
- Firebase CLI and FlutterFire CLI for regenerating/deploying Firebase configuration

## Local Setup

The commands below use PowerShell from the repository root.

### 1. Configure the backend

```powershell
Copy-Item backend\.env.example backend\.env
```

Fill in the Firebase Admin values in `backend/.env`. Never commit this file or a service-account JSON key.

```env
NODE_ENV=development
HOST=127.0.0.1
PORT=3000
DATABASE_URL="postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public"
FIREBASE_PROJECT_ID="your-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-...@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="<escaped-service-account-private-key>"
```

Create the Admin credential from **Firebase Console > Project settings > Service accounts > Generate new private key**. Copy only `project_id`, `client_email`, and `private_key` into the matching environment variables, preserve private-key newlines as `\n`, and keep the downloaded JSON file outside this repository.

### 2. Start PostgreSQL with Docker

```powershell
docker compose up -d
docker compose ps
```

Docker maps host port `5433` to PostgreSQL's container port `5432`. Local `DATABASE_URL` examples must therefore use `localhost:5433`.

### 3. Install and migrate the backend

```powershell
Push-Location backend
npm install
npx prisma migrate dev
npm run prisma:generate
npm run typecheck
Pop-Location
```

Start the API:

```powershell
Push-Location backend
npm run dev
```

Verify the public health endpoint:

```powershell
Invoke-RestMethod http://localhost:3000/health
```

### 4. Configure Firebase for Flutter

In Firebase Console:

1. Enable **Authentication > Sign-in method > Email/Password**.
2. Create a Firestore database.
3. Register the Android app with package ID `com.fintrack.fintrack_mobile`.
4. Generate FlutterFire configuration from `mobile/` when using your own Firebase project:

```powershell
Push-Location mobile
flutterfire configure
Pop-Location
```

Flutter client configuration such as `google-services.json` and `firebase_options.dart` contains project identifiers, not Firebase Admin private keys. Backend service-account credentials belong only in `backend/.env`.

Deploy the checked-in Firestore rules and composite index:

```powershell
Push-Location mobile
firebase login
firebase deploy --only "firestore:rules,firestore:indexes" --project <FIREBASE_PROJECT_ID>
Pop-Location
```

To create a finance tip manually, add a document to `finance_tips` with:

| Field | Type | Example |
| --- | --- | --- |
| `title` | string | `Review weekly spending` |
| `content` | string | `Check your largest category each week.` |
| `isActive` | boolean | `true` |
| `createdAt` | timestamp | Current date and time |

### 5. Install mobile dependencies

```powershell
Push-Location mobile
flutter pub get
flutter analyze
flutter test
Pop-Location
```

## Run on Android Emulator

Start the backend with its default `HOST=127.0.0.1`, then run:

```powershell
cd mobile
flutter devices
flutter run -d <EMULATOR_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Android Emulator uses `10.0.2.2` to reach the host machine. `localhost` inside the emulator points back to the emulator itself.

## Run on a Physical Android Device

Connect the PC and phone to the same private network. Start the backend so it accepts LAN traffic:

```powershell
cd backend
$env:HOST="0.0.0.0"
npm run dev
```

Find the PC's LAN IPv4 address with `ipconfig`, then confirm `http://<PC_LAN_IP>:3000/health` opens in the phone browser.

After connecting the phone through USB debugging or Android Wireless Debugging:

```powershell
cd mobile
adb devices
flutter devices
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

The debug Android manifest allows local cleartext HTTP. Release builds do not broadly enable cleartext traffic and should use HTTPS.

For wireless pairing troubleshooting and Android-specific setup, see [mobile/README.md](mobile/README.md).

## API Summary

Public routes:

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/health` | API health check |

Protected routes use the `/api/v1` prefix:

| Area | Routes |
| --- | --- |
| Authentication | `POST /auth/sync` |
| Current user | `GET`, `PATCH`, `DELETE /users/me` |
| Wallets | `GET`, `POST /wallets`; `GET`, `PATCH`, `DELETE /wallets/:id` |
| Categories | `GET`, `POST /categories`; `PATCH`, `DELETE /categories/:id` |
| Transactions | `GET`, `POST /transactions`; `GET`, `PATCH`, `DELETE /transactions/:id` |
| Budgets | `GET`, `POST /budgets`; `PATCH`, `DELETE /budgets/:id` |
| Dashboard | `GET /dashboard/summary?month=&year=` |

See [docs/API_SPEC.MD](docs/API_SPEC.MD) for request and response details.

## Screenshots

Real device captures are intentionally not committed yet. Before using this repository as a final portfolio case study, add screenshots for:

| Screen | Suggested capture |
| --- | --- |
| Authentication | Welcome, login, and registration states |
| Dashboard | Summary cards, expense chart, budget preview, recent activity |
| Wallets | Wallet list and formatted balance form |
| Categories | Income/expense tabs and icon/color picker |
| Transactions | Filtered list and transaction form |
| Budgets | Monthly progress and over-budget state |
| Profile | Account navigation and deletion confirmation |

Store sanitized images under `docs/screenshots/`; do not include real email addresses, tokens, account balances, Firebase identifiers, or service credentials.

## Portfolio Case Study

### Problem

Personal finance data requires stronger consistency than a simple CRUD demo. Balances, category ownership, and budget usage must agree after transaction creation, editing, and deletion.

### Engineering Approach

- Kept financial entities in PostgreSQL and used Prisma transactions to reverse and reapply wallet effects safely.
- Used Firebase for identity while maintaining an application user record in PostgreSQL.
- Introduced Firestore only where realtime, semi-structured content adds value.
- Structured Flutter by feature and kept HTTP/Firestore queries out of widgets.
- Made local Android networking configurable through `--dart-define` instead of hardcoded environment URLs.

### Current Result

The MVP supports the complete manual flow from registration to wallet/category setup, transactions, budgets, dashboard reporting, realtime activity, and account deletion. Static analysis, compilation, Prisma validation, and Flutter tests are tracked in [docs/MVP_QA_CHECKLIST.md](docs/MVP_QA_CHECKLIST.md). Production operations and wider device coverage are intentionally still open.

## Future Improvements

- Add backend unit, integration, and API contract tests.
- Add CI/CD for linting, tests, builds, and migration checks.
- Publish an OpenAPI/Swagger document generated from the implemented routes.
- Add production HTTPS hosting, monitoring, structured logging, and rate limiting.
- Add accessibility review, localization, dark mode, and wider device testing.
- Add recurring transactions, savings goals, CSV/PDF export, and offline read caching.
- Add release signing and distribute an Android test build.

## Documentation

- [Documentation index](docs/README.md)
- [Product requirements](docs/PRD.md)
- [API specification](docs/API_SPEC.MD)
- [Technical requirements](docs/TECHNICAL_REQUIRMENTS.md)
- [Development plan](docs/DEVELOPMENT_PLAN.md)
- [MVP QA checklist](docs/MVP_QA_CHECKLIST.md)
