# FinTrack MVP QA Checklist

Use this checklist before an MVP demo, release candidate, or portfolio handoff. Automated checks should pass from a clean checkout; manual checks require configured Firebase projects, PostgreSQL, and an Android device or emulator.

Latest QA run: 2026-06-29. All automated checks pass. Prisma Client generation was rerun successfully after stopping the backend processes that held the Windows query-engine DLL lock.

## Automated Backend Checks

- [x] Installed packages satisfy `backend/package-lock.json` (`npm ls --depth=0`).
- [x] TypeScript type checking passes (`npm run typecheck`).
- [x] Production compilation passes (`npm run build`).
- [x] Prisma Client generation passes (`npm run prisma:generate`).
- [x] Prisma schema validation passes (`npx prisma validate`).
- [x] Every API route is mounted under the intended `/health` or `/api/v1` prefix.
- [x] Every non-health endpoint uses Firebase Admin authentication.
- [x] Request identity comes from the verified Firebase token, not request `userId` values.
- [x] No backend environment file, service-account private key, or credential artifact is tracked.

## Automated Mobile Checks

- [x] Flutter dependencies resolve (`flutter pub get`).
- [x] Static analysis passes (`flutter analyze`).
- [x] Flutter tests pass (`flutter test`).
- [x] Every `go_router` navigation target has a registered route.
- [x] Firebase initializes before `runApp` with generated FlutterFire options.
- [x] `API_BASE_URL` comes from `--dart-define` and has the documented emulator default.
- [x] Dio attaches the current Firebase ID token as a Bearer token.
- [x] Flutter does not write wallet, category, transaction, or budget data to Firestore.
- [x] Firestore client writes are denied by the checked-in security rules.

## Automated Documentation Checks

- [x] Root, backend, and mobile READMEs match the current setup.
- [x] Local PostgreSQL host access consistently uses port `5433`.
- [x] Android emulator and physical-device `API_BASE_URL` examples are present.
- [x] Firebase client/Admin configuration and Firestore deployment are documented.
- [x] Docker, Prisma, backend, emulator, and physical-device commands are documented.

## Manual Environment Checks

- [ ] `docker compose up -d` starts PostgreSQL and `docker compose ps` reports healthy/running state.
- [ ] Prisma migrations apply to an empty local database.
- [ ] `GET /health` succeeds from Windows, the emulator, and a physical device as applicable.
- [ ] Debug Android builds can reach local HTTP; release configuration uses HTTPS.
- [ ] No secret values appear in Git status, commits, screenshots, or logs.

## Manual Authentication Checks

- [ ] Registration creates a Firebase Auth account and synchronizes the PostgreSQL user.
- [ ] New-user synchronization creates default income and expense categories once.
- [ ] Login, restored session, protected-route guard, invalid token handling, and logout work.
- [ ] One user cannot access another user's REST or Firestore data.

## Manual Financial Flow Checks

- [ ] Wallet create, list, edit, and archive work with formatted IDR balances.
- [ ] Category create, filter, edit, and guarded delete work.
- [ ] Transaction create, edit, and delete apply and reverse wallet balances correctly.
- [ ] Transaction category type must match income/expense type.
- [ ] Budget create, edit, duplicate rejection, delete, and usage calculations work.
- [ ] Dashboard totals, monthly count, category breakdown, budgets, and recent transactions refresh after mutations.
- [ ] Date filters include the selected end date and exclude the following day.

## Manual Firestore Checks

- [ ] Transaction, wallet-create, and budget create/update summary events appear in realtime.
- [ ] Activity documents contain summaries only, not complete financial records.
- [ ] The user can read only `users/{firebaseUid}/activity_feed` for their own UID.
- [ ] Active finance tips load newest first; inactive or missing tips use the expected behavior.

## Release Decision

- [x] All automated checks pass.
- [ ] All critical manual flows pass on at least one Android emulator.
- [ ] Network/auth flows pass on at least one physical Android device.
- [ ] Known limitations are documented and accepted before release.
