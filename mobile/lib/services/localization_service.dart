import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale('mr'),
    Locale('en'),
    Locale('hi'),
  ];

  static const String translationPath = 'assets/translations';
  static const Locale fallbackLocale = Locale('mr');
  static const Locale startLocale = Locale('mr');

  static String _currentLanguage = 'mr';

  /// Currently active language code (e.g. 'mr', 'hi', 'en').
  static String get currentLanguage => _currentLanguage;

  static set currentLanguage(String lang) {
    if (supportedLocales.any((loc) => loc.languageCode == lang)) {
      _currentLanguage = lang;
    }
  }

  /// Initialize and restore stored language preference.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_selected_locale');
      if (saved != null && supportedLocales.any((loc) => loc.languageCode == saved)) {
        _currentLanguage = saved;
      }
    } catch (_) {}
  }

  static bool isMarathi(BuildContext context) => context.locale.languageCode == 'mr';
  static bool isHindi(BuildContext context) => context.locale.languageCode == 'hi';
  static bool isEnglish(BuildContext context) => context.locale.languageCode == 'en';

  static String getLanguageCode(BuildContext context) => context.locale.languageCode;

  static Future<void> changeLanguage(BuildContext context, String langCode) async {
    _currentLanguage = langCode;
    await context.setLocale(Locale(langCode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_selected_locale', langCode);
    } catch (_) {}
  }
}

class AppStrings {
  // Common
  static String get ok => 'ok'.tr();
  static String get cancel => 'cancel'.tr();
  static String get save => 'save'.tr();
  static String get verify => 'verify'.tr();
  static String get resend => 'resend'.tr();
  static String get requiredField => 'required_field'.tr();
  static String get loading => 'loading'.tr();
  static String get error => 'error'.tr();
  static String get success => 'success'.tr();
  static String get yes => 'yes'.tr();
  static String get no => 'no'.tr();
  static String get close => 'close'.tr();
  static String get back => 'back'.tr();
  static String get all => 'all'.tr();
  static String get empty => 'empty'.tr();

  // Navigation / Tabs
  static String get tabKundali => 'tab_kundali'.tr();
  static String get tabGunMilan => 'tab_gunmilan'.tr();
  static String get tabCitySearch => 'tab_city_search'.tr();
  static String get tabSettings => 'tab_settings'.tr();

  // Language Selection Screen
  static String get selectLanguageTitle => 'select_language_title'.tr();
  static String get selectLanguageSubtitle => 'select_language_subtitle'.tr();
  static String get marathiName => 'marathi_name'.tr();
  static String get marathiSub => 'marathi_sub'.tr();
  static String get englishName => 'english_name'.tr();
  static String get englishSub => 'english_sub'.tr();
  static String get hindiName => 'hindi_name'.tr();
  static String get hindiSub => 'hindi_sub'.tr();
  static String get continueButton => 'continue_button'.tr();

  // Login Screen
  static String get loginTitle => 'login_title'.tr();
  static String get appName => 'app_name'.tr();
  static String get loginSubtitle => 'login_subtitle'.tr();
  static String get emailLabel => 'email_label'.tr();
  static String get emailHint => 'email_hint'.tr();
  static String get enterEmailPrompt => 'enter_email_prompt'.tr();
  static String get enterValidEmailPrompt => 'enter_valid_email_prompt'.tr();
  static String get passwordLabel => 'password_label'.tr();
  static String get enterPasswordPrompt => 'enter_password_prompt'.tr();
  static String get passwordMinLengthPrompt => 'password_min_length_prompt'.tr();
  static String get rememberMe => 'remember_me'.tr();
  static String get forgotPassword => 'forgot_password'.tr();
  static String get loginButton => 'login_button'.tr();
  static String get sendingOtp => 'sending_otp'.tr();
  static String get loggingIn => 'logging_in'.tr();
  static String get dontHaveAccount => 'dont_have_account'.tr();
  static String get signUpLink => 'sign_up_link'.tr();

