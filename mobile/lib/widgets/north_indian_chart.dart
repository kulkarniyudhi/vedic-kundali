import 'package:material_ui/material_ui.dart';
import '../models/astrology_models.dart';
import '../theme/app_theme.dart';

class NorthIndianChartWidget extends StatelessWidget {
  final ChartHouseData chartData;
  final List<PlanetDetail>? planetDetails;
  final double size;
  final bool showDegrees;

  const NorthIndianChartWidget({
    super.key,
    required this.chartData,
    this.planetDetails,
    this.size = 340,
    this.showDegrees = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveSize = (constraints.maxWidth.isFinite && constraints.maxWidth < size)
            ? constraints.maxWidth
            : size;

        return Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepVermilion.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.borderLight, width: 1.5),
          ),
          child: CustomPaint(
            size: Size(effectiveSize, effectiveSize),
            painter: _NorthIndianChartPainter(
              chartData: chartData,
              planetDetails: planetDetails ?? [],
              showDegrees: showDegrees,
            ),
          ),
        );
      },
    );
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  final ChartHouseData chartData;
  final List<PlanetDetail> planetDetails;
  final bool showDegrees;

  _NorthIndianChartPainter({
    required this.chartData,
    required this.planetDetails,
    required this.showDegrees,
  });

  static const Map<String, String> planetLabels = {
    'sun': 'रवि',
    'moon': 'चंद्र',
    'mars': 'मंगळ',
    'mercury': 'बुध',
    'jupiter': 'गुरु',
    'venus': 'शुक्र',
    'saturn': 'शनि',
    'rahu': 'राहू',
    'ketu': 'केतु',
    'uranus': 'हर्षल',
    'neptune': 'नेप.',
    'pluto': 'प्लुटो',
  };

  // Center positions for planets in each house (normalized 0.0 - 1.0)
  static const Map<int, Offset> housePlanetPositions = {
    1: Offset(0.50, 0.28),
    2: Offset(0.27, 0.16),
    3: Offset(0.15, 0.27),
    4: Offset(0.28, 0.50),
    5: Offset(0.15, 0.73),
    6: Offset(0.27, 0.84),
    7: Offset(0.50, 0.72),
    8: Offset(0.73, 0.84),
    9: Offset(0.85, 0.73),
    10: Offset(0.72, 0.50),
    11: Offset(0.85, 0.27),
    12: Offset(0.73, 0.16),
  };

  // House number positions (normalized 0.0 - 1.0)
  static const Map<int, Offset> houseNumberPositions = {
    1: Offset(0.50, 0.10),
    2: Offset(0.26, 0.07),
    3: Offset(0.07, 0.26),
    4: Offset(0.12, 0.50),
    5: Offset(0.07, 0.74),
    6: Offset(0.26, 0.93),
    7: Offset(0.50, 0.90),
    8: Offset(0.74, 0.93),
    9: Offset(0.93, 0.74),
    10: Offset(0.88, 0.50),
    11: Offset(0.93, 0.26),
    12: Offset(0.74, 0.07),
  };

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 10.0;
    final w = size.width;
    final h = size.height;
    final midX = w / 2;
    final midY = h / 2;

    // Paint styles
    final borderPaint = Paint()
      ..color = AppTheme.primarySaffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final linePaint = Paint()
      ..color = AppTheme.primarySaffron.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 1. Outer Square
    final outerRect = Rect.fromLTRB(pad, pad, w - pad, h - pad);
    canvas.drawRect(outerRect, borderPaint);

    // 2. Diagonals (A-C and B-D)
    canvas.drawLine(Offset(pad, pad), Offset(w - pad, h - pad), linePaint);
    canvas.drawLine(Offset(w - pad, pad), Offset(pad, h - pad), linePaint);

    // 3. Inner Diamond (E-F-G-H)
    final diamondPath = Path()
      ..moveTo(midX, pad)
      ..lineTo(w - pad, midY)
      ..lineTo(midX, h - pad)
      ..lineTo(pad, midY)
      ..close();
    canvas.drawPath(diamondPath, linePaint);

    // 4. Center Lagna watermarked badge
    final centerBadgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final centerRect = Rect.fromCenter(
      center: Offset(midX, midY),
      width: 44,
      height: 24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(6)),
      centerBadgePaint,
    );
    final centerBorder = Paint()
      ..color = AppTheme.primarySaffron.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(6)),
      centerBorder,
    );

    _drawText(
      canvas,
      'लग्न',
      Offset(midX, midY),
      fontSize: 11,
      color: AppTheme.deepVermilion.withValues(alpha: 0.6),
      fontWeight: FontWeight.bold,
    );

    // 5. Draw House Rashi Numbers & Planets
    final ascRashi = chartData.ascendantRashi;

    // Map planet details for degrees/retrograde lookup
    final Map<String, PlanetDetail> planetLookup = {};
    for (final p in planetDetails) {
      planetLookup[p.id] = p;
    }

    for (int house = 1; house <= 12; house++) {
      // Calculate Rashi Number (1-12)
      final rashiNum = (ascRashi + house - 1) % 12 + 1;

      // Draw Rashi Number
      final numNorm = houseNumberPositions[house]!;
      _drawText(
        canvas,
        '$rashiNum',
        Offset(numNorm.dx * w, numNorm.dy * h),
        fontSize: 10,
        color: AppTheme.textMuted.withValues(alpha: 0.8),
        fontWeight: FontWeight.w600,
      );

      // Draw Planets in House
      final planetsInHouse = chartData.houses[house] ?? [];
      if (planetsInHouse.isNotEmpty) {
        final posNorm = housePlanetPositions[house]!;
        final centerX = posNorm.dx * w;
        final centerY = posNorm.dy * h;

        final count = planetsInHouse.length;
        const lineHeight = 13.0;
        final startY = centerY - ((count - 1) * lineHeight) / 2;

        for (int i = 0; i < count; i++) {
          final pid = planetsInHouse[i];
          var label = planetLabels[pid] ?? pid;
          final pInfo = planetLookup[pid];

          if (pInfo != null && pInfo.retrograde && pid != 'rahu' && pid != 'ketu') {
            label = '$label↓';
          }
          if (showDegrees && pInfo != null && pInfo.degree.isNotEmpty) {
            label = '$label ${pInfo.degree}';
          }

          _drawText(
            canvas,
            label,
            Offset(centerX, startY + (i * lineHeight)),
            fontSize: count > 2 ? 9.5 : 11.0,
            color: AppTheme.deepVermilion,
            fontWeight: FontWeight.bold,
          );
        }
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _NorthIndianChartPainter oldDelegate) {
    return oldDelegate.chartData != chartData ||
        oldDelegate.planetDetails != planetDetails ||
        oldDelegate.showDegrees != showDegrees;
  }
}
