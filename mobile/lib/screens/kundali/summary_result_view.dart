import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/kundali_api.dart';
import '../../services/flagsmith_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/north_indian_chart.dart';

/// Summary-First Kundali Result Layout (Variation B of A/B Experiment)
///
/// This is the test variation for the 'kundali_result_layout' experiment.
/// It shows key highlights first with a prominent PDF download CTA,
/// followed by expandable detailed sections.
///
/// Hypothesis: This layout will lead to higher PDF download rates
/// compared to the detailed layout (Variation A / Control).
class SummaryResultView extends StatefulWidget {
  final KundaliData kundali;

  const SummaryResultView({super.key, required this.kundali});

  @override
  State<SummaryResultView> createState() => _SummaryResultViewState();
}

class _SummaryResultViewState extends State<SummaryResultView> {
  bool _isDownloadingPdf = false;
  bool _showFullDetails = false;
  String _activeChartKey = 'lagna';
  bool _showDegreesOnChart = false;

  Future<void> _downloadAndOpenPdf() async {
    setState(() => _isDownloadingPdf = true);
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
            Text(AppStrings.pdfGenerating),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final file = await KundaliApi.downloadPdf(widget.kundali);
      if (!mounted) return;
      setState(() => _isDownloadingPdf = false);

      // Track PDF download event for Flagsmith experiment
      unawaited(FlagsmithService.trackConversion('pdf_download'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pdfReady(file.path.split('/').last)),
          backgroundColor: AppTheme.successGreen,
          action: SnackBarAction(
            label: AppStrings.openPdf,
            textColor: Colors.white,
            onPressed: () => KundaliApi.openPdfFile(file),
          ),
          duration: const Duration(seconds: 6),
        ),
      );

      await KundaliApi.openPdfFile(file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloadingPdf = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pdfError(e.toString())),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kundali;
    final info = k.birthInfo;
    final p = k.panchang;
    final isEnglish = LocalizationService.isEnglish(context);

    // Find lagna planet detail
    final lagnaDetail = k.planets.firstWhere(
      (pl) => pl.id == 'lagna',
      orElse: () => k.planets.first,
    );