  // OTP Dialog
  static String get otpDialogTitle => 'otp_dialog_title'.tr();
  static String get otpDialogSubtitle => 'otp_dialog_subtitle'.tr();
  static String get otpFieldLabel => 'otp_field_label'.tr();
  static String get enterSixDigitOtp => 'enter_six_digit_otp'.tr();
  static String get otpResentSuccess => 'otp_resent_success'.tr();
  static String get verifyAndLogin => 'verify_and_login'.tr();
  static String get verifyAndRegister => 'verify_and_register'.tr();
  static String get welcomeUser => 'welcome_user'.tr();
  static String get loginSuccess => 'login_success'.tr();

  // Reset Password Dialog
  static String get resetPasswordTitle => 'reset_password_title'.tr();
  static String get resetPasswordDesc => 'reset_password_desc'.tr();
  static String get sendLink => 'send_link'.tr();
  static String get resetLinkSent => 'reset_link_sent'.tr();

  // Signup Screen
  static String get signupTitle => 'signup_title'.tr();
  static String get createAccountTitle => 'create_account_title'.tr();
  static String get signupSubtitle => 'signup_subtitle'.tr();
  static String get fullNameLabel => 'full_name_label'.tr();
  static String get fullNameHint => 'full_name_hint'.tr();
  static String get enterFullNamePrompt => 'enter_full_name_prompt'.tr();
  static String get mobileOptionalLabel => 'mobile_optional_label'.tr();
  static String get mobileValidationPrompt => 'mobile_validation_prompt'.tr();
  static String get createPasswordLabel => 'create_password_label'.tr();
  static String get confirmPasswordLabel => 'confirm_password_label'.tr();
  static String get confirmPasswordPrompt => 'confirm_password_prompt'.tr();
  static String get passwordsDoNotMatch => 'passwords_do_not_match'.tr();
  static String get acceptTerms => 'accept_terms'.tr();
  static String get mustAcceptTerms => 'must_accept_terms'.tr();
  static String get getOtpAndRegister => 'get_otp_and_register'.tr();
  static String get alreadyHaveAccount => 'already_have_account'.tr();
  static String get loginLink => 'login_link'.tr();
  static String get signupSuccess => 'signup_success'.tr();

  // Kundali Input Screen
  static String get kundaliInputTitle => 'kundali_input_title'.tr();
  static String get sampleButton => 'sample_button'.tr();
  static String get birthDetailsSection => 'birth_details_section'.tr();
  static String get birthDetailsSubtitle => 'birth_details_subtitle'.tr();
  static String get personName => 'person_name'.tr();
  static String get birthDate => 'birth_date'.tr();
  static String get birthTime => 'birth_time'.tr();
  static String get birthPlace => 'birth_place'.tr();
  static String get latitude => 'latitude'.tr();
  static String get longitude => 'longitude'.tr();
  static String get ayanamshaSystem => 'ayanamsha_system'.tr();
  static String get lahiriAyanamsha => 'lahiri_ayanamsha'.tr();
  static String get kpAyanamsha => 'kp_ayanamsha'.tr();
  static String get calculating => 'calculating'.tr();
  static String get calculateKundali => 'calculate_kundali'.tr();

