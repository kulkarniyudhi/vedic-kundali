import 'dart:convert';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/astrology_models.dart';
import 'api_client.dart';

class KundaliApi {
  /// Calculate real Vedic Kundali astronomical data.
  static Future<KundaliData> calculateKundali({
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lng,
    required String place,
    required String ayanamsha,
  }) async {
    final payload = {
      'name': name.trim(),
      'date': date.trim(),
      'time': time.trim(),
      'lat': lat,
      'lng': lng,
      'place': place.trim(),
      'ayanamsha': ayanamsha.toLowerCase(),
    };

    final res = await ApiClient.post(
      '/calculate',
      body: payload,
      timeout: const Duration(seconds: 15),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      if (data['birth_info'] is Map && (data['birth_info']['name'] == null || data['birth_info']['name'].isEmpty)) {
        data['birth_info']['name'] = name;
      }
      return KundaliData.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? data['message'] ?? 'कुंडली गणना अयशस्वी झाली (${res.statusCode})';
      throw ApiException(errorMsg.toString(), res.statusCode);
    }
  }

  /// Generate and download real Vedic Kundali PDF report.
  static Future<File> downloadPdf(KundaliData kundali, {String? fileName}) async {
    final res = await ApiClient.post(
      '/download-pdf',
      body: kundali.rawJson,
      extraHeaders: {'Accept': 'application/pdf'},
      timeout: const Duration(seconds: 25),
    );

    if (res.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final safeName = (fileName ?? 'kundali_${kundali.birthInfo.name}')
          .replaceAll(RegExp(r'[^\w\-_.]'), '_');
      final file = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(res.bodyBytes);
      return file;
    } else {
      throw ApiException('PDF डाऊनलोड अयशस्वी (${res.statusCode}): ${res.body}', res.statusCode);
    }
  }

  /// Open downloaded PDF using the system PDF viewer.
  static Future<OpenResult> openPdfFile(File file) async {
    return OpenFilex.open(file.path);
  }
}
