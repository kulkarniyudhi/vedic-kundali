import 'package:material_ui/material_ui.dart';

class AppTheme {
  // Brand Colors
  static const Color primarySaffron = Color(0xFFD45D00);
  static const Color deepVermilion = Color(0xFFC84B31);
  static const Color warmMaroon = Color(0xFF8B2616);
  static const Color goldAccent = Color(0xFFE5A65E);
  static const Color darkWood = Color(0xFF2C1A11);
  static const Color textMuted = Color(0xFF6B4F3B);

  // Surface & Backgrounds
  static const Color backgroundParchment = Color(0xFFFAF6F0);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFEDE0D0);
  static const Color chipBackground = Color(0xFFF4ECE1);

  // Status Colors
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color dangerRed = Color(0xFFC62828);
  static const Color dangerBg = Color(0xFFFFEBEE);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color warningBg = Color(0xFFFFF3E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepVermilion,
        primary: deepVermilion,
        secondary: primarySaffron,
        surface: backgroundParchment,
        onSurface: darkWood,
      ),
      scaffoldBackgroundColor: backgroundParchment,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardSurface,
        foregroundColor: deepVermilion,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: deepVermilion,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardSurface,
        indicatorColor: primarySaffron.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: deepVermilion,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySaffron,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepVermilion,
          side: const BorderSide(color: deepVermilion, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primarySaffron, width: 1.8),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.6), fontSize: 14),
      ),
    );
  }
}
