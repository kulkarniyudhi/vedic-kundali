import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/kundali_api.dart';
import '../../services/flagsmith_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/north_indian_chart.dart';

class KundaliResultScreen extends StatefulWidget {
  final KundaliData kundali;

  const KundaliResultScreen({super.key, required this.kundali});

  @override
  State<KundaliResultScreen> createState() => _KundaliResultScreenState();
}

class _KundaliResultScreenState extends State<KundaliResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeChartKey = 'lagna';
  bool _showDegreesOnChart = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isDownloadingPdf = false;

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

      // Track PDF download conversion event for Flagsmith A/B experiment
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

  void _showPdfExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primarySaffron, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.pdfSheetTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkWood,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.pdfSheetDesc,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isDownloadingPdf
                    ? null
                    : () {
                        Navigator.pop(context);
                        _downloadAndOpenPdf();
                      },
                icon: _isDownloadingPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(_isDownloadingPdf ? AppStrings.loading : AppStrings.downloadPdf),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadAndOpenPdf();
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(AppStrings.viewInReader),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kundali;
    final info = k.birthInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text(info.name.isNotEmpty ? info.name : AppStrings.horoscopeTitle),
        actions: [
          IconButton(
            onPressed: _showPdfExportSheet,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: AppStrings.pdfReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primarySaffron,
          labelColor: AppTheme.primarySaffron,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: AppStrings.tabCharts),
            Tab(text: AppStrings.tabPanchang),
            Tab(text: AppStrings.tabPlanets),
            Tab(text: AppStrings.tabMahadasha),
            Tab(text: AppStrings.tabAvakhada),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Birth Summary Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${info.date} • ${info.time} (${info.day})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkWood,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.place} • ${info.coordinates}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.chipBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    '${AppStrings.ayanamshaSystem}: ${k.ayanamshaSystem}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepVermilion,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppTheme.borderLight),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(k),
                _buildPanchangTab(k),
                _buildPlanetsTab(k),
                _buildMahadashaTab(k),
                _buildAvakhadaTab(k),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // TAB 1: CHARTS
  // ══════════════════════════════════════════
  Widget _buildChartsTab(KundaliData k) {
    final chart = k.charts[_activeChartKey] ?? k.charts['lagna']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart Type Selector
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

          // Chart Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chart.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepVermilion,
                ),
              ),
              Row(
                children: [
                  Text(AppStrings.showDegrees, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  Switch.adaptive(
                    value: _showDegreesOnChart,
                    activeTrackColor: AppTheme.primarySaffron,
                    onChanged: (val) {
                      setState(() => _showDegreesOnChart = val);
                    },
                  ),
                ],
              ),
            ],
          ),

          // North Indian Diamond Chart
          Center(
            child: NorthIndianChartWidget(
              chartData: chart,
              planetDetails: k.planets,
              size: 330,
              showDegrees: _showDegreesOnChart,
            ),
          ),
          const SizedBox(height: 16),

          // Houses Planet Distribution
          VedicSectionHeader(title: AppStrings.houseAnalysis),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderLight),
              itemBuilder: (context, idx) {
                final houseNum = idx + 1;
                final planets = chart.houses[houseNum] ?? [];
                final rashiNum = (chart.ascendantRashi + houseNum - 1) % 12 + 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.chipBackground,
                            child: Text(
                              '$houseNum',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepVermilion,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.houseItem(houseNum, rashiNum),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: planets.isEmpty
                            ? [
                                Text(
                                  AppStrings.empty,
                                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                                ),
                              ]
                            : planets.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primarySaffron.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme.primarySaffron.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.deepVermilion,
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // TAB 2: PANCHANG & CALENDAR
  // ══════════════════════════════════════════
  Widget _buildPanchangTab(KundaliData k) {
    final p = k.panchang;
    final c = k.calendar;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VedicSectionHeader(
            title: AppStrings.panchangSectionTitle,
            subtitle: AppStrings.panchangSectionSub,
          ),
          InfoGridCard(
            items: [
              MapEntry(AppStrings.tithi, '${p.tithi} (${p.paksha})'),
              MapEntry(
                AppStrings.nakshatra,
                AppStrings.nakshatraDetail(p.nakshatra, p.pada, p.syllable),
              ),
              MapEntry(AppStrings.yoga, p.yoga),
              MapEntry(AppStrings.karana, p.karana),
              MapEntry(AppStrings.moonSign, p.moonRashi),
            ],
          ),
          const SizedBox(height: 16),
          VedicSectionHeader(
            title: AppStrings.hinduCalendarTitle,
            subtitle: AppStrings.hinduCalendarSub,
          ),
          InfoGridCard(
            items: [
              MapEntry(AppStrings.dayName, c.dayName),
              MapEntry(AppStrings.hinduMonth, c.hinduMonth),
              MapEntry(AppStrings.shakaSamvat, c.shakaSamvat.toString()),
              MapEntry(AppStrings.vikramKartik, c.vikramKartik.toString()),
              MapEntry(AppStrings.vikramChaitra, c.vikramChaitra.toString()),
              MapEntry(AppStrings.ishtaGhati, c.ishtaGhati),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // TAB 3: PLANETS TABLE
  // ══════════════════════════════════════════
  Widget _buildPlanetsTab(KundaliData k) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: k.planets.length,
      itemBuilder: (context, idx) {
        final p = k.planets[idx];
        final isLagna = p.id == 'lagna';
        final isEnglish = LocalizationService.isEnglish(context);
        final rashiText = isEnglish ? p.rashiEn : p.rashi;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isLagna ? AppTheme.warmMaroon : AppTheme.primarySaffron.withValues(alpha: 0.15),
                  foregroundColor: isLagna ? Colors.white : AppTheme.deepVermilion,
                  child: Text(
                    p.name.length > 2 ? p.name.substring(0, 2) : p.name,
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
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (p.retrograde && !isLagna) ...[
                            const SizedBox(width: 6),
                            StatusBadge(
                              text: p.retroMarker.isNotEmpty ? p.retroMarker : (isEnglish ? 'R' : 'व'),
                              isSuccess: false,
                              isWarning: true,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$rashiText • ${p.degreeDms}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p.nakshatra,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      AppStrings.padaSyllable(p.pada, p.syllable),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════
  // TAB 4: MAHADASHA
  // ══════════════════════════════════════════
  Widget _buildMahadashaTab(KundaliData k) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: k.mahadasha.length,
      itemBuilder: (context, idx) {
        final d = k.mahadasha[idx];
        final isFirst = idx == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
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
      },
    );
  }

  // ══════════════════════════════════════════
  // TAB 5: AVAKHADA CHAKRA
  // ══════════════════════════════════════════
  Widget _buildAvakhadaTab(KundaliData k) {
    final a = k.avakhada;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VedicSectionHeader(
            title: AppStrings.avakhadaTitle,
            subtitle: AppStrings.avakhadaSub,
          ),
          InfoGridCard(
            items: [
              MapEntry(AppStrings.varna, a.varna),
              MapEntry(AppStrings.tattva, a.tattva),
              MapEntry(AppStrings.vashya, a.vashya),
              MapEntry(AppStrings.yoni, a.yoni),
              MapEntry(AppStrings.gana, a.gana),
              MapEntry(AppStrings.nadi, a.nadi),
              MapEntry(AppStrings.varga, a.varga),
              MapEntry(AppStrings.yunja, a.yunja),
              MapEntry(AppStrings.yoga, a.yoga),
              MapEntry(AppStrings.karana, a.karana),
            ],
          ),
        ],
      ),
    );
  }
}