  // Kundali Result Screen
  static String get horoscopeTitle => 'horoscope_title'.tr();
  static String get downloadPdf => 'download_pdf'.tr();
  static String get pdfReport => 'pdf_report'.tr();
  static String get pdfGenerating => 'pdf_generating'.tr();
  static String pdfReady(String filename) => 'pdf_ready'.tr(args: [filename]);
  static String pdfError(String err) => 'pdf_error'.tr(args: [err]);
  static String get pdfSheetTitle => 'pdf_sheet_title'.tr();
  static String get pdfSheetDesc => 'pdf_sheet_desc'.tr();
  static String get viewInReader => 'view_in_reader'.tr();
  static String get openPdf => 'open_pdf'.tr();
  static String get tabCharts => 'tab_charts'.tr();
  static String get tabPanchang => 'tab_panchang'.tr();
  static String get tabPlanets => 'tab_planets'.tr();
  static String get tabMahadasha => 'tab_mahadasha'.tr();
  static String get tabAvakhada => 'tab_avakhada'.tr();
  static String get chartLagna => 'chart_lagna'.tr();
  static String get chartNavamsha => 'chart_navamsha'.tr();
  static String get chartChalit => 'chart_chalit'.tr();
  static String get chartChandra => 'chart_chandra'.tr();
  static String get showDegrees => 'show_degrees'.tr();
  static String get houseAnalysis => 'house_analysis'.tr();
  static String houseItem(int h, int r) => 'house_item'.tr(args: [h.toString(), r.toString()]);
  static String get panchangSectionTitle => 'panchang_section_title'.tr();
  static String get panchangSectionSub => 'panchang_section_sub'.tr();
  static String get tithi => 'tithi'.tr();
  static String get nakshatra => 'nakshatra'.tr();
  static String nakshatraDetail(String name, int pada, String letter) =>
      'nakshatra_detail'.tr(args: [name, pada.toString(), letter]);
  static String get yoga => 'yoga'.tr();
  static String get karana => 'karana'.tr();
  static String get moonSign => 'moon_sign'.tr();
  static String get hinduCalendarTitle => 'hindu_calendar_title'.tr();
  static String get hinduCalendarSub => 'hindu_calendar_sub'.tr();
  static String get dayName => 'day_name'.tr();
  static String get hinduMonth => 'hindu_month'.tr();
  static String get shakaSamvat => 'shaka_samvat'.tr();
  static String get vikramKartik => 'vikram_kartik'.tr();
  static String get vikramChaitra => 'vikram_chaitra'.tr();
  static String get ishtaGhati => 'ishta_ghati'.tr();
  static String get years => 'years'.tr();
  static String get duration => 'duration'.tr();
  static String get to => 'to'.tr();
  static String mahadashaTitle(String planet) => 'mahadasha_title'.tr(args: [planet]);
  static String padaSyllable(int pada, String syllable) => 'pada_syllable'.tr(args: [pada.toString(), syllable]);
  static String get avakhadaTitle => 'avakhada_title'.tr();
  static String get avakhadaSub => 'avakhada_sub'.tr();
  static String get varna => 'varna'.tr();
  static String get tattva => 'tattva'.tr();
  static String get vashya => 'vashya'.tr();
  static String get yoni => 'yoni'.tr();
  static String get gana => 'gana'.tr();
  static String get nadi => 'nadi'.tr();
  static String get varga => 'varga'.tr();
  static String get yunja => 'yunja'.tr();

  // Gun Milan
  static String get gunMilanTitle => 'gunmilan_title'.tr();
  static String get samplePair => 'sample_pair'.tr();
  static String get samplePairLoaded => 'sample_pair_loaded'.tr();
  static String get boyBirthDetails => 'boy_birth_details'.tr();
  static String get girlBirthDetails => 'girl_birth_details'.tr();
  static String get boyLabel => 'boy_label'.tr();
  static String get girlLabel => 'girl_label'.tr();
  static String get checkCompatibility => 'check_compatibility'.tr();
  static String get checkingCompatibility => 'checking_compatibility'.tr();
  static String get gunMilanErrorTitle => 'gunmilan_error_title'.tr();
  static String get gunMilanReportTitle => 'gunmilan_report_title'.tr();
  static String get downloadGunMilanPdf => 'download_gunmilan_pdf'.tr();
  static String get pdfGunMilanGenerating => 'pdf_gunmilan_generating'.tr();
  static String get compatibilityMatch => 'compatibility_match'.tr();
  static String get compatibilityLow => 'compatibility_low'.tr();
  static String get totalGunas => 'total_gunas'.tr();
  static String get mangalDoshaAnalysis => 'mangal_dosha_analysis'.tr();
  static String get mangalDoshaSub => 'mangal_dosha_sub'.tr();
  static String get hasMangal => 'has_mangal'.tr();
  static String get noMangal => 'no_mangal'.tr();
  static String houseChalit(int h) => 'house_chalit'.tr(args: [h.toString()]);
  static String get ashtakootDetails => 'ashtakoot_details'.tr();
  static String get ashtakootSub => 'ashtakoot_sub'.tr();
  static String maxPointsLabel(dynamic pts) => 'max_points'.tr(args: [pts.toString()]);
  static String get panchangComparison => 'panchang_comparison'.tr();
  static String get lagnaComparison => 'lagna_comparison'.tr();
  static String boyTitle(String name) => 'boy_title'.tr(args: [name]);
  static String girlTitle(String name) => 'girl_title'.tr(args: [name]);

