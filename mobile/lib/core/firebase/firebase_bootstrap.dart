import 'package:firebase_core/firebase_core.dart';

const _enableFirebase = bool.fromEnvironment('ENABLE_FIREBASE');

Future<void> initializeFirebaseIfEnabled() async {
  if (!_enableFirebase) {
    return;
  }

  await Firebase.initializeApp();
}
