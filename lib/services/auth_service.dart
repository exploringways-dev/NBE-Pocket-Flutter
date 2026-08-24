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
        final data = jsonDecode(response.body);
        
        // 1. Look for various common token keys (ASP.NET often capitalizes properties)
        final token = (data['token'] ?? data['Token'] ?? data['accessToken'])?.toString();
        
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          return token;
        } else {
          // 2. No more silent failures! This will show exactly what your backend returned in the red snackbar.
          throw Exception('No token found. Backend returned: $data');
        }
      } catch (e) {
        // Prevent our custom exception from being caught by the fallback below
        if (e.toString().contains('No token found')) rethrow;
        
        // Fallback: If your C# API returned just a raw JWT string instead of JSON
        final token = response.body.trim();
        await _storage.write(key: 'jwt_token', value: token);
        return token;
      }
    } else {
      if (response.body.isEmpty) {
        throw Exception('Login failed (Status ${response.statusCode})');
      }
      try {
        final error = jsonDecode(response.body);
        if (error['errors'] != null) {
          final firstError = error['errors'].values.first[0];
          throw Exception(firstError);
        }
        throw Exception(error['message'] ?? error['title'] ?? 'Login failed');
      } catch (e) {
         if (e is FormatException) throw Exception(response.body);
         rethrow;
      }
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}