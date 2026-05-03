import 'package:flutter/material.dart';

class AppTheme {
  // Primary – Vibrant Emerald
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryGlow = Color(0x3310B981);
  static const Color accent = Color(0xFF34D399);
  static const Color primary2 = Color(0xFF34D399);
  static const Color navy = Color(0xFF0F172A);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color lightBg = backgroundLight;
  static const Color darkBg = backgroundDark;

  // Card & Surface
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);
  static const Color darkSurface = cardDark;
  static const Color darkCard = cardDark;
  static const Color lightSurface = Color(0xFFF1F5F9);

  // Border & Divider
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color lightBorder = borderLight;
  static const Color darkBorder = borderDark;
  static const double radiusFull = 1000.0;

  // Text
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color lightText = textPrimaryDark;
  static const Color lightTextSub = textSecondaryDark;
  static const Color darkText = textPrimaryLight;
  static const Color textHint = Color(0xFF94A3B8);

  // Action Colors
  static const Color success = Color(0xFF10B981);
  static const Color success2 = Color(0xFF34D399);
  static const Color green = success;
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color gold = Color(0xFFFFD700);

  // Card & Surface Extras
  static const Color darkElevated = Color(0xFF1E293B);
  static const double radiusLg = 24.0;

  // Section Specific (Bento Colors)
  static const Color sectionBlue = Color(0xFFEFF6FF);
  static const Color sectionBlueDark = Color(0xFF1D4ED8);
  static const Color sectionPink = Color(0xFFFFF1F2);
  static const Color sectionPinkDark = Color(0xFFBE123C);
  static const Color sectionGreen = Color(0xFFECFDF5);
  static const Color sectionGreenDark = Color(0xFF047857);
  static const Color sectionPurple = Color(0xFFF5F3FF);
  static const Color sectionPurpleDark = Color(0xFF6D28D9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'NRT',
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderLight),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryLight),
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'NRT',
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'NRT',
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderDark),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryDark),
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'NRT',
      ),
    ),
  );

  // Text Extras
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral600 = Color(0xFF475569);

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animMed = Duration(milliseconds: 400);

  // Helpers
  static List<BoxShadow> softShadow([dynamic arg, Color? shadowColor]) {
    bool isDark = false;
    Color? col;
    
    if (arg is bool) {
      isDark = arg;
      col = shadowColor;
    } else if (arg is Color) {
      col = arg;
    }
    
    return [
      BoxShadow(
        color: col ?? (isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF475569).withValues(alpha: 0.08)),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ];
  }

  static List<BoxShadow> premiumShadow([dynamic arg]) => softShadow(arg);

  static List<BoxShadow> coloredShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static BoxDecoration glassDecoration({bool isDark = false, double radius = 24}) => BoxDecoration(
    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.4),
    ),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = primaryGradient;
  static const LinearGradient emeraldGlowGradient = primaryGradient;
}
