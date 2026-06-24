import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static void logDebugValues() {
    if (kDebugMode) {
      debugPrint('FinTrack API base URL: $apiBaseUrl');
    }
  }
}
