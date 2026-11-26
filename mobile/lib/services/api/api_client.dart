import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import '../localization_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  /// Base API candidate endpoints.
  static const List<String> candidateUrls = [
    'http://127.0.0.1:8000/api',
    'http://192.168.31.118:8000/api',
    'http://10.0.2.2:8000/api',
    'http://localhost:8000/api',
    // 'http://13.211.227.174/backend/public/api'
  ];

  static String _baseUrl = 'http://127.0.0.1:8000/api';

  static String get baseUrl => _baseUrl;

  static set baseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Build standard headers including Laravel Sanctum Bearer token and active language header.
  static Map<String, String> buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'lang': LocalizationService.currentLanguage,
      'X-Locale': LocalizationService.currentLanguage,
      'Accept-Language': LocalizationService.currentLanguage,
    };
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// Ping the API server to verify connectivity.
  static Future<bool> testConnection([String? testUrl]) async {
    final target = (testUrl ?? _baseUrl).replaceAll(RegExp(r'/+$'), '');
    try {
      final res = await http.get(
        Uri.parse('$target/cities?q=Pune&limit=1'),
        headers: buildHeaders(),
      ).timeout(const Duration(seconds: 3));

      // 200 (authenticated) or 401 (server reachable with Sanctum auth) confirms backend is up
      if (res.statusCode == 200 || res.statusCode == 401) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Automatically detect the working backend server URL from candidate endpoints.
  static Future<String> autoDetectWorkingUrl() async {
    for (final url in candidateUrls) {
      if (await testConnection(url)) {
        _baseUrl = url;
        return url;
      }
    }
    return _baseUrl;
  }

  /// Helper for GET requests with auto URL fallback on connection loss.
  static Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final pathClean = path.startsWith('/') ? path : '/$path';
    Uri uri = Uri.parse('$_baseUrl$pathClean');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      return await http.get(uri, headers: buildHeaders()).timeout(timeout);
    } on SocketException catch (_) {
      final detected = await autoDetectWorkingUrl();
      if (detected != _baseUrl) {
        final retryUri = Uri.parse('$_baseUrl$pathClean').replace(queryParameters: queryParams);
        return await http.get(retryUri, headers: buildHeaders()).timeout(timeout);
      }
      throw ApiException('सर्व्हरशी संपर्क होऊ शकला नाही. कृपया सर्व्हर चालू असल्याची खात्री करा.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('सर्व्हर विनंती अयशस्वी: $e');
    }
  }

  /// Helper for POST requests with auto URL fallback on connection loss.
  static Future<http.Response> post(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final pathClean = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$pathClean');
    final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

    try {
      return await http.post(
        uri,
        headers: buildHeaders(extraHeaders),
        body: encodedBody,
      ).timeout(timeout);
    } on SocketException catch (_) {
      final detected = await autoDetectWorkingUrl();
      if (detected != _baseUrl) {
        final retryUri = Uri.parse('$_baseUrl$pathClean');
        return await http.post(
          retryUri,
          headers: buildHeaders(extraHeaders),
          body: encodedBody,
        ).timeout(timeout);
      }
      throw ApiException('सर्व्हरशी संपर्क होऊ शकला नाही. कृपया सर्व्हर चालू असल्याची खात्री करा.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('सर्व्हर विनंती अयशस्वी: $e');
    }
  }
}
