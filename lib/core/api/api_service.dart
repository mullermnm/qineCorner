import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/api_error.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = ApiConfig.baseUrl;
  String? _token;

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString('auth_state');
    if (savedState != null) {
      final Map<String, dynamic> json = jsonDecode(savedState);
      _token = json['token'];
    }
  }

  void setAuthToken(String token) {
    _token = token;
  }

  void clearAuthToken() {
    _token = null;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    switch (statusCode) {
      case 401:
        throw ApiException('Unauthorized: ${body['message']}', statusCode: 401);
      case 403:
        throw ApiException('Forbidden: ${body['message']}', statusCode: 403);
      case 404:
        throw ApiException('Not Found: ${body['message']}', statusCode: 404);
      case 422:
        throw ApiException('Validation Error: ${body['message']}',
            statusCode: 422);
      case 500:
        throw ApiException('Server Error: ${body['message']}', statusCode: 500);
      default:
        throw ApiException(
            'Error: ${body['message'] ?? 'Unknown error occurred'}',
            statusCode: statusCode);
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    if (_token == null) {
      await initializeToken();
    }

    final uri = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) {
      await initializeToken();
    }

    final uri = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) {
      await initializeToken();
    }

    final uri = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    if (_token == null) {
      await initializeToken();
    }

    final uri = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required Map<String, String> files,
  }) async {
    if (_token == null) {
      await initializeToken();
    }

    final uri = Uri.parse(baseUrl + endpoint);
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..fields.addAll(fields);

    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<String> uploadMedia(String endpoint, File file) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'] as String;
      }
      throw ApiException(response.statusCode.toString());
    } catch (e) {
      throw ApiException('Failed to upload media: $e');
    }
  }
}
