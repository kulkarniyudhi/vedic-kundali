import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/models/astrology_models.dart';
import 'package:mobile/screens/kundali/kundali_result_screen.dart';
import 'package:mobile/screens/kundali/summary_result_view.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/flagsmith_service.dart';
import 'package:mobile/services/localization_service.dart';
import 'package:mobile/theme/app_theme.dart';
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

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    return Future.value(_testTranslations[locale.languageCode] ?? {});
  }
}

Widget _wrapWithLocalization(Widget child) {
  return EasyLocalization(
    key: UniqueKey(),
    saveLocale: false,
    assetLoader: const _InMemoryAssetLoader(),
    supportedLocales: LocalizationService.supportedLocales,
    path: LocalizationService.translationPath,
    fallbackLocale: LocalizationService.fallbackLocale,
    startLocale: const Locale('en'),
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
        home: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _loadTestTranslations();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableLevels = [];
    await EasyLocalization.ensureInitialized();
  });

  test('FlagsmithService safely falls back to detailed when uninitialized', () async {
    expect(FlagsmithService.isReady, isFalse);
    final layout = await FlagsmithService.getKundaliLayout();
    expect(layout, equals('detailed'));
  });

  testWidgets('SummaryResultView (Variation B) renders highlights, PDF CTA, and expandable details',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithLocalization(SummaryResultView(kundali: sampleKundaliData)));
    await tester.pumpAndSettle();

    // Key summary highlights
    expect(find.text('Rashi'), findsOneWidget);
    expect(find.text('Nakshatra'), findsWidgets);
    expect(find.text('Lagna'), findsOneWidget);
    expect(find.text('Mahadasha'), findsOneWidget);

    // Prominent PDF Download CTA
    expect(find.text('Download PDF'), findsOneWidget);

    // Expandable full details button starts collapsed
    final expandBtn = find.text('View Full Details');
    expect(expandBtn, findsOneWidget);

    await tester.ensureVisible(expandBtn);
    await tester.tap(expandBtn);
    await tester.pumpAndSettle();

    // Now full details are visible
    expect(find.text('Hide Full Details'), findsOneWidget);
  });

  testWidgets('KundaliResultScreen (Control Variation A) renders without overflow on 360px screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithLocalization(KundaliResultScreen(kundali: sampleKundaliData)));
    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(KundaliResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('ApiClient.sanitizeFileSlug avoids repeated underscores for non-ASCII names', () {
    expect(ApiClient.sanitizeFileSlug('अनिकेत जोशी', '06-09-2000'), equals('06-09-2000'));
    expect(ApiClient.sanitizeFileSlug('Aniket   Joshi!', 'report'), equals('Aniket_Joshi'));
    expect(ApiClient.sanitizeFileSlug('   ', 'report'), equals('report'));
  });
}
