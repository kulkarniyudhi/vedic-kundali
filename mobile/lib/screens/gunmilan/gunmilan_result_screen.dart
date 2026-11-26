import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/gunmilan_api.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/north_indian_chart.dart';

class GunMilanResultScreen extends StatefulWidget {
  final GunMilanData data;

  const GunMilanResultScreen({super.key, required this.data});

  @override
  State<GunMilanResultScreen> createState() => _GunMilanResultScreenState();
}

class _GunMilanResultScreenState extends State<GunMilanResultScreen> {
  bool _isDownloadingPdf = false;

  Future<void> _downloadAndOpenPdf() async {
    setState(() => _isDownloadingPdf = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(AppStrings.pdfGunMilanGenerating)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final file = await GunMilanApi.downloadPdf(widget.data);
      if (!mounted) return;
      setState(() => _isDownloadingPdf = false);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pdfReady(file.path.split('/').last)),
          backgroundColor: AppTheme.successGreen,
          showCloseIcon: true,
          closeIconColor: Colors.white,
          action: SnackBarAction(
            label: AppStrings.openPdf,
            textColor: Colors.white,
            onPressed: () => GunMilanApi.openPdfFile(file),
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      await GunMilanApi.openPdfFile(file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloadingPdf = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pdfError(e.toString())),
          backgroundColor: AppTheme.dangerRed,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gm = widget.data;
    final boy = gm.boy;
    final girl = gm.girl;
    final isGood = gm.totalObtained >= 18;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.gunMilanReportTitle),
        actions: [
          IconButton(
            onPressed: _isDownloadingPdf ? null : _downloadAndOpenPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: AppStrings.pdfReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Badge
            ScoreCircleBadge(
              score: gm.totalObtained,
              maxScore: gm.totalMax,
              percentage: gm.percentage,
            ),
            const SizedBox(height: 16),

            // Conclusion Card
            Card(
              color: isGood ? AppTheme.successBg : AppTheme.dangerBg,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      isGood ? AppStrings.compatibilityMatch : AppStrings.compatibilityLow,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isGood ? AppTheme.successGreen : AppTheme.dangerRed,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gm.conclusion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isGood ? AppTheme.successGreen : AppTheme.dangerRed,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mangal Dosha Card
            _buildMangalDoshaCard(gm),
            const SizedBox(height: 16),

            // Ashtakoot 8 Gunas Table
            _buildAshtakootTable(gm),
            const SizedBox(height: 16),

            // Birth Info & Panchang Comparison Table
            _buildPanchangComparison(boy, girl),
            const SizedBox(height: 16),

            // Lagna Kundali Side-by-Side Comparison
            _buildChartComparison(boy, girl),
            const SizedBox(height: 24),

            // Export Button
            ElevatedButton.icon(
              onPressed: _isDownloadingPdf ? null : _downloadAndOpenPdf,
              icon: _isDownloadingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(_isDownloadingPdf ? AppStrings.loading : AppStrings.downloadGunMilanPdf),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMangalDoshaCard(GunMilanData gm) {
    final boyM = gm.boyMangal;
    final girlM = gm.girlMangal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VedicSectionHeader(
              title: AppStrings.mangalDoshaAnalysis,
              subtitle: AppStrings.mangalDoshaSub,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: boyM.hasMangal ? AppTheme.dangerBg : AppTheme.successBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (boyM.hasMangal ? AppTheme.dangerRed : AppTheme.successGreen).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.boyLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          text: boyM.hasMangal ? AppStrings.hasMangal : AppStrings.noMangal,
                          isSuccess: !boyM.hasMangal,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.houseChalit(boyM.chalitHouse),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: girlM.hasMangal ? AppTheme.dangerBg : AppTheme.successBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (girlM.hasMangal ? AppTheme.dangerRed : AppTheme.successGreen).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.girlLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          text: girlM.hasMangal ? AppStrings.hasMangal : AppStrings.noMangal,
                          isSuccess: !girlM.hasMangal,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.houseChalit(girlM.chalitHouse),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.chipBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppTheme.primarySaffron),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gm.mangalSummary,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAshtakootTable(GunMilanData gm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VedicSectionHeader(
              title: AppStrings.ashtakootDetails,
              subtitle: AppStrings.ashtakootSub,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gm.gunas.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderLight),
              itemBuilder: (context, idx) {
                final g = gm.gunas[idx];
                final hasPoints = g.maxPoints is num;
                final gunaName = LocalizationService.isEnglish(context) ? g.nameEn : g.name;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gunaName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${g.boyValue} × ${g.girlValue}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (hasPoints) ...[
                        Text(
                          AppStrings.maxPointsLabel(g.maxPoints),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primarySaffron.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${g.obtained}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.deepVermilion,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanchangComparison(KundaliData boy, KundaliData girl) {
    final bP = boy.panchang;
    final gP = girl.panchang;
    final bA = boy.avakhada;
    final gA = girl.avakhada;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VedicSectionHeader(title: AppStrings.panchangComparison),
            const SizedBox(height: 8),
            _compareRow(AppStrings.moonSign, bP.moonRashi, gP.moonRashi),
            _compareRow(
              AppStrings.nakshatra,
              '${bP.nakshatra} (${bP.pada})',
              '${gP.nakshatra} (${gP.pada})',
            ),
            _compareRow(AppStrings.gana, bA.gana, gA.gana),
            _compareRow(AppStrings.nadi, bA.nadi, gA.nadi),
            _compareRow(AppStrings.yoni, bA.yoni, gA.yoni),
            _compareRow(AppStrings.varna, bA.varna, gA.varna),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(String label, String boyVal, String girlVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              boyVal,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1A365D)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              girlVal,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF701A45)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartComparison(KundaliData boy, KundaliData girl) {
    final bLagna = boy.charts['lagna']!;
    final gLagna = girl.charts['lagna']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            VedicSectionHeader(title: AppStrings.lagnaComparison),
            const SizedBox(height: 12),
            Column(
              children: [
                Text(
                  AppStrings.boyTitle(boy.birthInfo.name),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A365D)),
                ),
                const SizedBox(height: 8),
                NorthIndianChartWidget(chartData: bLagna, size: 280),
                const SizedBox(height: 20),
                Text(
                  AppStrings.girlTitle(girl.birthInfo.name),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF701A45)),
                ),
                const SizedBox(height: 8),
                NorthIndianChartWidget(chartData: gLagna, size: 280),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
