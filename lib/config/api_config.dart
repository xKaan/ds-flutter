// lib/config/api_config.dart

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _overrideUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) return _overrideUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static Uri get loginUri => Uri.parse('$baseUrl/login.php');

  static const Duration timeout = Duration(seconds: 10);
}