  // City Search
  static String get selectCityTitle => 'select_city_title'.tr();
  static String get searchCityTitle => 'search_city_title'.tr();
  static String get searchCityHint => 'search_city_hint'.tr();
  static String get searchingCities => 'searching_cities'.tr();
  static String get popularCities => 'popular_cities'.tr();
  static String get noCitiesFound => 'no_cities_found'.tr();
  static String get checkSpellingHint => 'check_spelling_hint'.tr();
  static String get showAllCities => 'show_all_cities'.tr();
  static String get selectBtn => 'select_btn'.tr();
  static String citiesCount(int count) => 'cities_count'.tr(args: [count.toString()]);
  static String get localDbBadge => 'local_db_badge'.tr();
  static String citySelected(String name, double lat, double lng) =>
      'city_selected'.tr(args: [name, lat.toString(), lng.toString()]);
  static String latLngDisplay(double lat, double lng) =>
      'lat_lng_display'.tr(args: [lat.toString(), lng.toString()]);

  // Settings
  static String get settingsTitle => 'settings_title'.tr();
  static String get userProfile => 'user_profile'.tr();
  static String get activeStatus => 'active_status'.tr();
  static String get logOutButton => 'logout_button'.tr();
  static String get confirmLogoutTitle => 'confirm_logout_title'.tr();
  static String get confirmLogoutMsg => 'confirm_logout_msg'.tr();
  static String get confirmLogoutBtn => 'confirm_logout_btn'.tr();
  static String get backendServerSection => 'backend_server_section'.tr();
  static String get serverConnectivity => 'server_connectivity'.tr();
  static String get pingServer => 'ping_server'.tr();
  static String get changeUrl => 'change_url'.tr();
  static String get editServerUrlTitle => 'edit_server_url_title'.tr();
  static String get serverUrlDesc => 'server_url_desc'.tr();
  static String get serverOnline => 'server_online'.tr();
  static String get serverOffline => 'server_offline'.tr();
  static String get serverChecking => 'server_checking'.tr();
  static String get astrologyOptions => 'astrology_options'.tr();
  static String get defaultAyanamsha => 'default_ayanamsha'.tr();
  static String get lahiriSub => 'lahiri_sub'.tr();
  static String get kpSub => 'kp_sub'.tr();
  static String get houseSystem => 'house_system'.tr();
  static String get placidusSub => 'placidus_sub'.tr();
  static String get wholesignSub => 'wholesign_sub'.tr();
  static String get languageSetting => 'language_setting'.tr();
  static String get includedFeatures => 'included_features'.tr();
  static String get softwareEngineTitle => 'software_engine_title'.tr();
  static String get softwareEngineSubtitle => 'software_engine_subtitle'.tr();
  static String get softwareEngineDesc => 'software_engine_desc'.tr();
  static String get featDiamondChart => 'feat_diamond_chart'.tr();
  static String get featDiamondChartSub => 'feat_diamond_chart_sub'.tr();
  static String get featGunMilan => 'feat_gunmilan'.tr();
  static String get featGunMilanSub => 'feat_gunmilan_sub'.tr();
  static String get featMahadasha => 'feat_mahadasha'.tr();
  static String get featMahadashaSub => 'feat_mahadasha_sub'.tr();
  static String get featCities => 'feat_cities'.tr();
  static String get featCitiesSub => 'feat_cities_sub'.tr();
}
