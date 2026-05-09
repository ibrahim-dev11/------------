import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === BRAND PALETTE ===
  static const Color primary = Color(0xFF534AB7);
  static const Color primaryDark = Color(0xFF3E389A);
  static const Color primaryLight = Color(0xFF7F77DD);

  static const Color secondary = Color(0xFF7F77DD);
  static const Color secondaryDark = Color(0xFF534AB7);

  static const Color success = Color(0xFF1D9E75);
  static const Color successLight = Color(0xFF25C28F);

  static const Color accent = Color(0xFFD4A017);
  static const Color accentGold = Color(0xFFE8B84B);

  // === ICON CATEGORY COLORS ===
  static const Color iconInstitution = Color(0xFF534AB7);
  static const Color iconCV = Color(0xFF1D9E75);
  static const Color iconTeacher = Color(0xFFD4A017);
  static const Color iconUniversity = Color(0xFFE05C8A);
  static const Color iconBook = Color(0xFF3A7DD4);
  static const Color iconContact = Color(0xFFE06B3A);
  static const Color iconStudent = Color(0xFF3AAD6E);
  static const Color iconMessage = Color(0xFF534AB7);

  // === GRADIENTS ===
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF534AB7), Color(0xFF7F77DD)],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D9E75), Color(0xFF25C28F)],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A017), Color(0xFFE8B84B)],
  );

  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a1a1a), Color(0xFF252525)],
  );

  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF534AB7), Color(0xFF3E389A), Color(0xFF2D2880)],
  );

  // === DARK THEME BACKGROUNDS ===
  static const Color darkBg = Color(0xFF1a1a1a);
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkCard = Color(0xFF2E2E2E);
  static const Color darkCardElevated = Color(0xFF383838);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkDivider = Color(0xFF2E2E2E);

  // === LIGHT THEME BACKGROUNDS ===
  static const Color lightBg = Color(0xFFF4F3FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF8F7FF);
  static const Color lightBorder = Color(0xFFE6E3FF);
  static const Color lightDivider = Color(0xFFEEECFF);

  // === TEXT COLORS ===
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1a1a1a);
  static const Color textGrey = Color(0xFF8E8BAD);
  static const Color textGreyLight = Color(0xFFB5B3CF);
  static const Color textMuted = Color(0xFF7470A0);

  // === SEMANTIC COLORS ===
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // === GLASS EFFECT ===
  static Color glassLight = Colors.white.withOpacity(0.12);
  static Color glassDark = Colors.black.withOpacity(0.2);
  static Color glassBorder = Colors.white.withOpacity(0.18);

  // === INSTITUTION TYPE COLORS ===
  static const Map<String, Color> typeColors = {
    'university': Color(0xFF534AB7),
    'institute': Color(0xFF7F77DD),
    'school': Color(0xFF1D9E75),
    'kindergarten': Color(0xFFD4A017),
    'language_center': Color(0xFF3A7DD4),
    'college': Color(0xFFE05C8A),
    'other': Color(0xFF7470A0),
  };

  static Color typeColor(String? type) =>
      typeColors[type] ?? primary;

  // legacy aliases
  static const Color purple = Color(0xFF7F77DD);
  static const Color purpleLight = Color(0xFFA5A0E8);
  static const Gradient cyanGradient = successGradient;
}
