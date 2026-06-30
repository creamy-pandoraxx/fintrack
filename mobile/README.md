# FinTrack Mobile

FinTrack Mobile is the Flutter Android client for the FinTrack personal finance MVP. It uses feature-based organization, Riverpod state management, Dio for the REST API, go_router for guarded navigation, Firebase Authentication, and Firestore realtime streams.

Financial writes always go through the backend. Flutter never writes wallet, category, transaction, or budget source data directly to PostgreSQL or Firestore.

## Implemented Screens

- Splash, welcome, login, and registration
- Dashboard with monthly summary, expense chart, budget preview, finance tip, recent transactions, and activity preview
- Wallet list/add/edit/archive
- Category income/expense tabs, add/edit/delete, icon picker, and color palette
- Transaction list/add/edit/detail/delete with filters
- Budget list/add/edit/delete with monthly selection and progress visualization
- Realtime activity feed
- Profile navigation, logout, and account deletion confirmation

## Structure

```text
lib/
|-- app/
|   |-- constants/       # Shared design values
|   |-- router/          # go_router routes and auth guard
|   `-- theme/           # Material theme
|-- core/
|   |-- config/          # API_BASE_URL configuration
|   |-- firebase/        # Firebase initialization
|   |-- network/         # Dio client, interceptor, API errors
|   |-- utils/           # Money, date, category visual helpers
|   `-- widgets/         # Reusable loading/error/visual widgets
`-- features/
    |-- auth/
    |-- dashboard/
    |-- wallets/
    |-- categories/
    |-- transactions/
    |-- budgets/
    |-- activity/
    |-- finance_tips/
    `-- profile/
```

Each feature separates data access, domain models, and presentation where appropriate. Repositories own Dio or Firestore calls; Riverpod controllers/providers expose state; widgets focus on rendering and user interaction.

## Prerequisites

- Flutter SDK and Dart
- Android Studio/SDK with an emulator or Android 11+ physical device
- A running FinTrack backend
- A Firebase project configured for the app
- Firebase CLI and FlutterFire CLI when regenerating configuration

## Install and Verify

```powershell
cd mobile
flutter doctor
flutter pub get
flutter analyze
flutter test
```

## API Base URL

The API endpoint is supplied at build/run time:

```dart
const String.fromEnvironment('API_BASE_URL')
```

The safe development default is:

```text
http://10.0.2.2:3000/api/v1
```

That default is intended for an Android emulator. Always pass an explicit value for a physical device or deployed environment.

The base URL is logged only in debug mode. Authentication tokens are not logged or manually persisted by the app.

## Firebase Setup

1. Create or select a Firebase project.
2. Enable **Authentication > Sign-in method > Email/Password**.
3. Create a Firestore database.
4. Register Android package `com.fintrack.fintrack_mobile`.
5. Install the CLIs if needed:

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

6. From `mobile/`, generate configuration for your Firebase project:

```powershell
firebase login
flutterfire configure
```

Firebase must initialize before `runApp`; the generated `DefaultFirebaseOptions.currentPlatform` is used by the current bootstrap.

Flutter Firebase configuration contains client project metadata. Do not put the Firebase Admin service-account email/private key or service-account JSON in this app. Admin credentials belong only in `backend/.env`.

### Firestore Rules and Indexes

Deploy from `mobile/`, where `firebase.json` is located:

```powershell
firebase deploy --only "firestore:rules,firestore:indexes" --project <FIREBASE_PROJECT_ID>
```

The checked-in rules allow:

- an authenticated user to read only `users/{theirUid}/activity_feed`;
- an authenticated user to read active `finance_tips`;
- no Flutter client writes to either collection.

Activity summaries are written by the backend Firebase Admin SDK. The finance-tip query uses `isActive == true` and `createdAt` descending, backed by the checked-in composite index.

To add a finance tip in Firestore Console, create an auto-ID document in `finance_tips`:

