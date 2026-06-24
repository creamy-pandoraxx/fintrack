# FinTrack Mobile

Flutter mobile app placeholder for FinTrack.

## Local Development

```bash
flutter pub get
flutter analyze
flutter run
```

Firebase packages are installed, but platform Firebase configuration is intentionally deferred to the auth milestone. Until `firebase_options.dart` and native Firebase config files are added, run without Firebase initialization. After FlutterFire setup, run with:

```bash
flutter run --dart-define=ENABLE_FIREBASE=true
```
