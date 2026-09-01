import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'api_exception.dart';

class RegistrationResult {
  const RegistrationResult(this.message);
  final String message;
  bool get verificationLikelyRequired =>
      message.toLowerCase().contains('verify');
}

class AuthService {
  final ApiClient _api = ApiClient();
  static const _storage = FlutterSecureStorage();

  Future<RegistrationResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Added /api/ here
    final data = await _api.post('/api/Auth/register', authenticated: false, body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return RegistrationResult(data is Map && data['message'] is String
        ? data['message'] as String
        : 'Registration successful.');
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Added /api/ here
    final data = await _api.post('/api/Auth/login', authenticated: false, body: {
      'email': email,
      'password': password,
    });

    if (data is! Map<String, dynamic>) {
      throw const ApiException(
          'The server returned an invalid login response.');
    }
    await ApiClient.saveSession(data);
  }

  Future<String> verifyEmail(
      {required String email, required String token}) async {
    final query = Uri(queryParameters: {'email': email, 'token': token}).query;
    // Added /api/ here
    final data =
        await _api.get('/api/Auth/verify-email?$query', authenticated: false);
    return data is Map && data['message'] is String
        ? data['message'] as String
        : 'Email verified.';
  }

  Future<String> forgotPassword(String email) async {
    // Added /api/ here
    final data = await _api.post('/api/Auth/forgot-password',
        authenticated: false, body: {'email': email});
    return data is Map && data['message'] is String
        ? data['message'] as String
        : 'Reset link sent.';
  }

  Future<String> resetPassword(
      {required String email,
      required String token,
      required String newPassword}) async {
    // Added /api/ here
    final data =
        await _api.post('/api/Auth/reset-password', authenticated: false, body: {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
    return data is Map && data['message'] is String
        ? data['message'] as String
        : 'Password reset.';
  }

  Future<bool> restoreSession() async {
    final access = await _storage.read(key: ApiClient.accessTokenKey);
    final refresh = await _storage.read(key: ApiClient.refreshTokenKey);
    if (access == null || refresh == null) return false;
    try {
      // Change this line to include /api/
      await _api.get('/api/Users/profile'); 
      return true;
    } catch (_) {
      await ApiClient.clearSession();
      return false;
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.read(key: ApiClient.refreshTokenKey);
    if (refresh != null) {
      try {
        // Added /api/ here
        await _api.post('/api/Auth/revoke',
            authenticated: false, body: {'refreshToken': refresh});
      } catch (_) {
        // Local logout must complete even when the API is unreachable.
      }
    }
    await ApiClient.clearSession();
  }
}