    // Find moon planet detail for current mahadasha
    final currentDasha = k.mahadasha.isNotEmpty ? k.mahadasha.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(info.name.isNotEmpty ? info.name : AppStrings.horoscopeTitle),
        actions: [
          IconButton(
            onPressed: _downloadAndOpenPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: AppStrings.pdfReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══════════════════════════════════════
            // HERO SUMMARY CARD
            // ═══════════════════════════════════════
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.warmMaroon, AppTheme.deepVermilion],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepVermilion.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Date
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.name.isNotEmpty ? info.name : AppStrings.horoscopeTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${info.date} • ${info.time} (${info.day})',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${info.place} • ${info.coordinates}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),

                  // Key Highlights Grid
                  Row(
                    children: [
                      _highlightChip(
                        isEnglish ? 'Rashi' : 'राशी',
                        p.moonRashi.split(' ').first,
                      ),
                      const SizedBox(width: 10),
                      _highlightChip(
                        isEnglish ? 'Nakshatra' : 'नक्षत्र',
                        '${p.nakshatra} (${p.pada})',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _highlightChip(
                        isEnglish ? 'Lagna' : 'लग्न',
                        isEnglish ? lagnaDetail.rashiEn : lagnaDetail.rashi,
                      ),
                      const SizedBox(width: 10),
                      if (currentDasha != null)
                        _highlightChip(
                          isEnglish ? 'Mahadasha' : 'महादशा',
                          currentDasha.planetName,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // PROMINENT PDF DOWNLOAD CTA
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isDownloadingPdf ? null : _downloadAndOpenPdf,
                icon: _isDownloadingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 22),
                label: Text(
                  _isDownloadingPdf ? AppStrings.loading : AppStrings.downloadPdf,
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primarySaffron,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════
            // QUICK PANCHANG INFO
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VedicSectionHeader(
                    title: AppStrings.panchangSectionTitle,
                  ),
                  InfoGridCard(
                    items: [
                      MapEntry(AppStrings.tithi, '${p.tithi} (${p.paksha})'),
                      MapEntry(AppStrings.nakshatra,
                          AppStrings.nakshatraDetail(p.nakshatra, p.pada, p.syllable)),
                      MapEntry(AppStrings.yoga, p.yoga),
                      MapEntry(AppStrings.karana, p.karana),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════
            // LAGNA CHART PREVIEW
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VedicSectionHeader(title: AppStrings.chartLagna),
                  Center(
                    child: NorthIndianChartWidget(
                      chartData: k.charts['lagna'] ?? k.charts.values.first,
                      planetDetails: k.planets,
                      size: 300,
                      showDegrees: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════
            // EXPAND FOR FULL DETAILS
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  final expanding = !_showFullDetails;
                  setState(() => _showFullDetails = expanding);
                  if (expanding) {
                    unawaited(FlagsmithService.trackConversion('view_full_details'));
                  }
                },
                icon: Icon(
                  _showFullDetails ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showFullDetails
                      ? (isEnglish ? 'Hide Full Details' : 'संपूर्ण माहिती लपवा')
                      : (isEnglish ? 'View Full Details' : 'संपूर्ण माहिती पहा'),
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // FULL DETAILS (Expandable)
            // ═══════════════════════════════════════
            if (_showFullDetails) ...[
              const SizedBox(height: 16),

              // All Charts with selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VedicSectionHeader(title: AppStrings.tabCharts),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: 'lagna', label: Text(AppStrings.chartLagna)),
                        ButtonSegment(value: 'navamsha', label: Text(AppStrings.chartNavamsha)),
                        ButtonSegment(value: 'chalit', label: Text(AppStrings.chartChalit)),
                        ButtonSegment(value: 'chandra', label: Text(AppStrings.chartChandra)),
                      ],
                      selected: {_activeChartKey},
                      onSelectionChanged: (val) {
                        setState(() => _activeChartKey = val.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.primarySaffron;
                          }
                          return Colors.white;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return AppTheme.darkWood;
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(AppStrings.showDegrees, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Switch.adaptive(
                          value: _showDegreesOnChart,
                          activeTrackColor: AppTheme.primarySaffron,
                          onChanged: (val) => setState(() => _showDegreesOnChart = val),
                        ),
                      ],
                    ),
                    Center(
                      child: NorthIndianChartWidget(
                        chartData: k.charts[_activeChartKey] ?? k.charts['lagna']!,
                        planetDetails: k.planets,
                        size: 330,
                        showDegrees: _showDegreesOnChart,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Planets Table
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VedicSectionHeader(title: AppStrings.tabPlanets),
                    ...k.planets.map((pl) {
                      final isLagna = pl.id == 'lagna';
                      final rashiText = isEnglish ? pl.rashiEn : pl.rashi;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isLagna
                                    ? AppTheme.warmMaroon
                                    : AppTheme.primarySaffron.withValues(alpha: 0.15),
                                foregroundColor: isLagna ? Colors.white : AppTheme.deepVermilion,
                                child: Text(
                                  pl.name.length > 2 ? pl.name.substring(0, 2) : pl.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(pl.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        if (pl.retrograde && !isLagna) ...[
                                          const SizedBox(width: 6),
                                          StatusBadge(
                                            text: pl.retroMarker.isNotEmpty ? pl.retroMarker : (isEnglish ? 'R' : 'व'),
                                            isSuccess: false,
                                            isWarning: true,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$rashiText • ${pl.degreeDms}',
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(pl.nakshatra, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(
                                    AppStrings.padaSyllable(pl.pada, pl.syllable),
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mahadasha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VedicSectionHeader(title: AppStrings.tabMahadasha),
                    ...k.mahadasha.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final d = entry.value;
                      final isFirst = idx == 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isFirst ? AppTheme.primarySaffron : AppTheme.chipBackground,
                            foregroundColor: isFirst ? Colors.white : AppTheme.darkWood,
                            child: Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Row(
                            children: [
                              Text(
                                AppStrings.mahadashaTitle(d.planetName),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${d.totalYears} ${AppStrings.years})',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${AppStrings.duration}: ${d.startDate} ${AppStrings.to} ${d.endDate}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${d.actualYears.toStringAsFixed(1)} ${AppStrings.years}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepVermilion),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Avakhada Chakra
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VedicSectionHeader(
                      title: AppStrings.avakhadaTitle,
                      subtitle: AppStrings.avakhadaSub,
                    ),
                    InfoGridCard(
                      items: [
                        MapEntry(AppStrings.varna, k.avakhada.varna),
                        MapEntry(AppStrings.tattva, k.avakhada.tattva),
                        MapEntry(AppStrings.vashya, k.avakhada.vashya),
                        MapEntry(AppStrings.yoni, k.avakhada.yoni),
                        MapEntry(AppStrings.gana, k.avakhada.gana),
                        MapEntry(AppStrings.nadi, k.avakhada.nadi),
                        MapEntry(AppStrings.varga, k.avakhada.varga),
                        MapEntry(AppStrings.yunja, k.avakhada.yunja),
                        MapEntry(AppStrings.yoga, k.avakhada.yoga),
                        MapEntry(AppStrings.karana, k.avakhada.karana),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _highlightChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
