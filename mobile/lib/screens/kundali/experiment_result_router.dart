import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/flagsmith_service.dart';
import 'kundali_result_screen.dart';
import 'summary_result_view.dart';

/// Experiment Router for Kundali Results
///
/// This widget evaluates the Flagsmith 'kundali_result_layout' feature flag
/// and routes the user to the appropriate result layout variation:
///   - 'detailed' (Control / Variation A) → KundaliResultScreen
///   - 'summary_first' (Test / Variation B) → SummaryResultView
///
/// Part of the A/B experiment for the Toggle Wars Flagsmith Hackathon.
class ExperimentResultRouter extends StatefulWidget {
  final KundaliData kundali;

  const ExperimentResultRouter({super.key, required this.kundali});

  @override
  State<ExperimentResultRouter> createState() => _ExperimentResultRouterState();
}

class _ExperimentResultRouterState extends State<ExperimentResultRouter> {
  String _layout = 'loading';

  @override
  void initState() {
    super.initState();
    _loadExperimentVariation();
  }

  Future<void> _loadExperimentVariation() async {
    final layout = await FlagsmithService.getKundaliLayout();
    if (mounted) {
      setState(() => _layout = layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_layout == 'loading') {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD45D00)),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.brown.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Route to the appropriate variation
    if (_layout == 'summary_first') {
      return SummaryResultView(kundali: widget.kundali);
    }

    // Default: Control variation (detailed layout)
    return KundaliResultScreen(kundali: widget.kundali);
  }
}
