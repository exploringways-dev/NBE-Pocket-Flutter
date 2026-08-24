import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    double? income,
  }) async {
    final response = await _api.post('/Auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      if (income != null) 'income': income,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      // Safely handle API registration errors
      if (response.body.isEmpty) {
        throw Exception('Registration failed (Status ${response.statusCode})');
      }
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['title'] ?? 'Registration failed');
      } catch (_) {
        throw Exception(response.body); // Fallback if API sent plain text
      }
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/Auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Login successful but no data was returned by the API.');
      }

      try {
        // Try to decode as JSON
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
        }
        return token;
      } catch (e) {
        // Fallback: If your C# API returned just a raw JWT string instead of JSON
        final token = response.body.trim();
        await _storage.write(key: 'jwt_token', value: token);
        return token;
      }
    } else {
      // Safely handle API login errors (like 401 Unauthorized)
      if (response.body.isEmpty) {
        throw Exception('Login failed (Status ${response.statusCode})');
      }
      
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['title'] ?? 'Login failed');
      } catch (_) {
        throw Exception(response.body); // Fallback if API sent plain text error
      }
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}