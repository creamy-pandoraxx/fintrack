# FinTrack Mobile

Flutter mobile app for FinTrack.

The current app includes Firebase authentication, guarded application routes, dashboard summaries, wallet/category/transaction/budget management, a realtime activity feed, and dynamic finance tips. Financial source data is read and written only through the backend REST API.

## Local Development

Install dependencies and run analysis:

```bash
flutter pub get
flutter analyze
```

The API base URL is configured with `--dart-define=API_BASE_URL=...`.
If no value is provided, the development default is:

```txt
http://10.0.2.2:3000/api/v1
```

Use that default for the Android emulator when the backend is running on the same machine.

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Physical Android device on the same Wi-Fi network:

```bash
flutter run --dart-define=API_BASE_URL=http://<PC_LAN_IP>:3000/api/v1
```

For a physical device, run the backend with `HOST=0.0.0.0` so it accepts LAN connections. Keep release builds on HTTPS or a production API host.

Debug Android builds allow cleartext HTTP for local development only. Release builds do not enable broad cleartext HTTP in the main Android manifest.

## Firebase Setup

Firebase packages and FlutterFire options are configured for Android and iOS. Backend Firebase Admin service-account secrets must stay in `backend/.env` only and must never be added to Flutter.

Install the Firebase CLI, authenticate it, then deploy the checked-in activity-feed rules and finance-tip index:

```bash
firebase login
firebase deploy --only "firestore:rules,firestore:indexes" --project <FIREBASE_PROJECT_ID>
```

The rules allow signed-in users to read only their own `users/{firebaseUid}/activity_feed` documents. Flutter cannot write activity events; the backend Firebase Admin SDK creates summary-only events after transaction changes, wallet creation, and budget creation/update.

## Finance Tips

In Firestore Console, create a document with an automatic ID in the `finance_tips` collection and add:

| Field | Type | Example |
| --- | --- | --- |
| `title` | string | `Review weekly spending` |
| `content` | string | `Check your largest expense category each week.` |
| `isActive` | boolean | `true` |
| `createdAt` | timestamp | current date and time |

Only active tips are queried, ordered by `createdAt` descending. If Firebase is unavailable or no active document exists, the dashboard shows the built-in fallback tip.
