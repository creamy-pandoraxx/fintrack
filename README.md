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

## Android Local Setup

The commands below use PowerShell. Before the first run, create the backend environment file and fill in the Firebase Admin values from your service account:

```powershell
if (-not (Test-Path backend\.env)) {
    Copy-Item backend\.env.example backend\.env
}
```

Keep `backend/.env` private. The local database URL should remain:

```txt
postgresql://fintrack:fintrack_password@localhost:5433/fintrack_db?schema=public
```

### 1. Start PostgreSQL

From the repository root:

```powershell
docker compose up -d
docker compose ps
```

PostgreSQL uses host port `5433`; port `5432` remains internal to the container.

### 2. Install And Migrate The Backend

Run this after the first checkout and whenever Prisma migrations change:

```powershell
cd backend
npm install
npx prisma migrate dev
npm run prisma:generate
```

### 3. Run With An Android Emulator

Terminal 1, from `backend/`:

```powershell
npm run dev
```

The default `HOST=127.0.0.1` works with the Android emulator alias. Verify the backend from Windows:

```powershell
Invoke-RestMethod http://localhost:3000/health
```

Terminal 2:

```powershell
cd mobile
flutter pub get
flutter devices
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Replace `emulator-5554` with the device ID shown by `flutter devices`. Android emulator traffic must use `10.0.2.2`, not `localhost`, to reach the Windows host.

### 4. Run With A Physical Android Device

Connect the phone and PC to the same private Wi-Fi network, enable USB debugging, and find the PC IPv4 address with `ipconfig`.

Terminal 1, from `backend/`:

```powershell
$env:HOST="0.0.0.0"
npm run dev
```

Terminal 2:

```powershell
cd mobile
adb devices
flutter devices
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

Confirm `http://<PC_LAN_IP>:3000/health` opens in the phone browser before starting Flutter. `PORT` remains configurable in `backend/.env` or the process environment; update `API_BASE_URL` when using a non-default port.

### Android Network Security

The Android app has Internet permission in the main manifest. Local cleartext HTTP is enabled only by `mobile/android/app/src/debug/AndroidManifest.xml`; release builds do not broadly allow cleartext traffic. Use an HTTPS API URL for release builds:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

## Firebase And Firestore

Flutter Firebase client configuration is stored under `mobile/`. Firebase Admin service-account values belong only in `backend/.env` and must not be committed.

Deploy the activity-feed rules and finance-tip index from `mobile/`:

```bash
cd mobile
firebase deploy --only "firestore:rules,firestore:indexes" --project <FIREBASE_PROJECT_ID>
```

To add a finance tip in Firestore Console, create a document in `finance_tips` with `title` (string), `content` (string), `isActive` (boolean), and `createdAt` (timestamp). The dashboard reads active tips newest first and uses a local fallback when none are available.

## Troubleshooting

### Device Cannot Connect To Backend

- Verify the backend terminal says `FinTrack API running on 0.0.0.0:3000` for a physical device.
- Use `10.0.2.2` for the Android emulator and the PC LAN IPv4 address for a physical device. Never use `localhost` from Android.
- Open `http://<PC_LAN_IP>:3000/health` in the phone browser. If it fails there, the problem is network access rather than Flutter.
- Keep the phone and PC on the same private network and temporarily disable VPNs or guest-network isolation.
- Local HTTP works only in debug builds. Release builds require HTTPS unless a narrowly scoped production policy is added.

### Firebase Not Initialized

- Confirm `mobile/lib/firebase_options.dart` and `mobile/android/app/google-services.json` exist and belong to the same Firebase project.
- If configuration is missing or stale, run `flutterfire configure` from `mobile/`, then run `flutter clean` and `flutter pub get`.
- Do not place Firebase Admin service-account credentials in Flutter. Those values belong only in `backend/.env`.

### Invalid Or Expired Firebase Token

- Sign out and sign in again so Firebase Auth refreshes the ID token.
- Confirm the Flutter Firebase project matches `FIREBASE_PROJECT_ID` and the service account configured in `backend/.env`.
- Confirm `FIREBASE_PRIVATE_KEY` preserves escaped newlines as `\n` and that the device clock is correct.
- A protected request must send `Authorization: Bearer <firebase_id_token>`; the Dio interceptor adds this for signed-in users.

### Firestore Permission Denied

- Confirm the user is signed in and reads only `users/{firebaseUid}/activity_feed` for their own Firebase UID.
- Deploy the checked-in rules and indexes from `mobile/` using the command above.
- Confirm the mobile Firebase project and backend Firebase Admin project are the same.
- Client writes are intentionally denied. Activity events must be written by the backend.

### PostgreSQL Connection Refused

- Run `docker compose ps` and confirm `fintrack-postgres` is running.
- Test the mapped port with `Test-NetConnection localhost -Port 5433`.
- Confirm `backend/.env` uses port `5433`, not the container-only port `5432`.
- Inspect startup failures with `docker compose logs postgres`.

### Windows Firewall Blocks Backend

- Allow `node.exe` on Private networks when Windows prompts, or create a port rule from an elevated PowerShell terminal:

```powershell
New-NetFirewallRule -DisplayName "FinTrack Backend 3000" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3000 -Profile Private
```

Do not open the port on the Public profile. Retest the health endpoint from the phone after adding the rule.

## Documentation

Project documentation lives in `docs/`:

- `API_SPEC.MD`
- `DEVELOPMENT_PLAN.md`
- `PRD.md`
- `TECHNICAL_REQUIRMENTS.md`
