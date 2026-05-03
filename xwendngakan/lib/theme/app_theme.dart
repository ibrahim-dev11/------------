import 'package:flutter/material.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════
  // 🎨 MIDNIGHT AURORA — Color Palette
  // ══════════════════════════════════════════════════════

  // Primary — Rich Purple
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryGlow = Color(0x336C5CE7);
  static const Color accent = Color(0xFF00D2FF);
  static const Color primary2 = Color(0xFF00F5D4);

  // Deep Background
  static const Color navy = Color(0xFF0A0E27);
  static const Color deepNavy = Color(0xFF060919);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF0F2FF);
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color lightBg = backgroundLight;
  static const Color darkBg = backgroundDark;

  // Card & Surface
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF151937);
  static const Color darkSurface = cardDark;
  static const Color darkCard = cardDark;
  static const Color lightSurface = Color(0xFFE8EBFF);
  static const Color darkElevated = Color(0xFF1A1F3D);

  // Border & Divider
  static const Color borderLight = Color(0xFFD8DDFF);
  static const Color borderDark = Color(0xFF252A4A);
  static const Color lightBorder = borderLight;
  static const Color darkBorder = borderDark;
  static const double radiusFull = 1000.0;

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1F3D);
  static const Color textSecondaryLight = Color(0xFF6B7199);
  static const Color textPrimaryDark = Color(0xFFF0F2FF);
  static const Color textSecondaryDark = Color(0xFF8B92B3);
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color lightText = textPrimaryDark;
  static const Color lightTextSub = textSecondaryDark;
  static const Color darkText = textPrimaryLight;
  static const Color textHint = Color(0xFF8B92B3);

  // Action Colors
  static const Color success = Color(0xFF00F5D4);
  static const Color success2 = Color(0xFF00D2A8);
  static const Color green = success;
  static const Color info = Color(0xFF00D2FF);
  static const Color warning = Color(0xFFFFD700);
  static const Color danger = Color(0xFFFF6B9D);
  static const Color gold = Color(0xFFFFD700);

  // Aurora Colors
  static const Color auroraViolet = Color(0xFF8B5CF6);
  static const Color auroraCyan = Color(0xFF00D2FF);
  static const Color auroraPink = Color(0xFFFF6B9D);
  static const Color auroraGreen = Color(0xFF00F5D4);

  // Neutral
  static const Color neutral300 = Color(0xFFB8BDD6);
  static const Color neutral600 = Color(0xFF4A5078);

  // Section Specific (Bento Colors)
  static const Color sectionBlue = Color(0xFF0E1538);
  static const Color sectionBlueDark = Color(0xFF00D2FF);
  static const Color sectionPink = Color(0xFF1A0F1E);
  static const Color sectionPinkDark = Color(0xFFFF6B9D);
  static const Color sectionGreen = Color(0xFF0F1A15);
  static const Color sectionGreenDark = Color(0xFF00F5D4);
  static const Color sectionPurple = Color(0xFF150F2A);
  static const Color sectionPurpleDark = Color(0xFF8B5CF6);

  // ══════════════════════════════════════════════════════
  // 📏 Design Tokens
  // ══════════════════════════════════════════════════════
  static const double radiusLg = 24.0;
  static const double radiusMd = 16.0;
  static const double radiusSm = 12.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animMed = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ══════════════════════════════════════════════════════
  // 🌓 ThemeData
  // ══════════════════════════════════════════════════════

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'AppFont',
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
        fontFamily: 'AppFont',
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'AppFont',
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
        fontFamily: 'AppFont',
      ),
    ),
  );

  // ══════════════════════════════════════════════════════
  // 🎨 Gradients
  // ══════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [auroraViolet, auroraCyan, auroraGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [auroraPink, auroraViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGreenGradient = LinearGradient(
    colors: [auroraCyan, auroraGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkMeshGradient = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF151937), Color(0xFF0E1538)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = primaryGradient;
  static const LinearGradient emeraldGlowGradient = primaryGradient;

  // ══════════════════════════════════════════════════════
  // 🛠️ Helpers
  // ══════════════════════════════════════════════════════

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
        color: col ??
            (isDark
                ? Colors.black.withValues(alpha: 0.4)
                : primary.withValues(alpha: 0.08)),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> premiumShadow([dynamic arg]) => softShadow(arg);

  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.4}) => [
        BoxShadow(
          color: color.withValues(alpha: intensity),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: color.withValues(alpha: intensity * 0.3),
          blurRadius: 40,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> coloredShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static BoxDecoration glassDecoration({
    bool isDark = false,
    double radius = 24,
    double opacity = 0.06,
  }) =>
      BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.4),
        ),
      );

  /// Premium glassmorphic decoration with gradient border
  static BoxDecoration auroraGlassDecoration({
    double radius = 24,
    double bgOpacity = 0.06,
    List<Color>? borderColors,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: bgOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (borderColors ?? [primary]).first.withValues(alpha: 0.15),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColors ?? [primary]).first.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
