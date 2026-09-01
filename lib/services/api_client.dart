import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const accessExpiryKey = 'access_token_expires_at';
  static const _storage = FlutterSecureStorage();
  final http.Client _client;
  Future<bool>? _refreshInFlight;

  Future<dynamic> get(String endpoint, {bool authenticated = true}) =>
      _send('GET', endpoint, authenticated: authenticated);
  Future<dynamic> post(String endpoint,
          {Map<String, dynamic>? body, bool authenticated = true}) =>
      _send('POST', endpoint, body: body, authenticated: authenticated);
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) =>
      _send('PUT', endpoint, body: body, authenticated: true);
  Future<dynamic> delete(String endpoint) =>
      _send('DELETE', endpoint, authenticated: true);

  Future<dynamic> _send(String method, String endpoint,
      {Map<String, dynamic>? body,
      required bool authenticated,
      bool retryAfterRefresh = true}) async {
    final suffix = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('${ApiConfig.baseUrl}$suffix');
    final token =
        authenticated ? await _storage.read(key: accessTokenKey) : null;
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if (kDebugMode) debugPrint('API $method ${uri.path}');

    try {
      late http.Response response;
      final encoded = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConfig.requestTimeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encoded)
              .timeout(ApiConfig.requestTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encoded)
              .timeout(ApiConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(ApiConfig.requestTimeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 401 &&
          authenticated &&
          retryAfterRefresh &&
          await _refreshAccessToken()) {
        return await _send(method, endpoint,
            body: body, authenticated: true, retryAfterRefresh: false);
      }
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on SocketException {
      throw const ApiException(
          'Cannot reach the server. Check your connection.');
    } on http.ClientException {
      throw const ApiException(
          'Cannot reach the server. Check your connection.');
    }
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw const ApiException(
              'The server returned an unexpected response.');
        }
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final message = _messageFrom(data) ?? _defaultMessage(response.statusCode);
    final lower = message.toLowerCase();
    throw ApiException(message,
        statusCode: response.statusCode,
        requiresVerification: response.statusCode == 401 &&
            lower.contains('verify') &&
            lower.contains('email'));
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'] ?? data['title'];
    if (message is String && message.isNotEmpty) return message;
    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  String _defaultMessage(int status) => switch (status) {
        400 => 'Please check the information you entered.',
        401 => 'Your session is invalid or has expired.',
        403 => 'You do not have permission to perform this action.',
        404 => 'The requested resource was not found.',
        409 => 'This information already exists.',
        422 => 'Some information is invalid.',
        429 => 'Too many attempts. Please wait and try again.',
        _ when status >= 500 =>
          'The server is unavailable. Please try again later.',
        _ => 'The request failed (status $status).',
      };

  Future<bool> _refreshAccessToken() async {
    final current = _refreshInFlight;
    if (current != null) return current;
    final future = _performRefresh();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _storage.read(key: refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final data = await post('/Auth/refresh',
          body: {'refreshToken': refreshToken}, authenticated: false);
      if (data is! Map<String, dynamic>) return false;
      await saveSession(data);
      return true;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  static Future<void> saveSession(Map<String, dynamic> data) async {
    final access = data['accessToken']?.toString();
    final refresh = data['refreshToken']?.toString();
    final expiry = data['accessTokenExpiresAt']?.toString();
    if (access == null || refresh == null || expiry == null) {
      throw const ApiException(
          'The login response is missing session information.');
    }
    await _storage.write(key: accessTokenKey, value: access);
    await _storage.write(key: refreshTokenKey, value: refresh);
    await _storage.write(key: accessExpiryKey, value: expiry);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: accessExpiryKey);
    await _storage.delete(key: 'jwt_token');
  }
}
