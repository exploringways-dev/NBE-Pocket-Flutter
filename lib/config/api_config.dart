import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    // final configured = _configuredBaseUrl.trim();
    // if (configured.isNotEmpty) {
    //   return configured.replaceAll(RegExp(r'/$'), '');
    // }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://192.168.1.5/NBEPocketAPI';
    }

    // iOS Simulator, macOS, Windows, Linux, and local web development.
    return 'https://192.168.1.5/NBEPocketAPI';
  }

  static const Duration requestTimeout = Duration(seconds: 30);

  static void validate() {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('Invalid API_BASE_URL configuration.');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Release builds require an HTTPS API_BASE_URL.');
    }
  }
}
