import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/models/astrology_models.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/signup_screen.dart';
import 'package:mobile/screens/language/language_selection_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/localization_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/north_indian_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, Map<String, dynamic>> _testTranslations = {};

void _loadTestTranslations() {
  if (_testTranslations.isNotEmpty) return;
  for (final lang in ['mr', 'en', 'hi']) {
    final file = File('assets/translations/$lang.json');
    if (file.existsSync()) {
      _testTranslations[lang] = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    }
  }
}

class InMemoryAssetLoader extends AssetLoader {
  const InMemoryAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    return Future.value(_testTranslations[locale.languageCode] ?? {});
  }
}

Widget createLocalizedApp({Widget? child, Locale startLocale = const Locale('mr')}) {
  return EasyLocalization(
    key: UniqueKey(),
    saveLocale: false,
    assetLoader: const InMemoryAssetLoader(),
    supportedLocales: LocalizationService.supportedLocales,
    path: LocalizationService.translationPath,
    fallbackLocale: LocalizationService.fallbackLocale,
    startLocale: startLocale,
    child: Builder(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          ...context.localizationDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.lightTheme,
        home: child ?? (AuthService.isLoggedIn ? const HomeScreen() : const LanguageSelectionScreen()),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _loadTestTranslations();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    EasyLocalization.logger.enableLevels = [];
    await EasyLocalization.ensureInitialized();
    await AuthService.login(
      token: 'mock_sanctum_token_123',
      name: 'अनिकेत जोशी',
      email: 'aniket.joshi@example.com',
    );
  });

  testWidgets('When logged out, app shows LanguageSelectionScreen first, then navigates to LoginScreen',
      (WidgetTester tester) async {
    await AuthService.logout();
    await tester.pumpWidget(createLocalizedApp());
    await tester.pumpAndSettle();

    // Verify LanguageSelectionScreen appears first
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(find.text('भाषा निवडा'), findsOneWidget);
    expect(find.text('मराठी'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('hindi_name'), findsNothing);
    expect(find.text('hindi_sub'), findsNothing);
    expect(find.text('पुढे जा'), findsOneWidget);

    // Tap 'पुढे जा' to continue to LoginScreen
    await tester.tap(find.text('पुढे जा'));
    await tester.pumpAndSettle();

    // Now LoginScreen is shown without any double danda (॥)
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('प्रवेश'), findsOneWidget);
    expect(find.text('ईमेल पत्ता'), findsOneWidget);
    expect(find.text('प्रवेश करा'), findsOneWidget);
    expect(find.text('Google खात्याद्वारे प्रवेश करा'), findsNothing);
    expect(find.text('अतिथी म्हणून पुढे जा (Continue as Guest)'), findsNothing);
  });

  testWidgets('Renders Vedic Kundali app with navigation bar when logged in', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp());
    await tester.pumpAndSettle();

    // Verify title and tabs without double danda symbol
    expect(find.text('जन्म कुंडली'), findsWidgets);
    expect(find.text('गुण मिलान'), findsOneWidget);
    expect(find.text('शहर शोध'), findsOneWidget);
    expect(find.text('सेटिंग्ज'), findsOneWidget);
  });

  testWidgets('Starting in English locale renders English strings across the app', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp(startLocale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Gun Milan'), findsOneWidget);
    expect(find.text('Search City'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Starting in Hindi locale renders Hindi strings across the app', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp(startLocale: const Locale('hi')));
    await tester.pumpAndSettle();

    expect(find.text('गुण मिलान'), findsOneWidget);
    expect(find.text('शहर खोज'), findsOneWidget);
    expect(find.text('सेटिंग्स'), findsOneWidget);
  });

  testWidgets('NorthIndianChartWidget renders without exceptions', (WidgetTester tester) async {
    final chart = sampleKundaliData.charts['lagna']!;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: NorthIndianChartWidget(
              chartData: chart,
              planetDetails: sampleKundaliData.planets,
              size: 320,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NorthIndianChartWidget), findsOneWidget);
  });

  testWidgets('Form starts empty, populates on Namuna button tap, and allows city selection', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp());
    await tester.pumpAndSettle();

    // Verify fields start empty
    final nameFieldFinder = find.widgetWithText(TextFormField, 'व्यक्तीचे नाव');
    expect(nameFieldFinder, findsOneWidget);
    expect(find.text('अनिकेत जोशी'), findsNothing);

    // Tap "नमुना" button in AppBar
    final namunaBtn = find.text('नमुना');
    expect(namunaBtn, findsOneWidget);
    await tester.tap(namunaBtn);
    await tester.pumpAndSettle();

    // Verify fields are now populated with demo data
    expect(find.text('अनिकेत जोशी'), findsOneWidget);
    expect(find.text('Shirpur, Dhule, Maharashtra'), findsOneWidget);

    // Tap on the city text form field in KundaliInputScreen
    final cityField = find.widgetWithText(TextFormField, 'Shirpur, Dhule, Maharashtra');
    expect(cityField, findsOneWidget);
    await tester.tap(cityField);
    await tester.pumpAndSettle();

    // Verify CitySearchScreen is opened in picker mode without double danda
    expect(find.text('स्थान निवडा'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Tap on Pune to select it
    final puneItem = find.text('पुणे');
    expect(puneItem, findsOneWidget);
    await tester.tap(puneItem);
    await tester.pumpAndSettle();

    // Verify we returned to KundaliInputScreen with Pune selected
    expect(find.widgetWithText(TextFormField, 'Pune, Pune, Maharashtra'), findsOneWidget);
  });

  testWidgets('LoginScreen renders UI elements and accepts user input', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp(child: const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('प्रवेश'), findsOneWidget);
    expect(find.text('ईमेल पत्ता'), findsOneWidget);
    expect(find.text('पासवर्ड'), findsOneWidget);
    expect(find.text('प्रवेश करा'), findsOneWidget);

    // Enter user credentials
    await tester.enterText(find.widgetWithText(TextFormField, 'ईमेल पत्ता'), 'user@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'पासवर्ड'), 'mypassword123');
    await tester.pumpAndSettle();

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('mypassword123'), findsOneWidget);
  });

  testWidgets('SignupScreen renders UI elements and accepts user input', (WidgetTester tester) async {
    await tester.pumpWidget(createLocalizedApp(child: const SignupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('नोंदणी'), findsWidgets);
    expect(find.text('पूर्ण नाव'), findsOneWidget);
    expect(find.text('ईमेल पत्ता'), findsOneWidget);
    expect(find.text('मोबाईल क्रमांक (ऐच्छिक)'), findsOneWidget);

    // Enter user registration details
    await tester.enterText(find.widgetWithText(TextFormField, 'पूर्ण नाव'), 'रमेश शर्मा');
    await tester.enterText(find.widgetWithText(TextFormField, 'ईमेल पत्ता'), 'ramesh@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'मोबाईल क्रमांक (ऐच्छिक)'), '9822123456');
    await tester.pumpAndSettle();

    expect(find.text('रमेश शर्मा'), findsOneWidget);
    expect(find.text('ramesh@example.com'), findsOneWidget);
    expect(find.text('9822123456'), findsOneWidget);
  });

  test('ApiClient.buildHeaders includes lang, X-Locale, and Accept-Language headers matching LocalizationService', () {
    LocalizationService.currentLanguage = 'mr';
    var headers = ApiClient.buildHeaders();
    expect(headers['lang'], 'mr');
    expect(headers['X-Locale'], 'mr');
    expect(headers['Accept-Language'], 'mr');

    LocalizationService.currentLanguage = 'hi';
    headers = ApiClient.buildHeaders();
    expect(headers['lang'], 'hi');
    expect(headers['X-Locale'], 'hi');
    expect(headers['Accept-Language'], 'hi');

    LocalizationService.currentLanguage = 'en';
    headers = ApiClient.buildHeaders();
    expect(headers['lang'], 'en');
    expect(headers['X-Locale'], 'en');
    expect(headers['Accept-Language'], 'en');
  });
}
