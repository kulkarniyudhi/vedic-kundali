import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'mr';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = context.locale.languageCode;
  }

  void _onLanguageSelected(String code) async {
    setState(() => _selectedLanguage = code);
    await LocalizationService.changeLanguage(context, code);
  }

  void _handleContinue() async {
    await LocalizationService.changeLanguage(context, _selectedLanguage);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedLanguage == code;

    return InkWell(
      onTap: () => _onLanguageSelected(code),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.deepVermilion : AppTheme.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.deepVermilion.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primarySaffron.withValues(alpha: 0.15)
                    : AppTheme.chipBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.deepVermilion : AppTheme.darkWood,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.deepVermilion : AppTheme.darkWood,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.deepVermilion : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Brand Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primarySaffron, AppTheme.deepVermilion],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepVermilion.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.language, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Center(
                child: Text(
                  AppStrings.selectLanguageTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepVermilion,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  AppStrings.selectLanguageSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 32),

              // Marathi Option
              _buildLanguageOption(
                code: 'mr',
                title: AppStrings.marathiName,
                subtitle: AppStrings.marathiSub,
                icon: Icons.translate,
              ),
              const SizedBox(height: 12),

              // Hindi Option
              _buildLanguageOption(
                code: 'hi',
                title: AppStrings.hindiName,
                subtitle: AppStrings.hindiSub,
                icon: Icons.auto_awesome,
              ),
              const SizedBox(height: 12),

              // English Option
              _buildLanguageOption(
                code: 'en',
                title: AppStrings.englishName,
                subtitle: AppStrings.englishSub,
                icon: Icons.abc,
              ),

              const Spacer(flex: 2),

              // Continue Button
              ElevatedButton.icon(
                onPressed: _handleContinue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  AppStrings.continueButton,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
