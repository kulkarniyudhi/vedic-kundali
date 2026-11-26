import 'dart:convert';
import '../auth_service.dart';
import 'api_client.dart';

class AuthApi {
  /// Request an OTP sent to email for Signup.
  static Future<Map<String, dynamic>> sendSignupOtp({
    required String email,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
    };

    final res = await ApiClient.post(
      '/signup/send-otp',
      body: payload,
      timeout: const Duration(seconds: 12),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      String msg = data['message'] ?? 'OTP पाठवण्यात अडचण आली (${res.statusCode})';
      if (data['errors'] is Map) {
        final errList = (data['errors'] as Map).values.expand((v) => (v as List)).toList();
        if (errList.isNotEmpty) {
          msg = errList.join('\n');
        }
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  /// Request an OTP sent to email for Login.
  static Future<Map<String, dynamic>> sendLoginOtp({
    required String email,
    String? password,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final res = await ApiClient.post(
      '/login/send-otp',
      body: payload,
      timeout: const Duration(seconds: 12),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      String msg = data['message'] ?? 'OTP पाठवण्यात अडचण आली (${res.statusCode})';
      if (data['errors'] is Map) {
        final errList = (data['errors'] as Map).values.expand((v) => (v as List)).toList();
        if (errList.isNotEmpty) {
          msg = errList.join('\n');
        }
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  /// Authenticate user directly via email and password and persist Sanctum token.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    final res = await ApiClient.post(
      '/login',
      body: payload,
      timeout: const Duration(seconds: 12),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true && data['token'] != null) {
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      await AuthService.login(
        token: token,
        name: user['name']?.toString(),
        email: user['email']?.toString(),
        phone: user['phone']?.toString(),
      );
      return data;
    } else {
      String msg = data['message'] ?? 'लॉगिन अयशस्वी झाले (${res.statusCode})';
      if (data['errors'] is Map) {
        final errList = (data['errors'] as Map).values.expand((v) => (v as List)).toList();
        if (errList.isNotEmpty) {
          msg = errList.join('\n');
        }
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  /// Register new user directly without OTP verification.
  /// Mobile phone number is optional.
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    };

    final res = await ApiClient.post(
      '/signup',
      body: payload,
      timeout: const Duration(seconds: 12),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 201 && data['success'] == true) {
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      await AuthService.login(
        token: token,
        name: user['name']?.toString(),
        email: user['email']?.toString(),
        phone: user['phone']?.toString(),
      );
      return data;
    } else {
      String msg = data['message'] ?? 'नोंदणी अयशस्वी झाली (${res.statusCode})';
      if (data['errors'] is Map) {
        final errList = (data['errors'] as Map).values.expand((v) => (v as List)).toList();
        if (errList.isNotEmpty) {
          msg = errList.join('\n');
        }
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  /// Revoke current Sanctum access token and log out locally.
  static Future<void> logout() async {
    try {
      if (AuthService.token != null && AuthService.token!.isNotEmpty) {
        await ApiClient.post(
          '/logout',
          timeout: const Duration(seconds: 5),
        );
      }
    } catch (_) {}
    await AuthService.logout();
  }
}
