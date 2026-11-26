import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyAuthToken = 'auth_token';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPhone = 'user_phone';

  static bool _isLoggedIn = false;
  static String? _token;
  static String _userName = '';
  static String _userEmail = '';
  static String _userPhone = '';

  static bool get isLoggedIn => _isLoggedIn && (_token != null && _token!.isNotEmpty);
  static String? get token => _token;
  static String get userName => _userName;
  static String get userEmail => _userEmail;
  static String get userPhone => _userPhone;

  /// Load persisted session from SharedPreferences on app startup.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_keyAuthToken);
      _isLoggedIn = (prefs.getBool(_keyIsLoggedIn) ?? false) && (_token != null && _token!.isNotEmpty);
      _userName = prefs.getString(_keyUserName) ?? '';
      _userEmail = prefs.getString(_keyUserEmail) ?? '';
      _userPhone = prefs.getString(_keyUserPhone) ?? '';
    } catch (_) {
      // Memory fallback if persistent storage is unavailable
    }
  }

  /// Save login session with Sanctum token.
  static Future<void> login({
    required String token,
    String? email,
    String? name,
    String? phone,
  }) async {
    _token = token;
    _isLoggedIn = true;
    _userEmail = email ?? '';
    _userName = name ?? '';
    _userPhone = phone ?? '';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyAuthToken, token);
      await prefs.setString(_keyUserEmail, _userEmail);
      await prefs.setString(_keyUserName, _userName);
      await prefs.setString(_keyUserPhone, _userPhone);
    } catch (_) {}
  }

  /// Clear login session and return to Login screen.
  static Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserPhone);
    } catch (_) {}
  }
}
