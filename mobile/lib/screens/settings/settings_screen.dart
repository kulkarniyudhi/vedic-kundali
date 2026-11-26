import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import '../../services/api/api.dart';
import '../../services/auth_service.dart';
import '../../services/flagsmith_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedAyanamsha = 'lahiri';
  String _selectedHouseSystem = 'placidus';
  String _selectedLanguage = 'mr';

  bool _isCheckingConnection = false;
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = context.locale.languageCode;
  }

  Future<void> _checkServer() async {
    setState(() => _isCheckingConnection = true);
    final ok = await ApiClient.testConnection();
    if (!mounted) return;
    setState(() {
      _isConnected = ok;
      _isCheckingConnection = false;
    });
  }

  void _editServerUrl() {
    final controller = TextEditingController(text: ApiClient.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.editServerUrlTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.serverUrlDesc,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://127.0.0.1:8000/api',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                ActionChip(
                  label: const Text('127.0.0.1 (ADB)'),
                  onPressed: () => controller.text = 'http://127.0.0.1:8000/api',
                ),
                ActionChip(
                  label: const Text('192.168.31.118 (Wi-Fi)'),
                  onPressed: () => controller.text = 'http://192.168.31.118:8000/api',
                ),
                ActionChip(
                  label: const Text('10.0.2.2 (Emulator)'),
                  onPressed: () => controller.text = 'http://10.0.2.2:8000/api',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ApiClient.baseUrl = controller.text.trim();
              Navigator.pop(ctx);
              _checkServer();
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppTheme.dangerRed),
            const SizedBox(width: 8),
            Text(AppStrings.confirmLogoutTitle),
          ],
        ),
        content: Text(
          AppStrings.confirmLogoutMsg,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthApi.logout();
              FlagsmithService.clearUser();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(AppStrings.confirmLogoutBtn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Profile Section
          VedicSectionHeader(title: AppStrings.userProfile),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primarySaffron.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, color: AppTheme.deepVermilion, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthService.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AuthService.userEmail,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            if (AuthService.userPhone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '+91 ${AuthService.userPhone}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                      StatusBadge(text: AppStrings.activeStatus, isSuccess: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout, size: 18, color: AppTheme.dangerRed),
                      label: Text(
                        AppStrings.logOutButton,
                        style: const TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.dangerRed, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Engine Card
          Card(
            color: AppTheme.chipBackground,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySaffron,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.softwareEngineTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkWood,
                              ),
                            ),
                            Text(
                              AppStrings.softwareEngineSubtitle,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.softwareEngineDesc,
                    style: const TextStyle(fontSize: 12, color: AppTheme.darkWood, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API Server Status Section
          VedicSectionHeader(title: AppStrings.backendServerSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isConnected == true
                            ? Icons.check_circle
                            : (_isConnected == false ? Icons.error : Icons.cloud_sync),
                        color: _isConnected == true
                            ? AppTheme.successGreen
                            : (_isConnected == false ? AppTheme.dangerRed : AppTheme.warningOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.serverConnectivity,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              ApiClient.baseUrl,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        text: _isCheckingConnection
                            ? AppStrings.serverChecking
                            : (_isConnected == true ? AppStrings.serverOnline : AppStrings.serverOffline),
                        isSuccess: _isConnected == true,
                        isWarning: _isCheckingConnection,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isCheckingConnection ? null : _checkServer,
                          icon: _isCheckingConnection
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 18),
                          label: Text(AppStrings.pingServer),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _editServerUrl,
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(AppStrings.changeUrl),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferences
          VedicSectionHeader(title: AppStrings.astrologyOptions),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_medium_outlined, color: AppTheme.primarySaffron),
                  title: Text(AppStrings.defaultAyanamsha),
                  subtitle: Text(
                    _selectedAyanamsha == 'lahiri' ? AppStrings.lahiriSub : AppStrings.kpSub,
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedAyanamsha,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'lahiri', child: Text('Lahiri')),
                      DropdownMenuItem(value: 'kp', child: Text('KP')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAyanamsha = val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.home_work_outlined, color: AppTheme.primarySaffron),
                  title: Text(AppStrings.houseSystem),
                  subtitle: Text(
                    _selectedHouseSystem == 'placidus' ? AppStrings.placidusSub : AppStrings.wholesignSub,
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedHouseSystem,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'placidus', child: Text('Placidus')),
                      DropdownMenuItem(value: 'wholesign', child: Text('Whole Sign')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedHouseSystem = val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: AppTheme.primarySaffron),
                  title: Text(AppStrings.languageSetting),
                  subtitle: Text(
                    _selectedLanguage == 'mr'
                        ? AppStrings.marathiName
                        : (_selectedLanguage == 'hi' ? AppStrings.hindiName : AppStrings.englishName),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'mr', child: Text(AppStrings.marathiName)),
                      DropdownMenuItem(value: 'hi', child: Text(AppStrings.hindiName)),
                      DropdownMenuItem(value: 'en', child: Text(AppStrings.englishName)),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => _selectedLanguage = val);
                        await LocalizationService.changeLanguage(context, val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Features Summary
          VedicSectionHeader(title: AppStrings.includedFeatures),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.diamond_outlined, color: AppTheme.deepVermilion),
                  title: Text(AppStrings.featDiamondChart),
                  subtitle: Text(AppStrings.featDiamondChartSub),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline, color: AppTheme.deepVermilion),
                  title: Text(AppStrings.featGunMilan),
                  subtitle: Text(AppStrings.featGunMilanSub),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timeline_outlined, color: AppTheme.deepVermilion),
                  title: Text(AppStrings.featMahadasha),
                  subtitle: Text(AppStrings.featMahadashaSub),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppTheme.deepVermilion),
                  title: Text(AppStrings.featCities),
                  subtitle: Text(AppStrings.featCitiesSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App version footer
          const Center(
            child: Text(
              'Vedic Kundali Mobile • v1.0.0\n100% Royalty Free Analytical Ephemeris',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
