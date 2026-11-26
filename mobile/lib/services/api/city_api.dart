import 'dart:convert';
import '../../models/astrology_models.dart';
import 'api_client.dart';

class CityApi {
  /// Search cities via backend SQLite database (146,000+ Indian cities).
  static Future<List<CityItem>> searchCities(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return [];
    }

    final res = await ApiClient.get(
      '/cities',
      queryParams: {
        'q': trimmed,
        'limit': limit.toString(),
      },
      timeout: const Duration(seconds: 6),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = (data['results'] as List? ?? []);
      return list.map((item) {
        final lat = (item['lat'] ?? 0.0).toDouble();
        final lng = (item['lng'] ?? 0.0).toDouble();
        return CityItem(
          name: item['name'] ?? '',
          state: item['state'] ?? '',
          district: item['district'] ?? '',
          lat: lat,
          lng: lng,
          display: item['display'] ?? '${item['name']}, ${item['state']}',
        );
      }).toList();
    } else {
      throw ApiException('शहरे शोधण्यात अडचण आली (${res.statusCode})', res.statusCode);
    }
  }
}