| Field | Type | Required value |
| --- | --- | --- |
| `title` | string | Tip heading |
| `content` | string | Short tip text |
| `isActive` | boolean | `true` to display |
| `createdAt` | timestamp | Creation date/time |

The dashboard uses a local fallback if Firestore is unavailable or no active tip exists.

## Run on Android Emulator

1. Start an Android emulator from Android Studio Device Manager.
2. Confirm Flutter recognizes it:

```powershell
flutter devices
```

3. Start the backend on its default `127.0.0.1:3000` listener.
4. Run Flutter:

```powershell
flutter run -d <EMULATOR_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Use the actual ID reported by `flutter devices`. If an emulator is marked unsupported, update its Android system image and the local Flutter/Android toolchain.

## Run on a Physical Android Device

The PC and phone must be on the same trusted Wi-Fi network. Start the backend from `backend/` with:

```powershell
$env:HOST="0.0.0.0"
npm run dev
```

Find the PC LAN address:

```powershell
ipconfig
```

Confirm `http://<PC_LAN_IP>:3000/health` opens in the phone browser before running Flutter.

### USB debugging

Enable Developer options and USB debugging, connect the cable, approve the phone prompt, then run:

```powershell
adb devices
flutter devices
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

### Wireless debugging

On Android 11+, open **Developer options > Wireless debugging > Pair device with pairing code**. The pairing port shown in that popup differs from the connection port on the main Wireless debugging page.

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb kill-server
& $adb start-server
& $adb pair <PHONE_IP>:<PAIRING_PORT>
& $adb connect <PHONE_IP>:<CONNECTION_PORT>
& $adb devices -l
```

Keep the pairing-code popup open while running `adb pair`; its port expires when the popup closes. If discovery fails, disable VPNs, use a private network profile, check Windows Firewall, and avoid Wi-Fi networks with client isolation.

Then run:

```powershell
flutter run -d <PHONE_IP>:<CONNECTION_PORT> --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

## Android Network Security

The main Android manifest includes Internet permission. Cleartext HTTP is allowed only by the debug manifest for local development. Release builds do not broadly permit HTTP; use an HTTPS backend URL:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

## Authentication Behavior

1. Firebase Auth performs email/password registration or login.
2. Dio requests the current Firebase ID token for protected calls.
3. The interceptor adds `Authorization: Bearer <token>`.
4. The app calls `/auth/sync` after registration/login and when restoring a session.
5. go_router redirects unauthenticated users away from protected routes.
6. Logout clears Firebase state; account deletion calls the backend before clearing the local session.

## Troubleshooting

### Backend is unreachable

- Emulator: use `10.0.2.2`, not `localhost`.
- Physical device: use the PC LAN IPv4 address and backend `HOST=0.0.0.0`.
- Test `/health` in the phone browser.
- Allow `node.exe` or TCP port `3000` on Windows Private networks only.

### Firebase is not initialized

- Confirm `lib/firebase_options.dart` and `android/app/google-services.json` exist.
- Regenerate them with `flutterfire configure` for the same Firebase project used by the backend.
- Run `flutter clean` and `flutter pub get` after changing configuration.

### Protected API returns 401

- Sign out and sign back in to refresh credentials.
- Confirm mobile and backend Firebase project IDs match.
- Confirm the backend private key keeps escaped `\n` newlines.

### Firestore permission denied

- Deploy both rules and indexes.
- Confirm the user is signed in and only reads their own activity path.
- Confirm backend Admin and Flutter use the same Firebase project.
- Do not add client write permissions for financial/activity records.

## Current Limitations

- Android is the primary tested platform; iOS configuration exists but is not the documented MVP target.
- No offline-first financial mutation queue.
- No push notifications or background synchronization.
- No release distribution pipeline or automated screenshot tests yet.

See the [root README](../README.md) for the complete system architecture and [API specification](../docs/API_SPEC.MD) for backend contracts.
