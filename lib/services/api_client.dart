import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();

  String get baseUrl {
    if (kIsWeb || Platform.isWindows) {
      return 'https://192.168.56.1/NBEPocketAPI/api';
    } else if (Platform.isAndroid) {
      return 'https://192.168.56.1/NBEPocketAPI/api';
    } else {
      return 'https://192.168.56.1/NBEPocketAPI/api';
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }
}
