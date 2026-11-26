import 'dart:io';
import 'package:open_filex/open_filex.dart';
import '../models/astrology_models.dart';
import 'api/api.dart';

export 'api/api.dart';

/// Facade maintaining backward compatibility while delegating to modular services:
/// - [ApiClient] for network configuration & HTTP transport
/// - [AuthApi] for authentication (login, signup, logout)
/// - [CityApi] for city search & autocomplete
/// - [KundaliApi] for Kundali calculation & PDF generation
/// - [GunMilanApi] for matchmaking & Gun Milan PDF generation
class ApiService {
  static List<String> get candidateUrls => ApiClient.candidateUrls;

  static String get baseUrl => ApiClient.baseUrl;
  static set baseUrl(String url) => ApiClient.baseUrl = url;

  static Future<bool> testConnection([String? testUrl]) =>
      ApiClient.testConnection(testUrl);

  static Future<String> autoDetectWorkingUrl() =>
      ApiClient.autoDetectWorkingUrl();

  static Future<Map<String, dynamic>> sendSignupOtp({required String email}) =>
      AuthApi.sendSignupOtp(email: email);

  static Future<Map<String, dynamic>> sendLoginOtp({required String email, String? password}) =>
      AuthApi.sendLoginOtp(email: email, password: password);

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      AuthApi.login(email: email, password: password);

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      AuthApi.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

  static Future<void> logout() => AuthApi.logout();

  static Future<List<CityItem>> searchCities(String query, {int limit = 20}) =>
      CityApi.searchCities(query, limit: limit);

  static Future<KundaliData> calculateKundali({
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lng,
    required String place,
    required String ayanamsha,
  }) =>
      KundaliApi.calculateKundali(
        name: name,
        date: date,
        time: time,
        lat: lat,
        lng: lng,
        place: place,
        ayanamsha: ayanamsha,
      );

  static Future<GunMilanData> calculateGunMilan({
    required Map<String, dynamic> boy,
    required Map<String, dynamic> girl,
    required String ayanamsha,
  }) =>
      GunMilanApi.calculateGunMilan(
        boy: boy,
        girl: girl,
        ayanamsha: ayanamsha,
      );

  static Future<File> downloadKundaliPdf(KundaliData kundali, {String? fileName}) =>
      KundaliApi.downloadPdf(kundali, fileName: fileName);

  static Future<File> downloadGunMilanPdf(GunMilanData gunMilan, {String? fileName}) =>
      GunMilanApi.downloadPdf(gunMilan, fileName: fileName);

  static Future<OpenResult> openPdfFile(File file) =>
      OpenFilex.open(file.path);
}
