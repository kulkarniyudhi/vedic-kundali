import 'dart:convert';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/astrology_models.dart';
import 'api_client.dart';

class GunMilanApi {
  /// Calculate real Ashtakoot Gun Milan matchmaking.
  static Future<GunMilanData> calculateGunMilan({
    required Map<String, dynamic> boy,
    required Map<String, dynamic> girl,
    required String ayanamsha,
  }) async {
    final payload = {
      'boy': boy,
      'girl': girl,
      'ayanamsha': ayanamsha.toLowerCase(),
    };

    final res = await ApiClient.post(
      '/gunmilan',
      body: payload,
      timeout: const Duration(seconds: 15),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      return GunMilanData.fromJson(data);
    } else {
      final errorMsg = data['error'] ?? data['message'] ?? 'गुण मिलान गणना अयशस्वी (${res.statusCode})';
      throw ApiException(errorMsg.toString(), res.statusCode);
    }
  }

  /// Generate and download real Gun Milan PDF report.
  static Future<File> downloadPdf(GunMilanData gunMilan, {String? fileName}) async {
    final res = await ApiClient.post(
      '/download-gunmilan-pdf',
      body: gunMilan.rawJson,
      extraHeaders: {'Accept': 'application/pdf'},
      timeout: const Duration(seconds: 25),
    );

    if (res.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final boySlug = ApiClient.sanitizeFileSlug(gunMilan.boy.birthInfo.name, 'boy');
      final girlSlug = ApiClient.sanitizeFileSlug(gunMilan.girl.birthInfo.name, 'girl');
      final safeName = fileName != null
          ? ApiClient.sanitizeFileSlug(fileName, 'gunmilan_report')
          : 'gunmilan_${boySlug}_$girlSlug';
      final file = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(res.bodyBytes);
      return file;
    } else {
      throw ApiException('गुण मिलान PDF डाऊनलोड अयशस्वी (${res.statusCode})', res.statusCode);
    }
  }

  /// Open downloaded PDF using the system PDF viewer.
  static Future<OpenResult> openPdfFile(File file) async {
    return OpenFilex.open(file.path);
  }
}
