# FinTrack Mobile

Flutter mobile app for FinTrack.

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

Firebase packages and FlutterFire options are configured for Android and iOS. Backend Firebase Admin service-account secrets must stay in backend `.env` only and must never be added to Flutter.
