import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

class VedicSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const VedicSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySaffron,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkWood,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                if (sub != null) ...[
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class InfoGridCard extends StatelessWidget {
  final List<MapEntry<String, String>> items;

  const InfoGridCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: items.map((item) {
            final isLast = items.indexOf(item) == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item.value,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkWood,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 0.7,
                    color: AppTheme.borderLight,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final bool isSuccess;
  final bool isWarning;

  const StatusBadge({
    super.key,
    required this.text,
    this.isSuccess = true,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppTheme.successBg;
    Color fg = AppTheme.successGreen;

    if (isWarning) {
      bg = AppTheme.warningBg;
      fg = AppTheme.warningOrange;
    } else if (!isSuccess) {
      bg = AppTheme.dangerBg;
      fg = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ScoreCircleBadge extends StatelessWidget {
  final double score;
  final double maxScore;
  final double percentage;

  const ScoreCircleBadge({
    super.key,
    required this.score,
    required this.maxScore,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = score >= 18;
    final color = isGood ? AppTheme.successGreen : AppTheme.dangerRed;

    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              score.toStringAsFixed(score == score.toInt() ? 0 : 1),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
            Text(
              '/ ${maxScore.toInt()} गुण',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
