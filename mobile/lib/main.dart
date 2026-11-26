import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'screens/home_screen.dart';
import 'screens/language/language_selection_screen.dart';
import 'services/api/api_client.dart';
import 'services/auth_service.dart';
import 'services/flagsmith_service.dart';
import 'services/localization_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AuthService.init();
  await FlagsmithService.init();
  if (AuthService.isLoggedIn) {
    await FlagsmithService.identifyUser();
  }
  await LocalizationService.init();
  ApiClient.autoDetectWorkingUrl();

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationService.supportedLocales,
      path: LocalizationService.translationPath,
      fallbackLocale: LocalizationService.fallbackLocale,
      startLocale: LocalizationService.startLocale,
      child: const VedicKundaliApp(),
    ),
  );
}

class VedicKundaliApp extends StatelessWidget {
  const VedicKundaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...context.localizationDelegates,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      home: AuthService.isLoggedIn
          ? const HomeScreen()
          : const LanguageSelectionScreen(),
    );
  }
}
