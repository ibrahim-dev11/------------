import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === BRAND PALETTE — نەیڵۆنی + زێڕی ===
  static const Color primary     = Color(0xFFC49A3C); // زێڕی سەرەکی
  static const Color primaryDark = Color(0xFF8A6520); // زێڕی تاریک
  static const Color primaryLight= Color(0xFFE0B856); // زێڕی ڕووناک

  static const Color secondary   = Color(0xFFE0B856);
  static const Color secondaryDark = Color(0xFFC49A3C);

  static const Color success     = Color(0xFF22C55E);
  static const Color successLight= Color(0xFF4ADE80);

  static const Color accent      = Color(0xFFC49A3C);
  static const Color accentGold  = Color(0xFFE0B856);

  // === ICON CATEGORY COLORS ===
  static const Color iconInstitution = Color(0xFFC49A3C);
  static const Color iconCV          = Color(0xFF22C55E);
  static const Color iconTeacher     = Color(0xFFE0B856);
  static const Color iconUniversity  = Color(0xFFE05C8A);
  static const Color iconBook        = Color(0xFF3A7DD4);
  static const Color iconContact     = Color(0xFFE06B3A);
  static const Color iconStudent     = Color(0xFF3AAD6E);
  static const Color iconMessage     = Color(0xFFC49A3C);

  // === GRADIENTS ===
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8A6520), Color(0xFFC49A3C)],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D9E75), Color(0xFF25C28F)],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8A6520), Color(0xFFE0B856)],
  );

  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF090D16), Color(0xFF0F1624)],
  );

  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF090D16), Color(0xFF0F1624), Color(0xFF16203A)],
  );

  // === DARK THEME BACKGROUNDS — نەیڵۆنی ===
  static const Color darkBg            = Color(0xFF090D16);
  static const Color darkSurface       = Color(0xFF0F1624);
  static const Color darkCard          = Color(0xFF16203A);
  static const Color darkCardElevated  = Color(0xFF1E2D48);
  static const Color darkBorder        = Color(0x21C49A3C); // rgba(196,154,60,.13)
  static const Color darkBorder2       = Color(0x47C49A3C); // rgba(196,154,60,.28)
  static const Color darkDivider       = Color(0xFF16203A);

  // === LIGHT THEME BACKGROUNDS ===
  static const Color lightBg           = Color(0xFFF8F5EC);
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightCard         = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFFDF8EE);
  static const Color lightBorder       = Color(0xFFE8D9B0);
  static const Color lightDivider      = Color(0xFFF0E6C8);

  // === TEXT COLORS ===
  static const Color textWhite     = Color(0xFFF5F0E8); // گەرمی سپی — لەسەر تاریک
  static const Color textDark      = Color(0xFF1A1A2E); // تاریک — لەسەر ڕووناک
  static const Color textGrey      = Color(0xFFB8CDDE); // دووەم — کونتراست بەرز لەسەر کارت تاریک
  static const Color textGreyLight = Color(0xFFD0E0EC); // سێیەم — ئاخاوتنی
  static const Color textMuted     = Color(0xFF7A9AB5); // مستەد dark
  static const Color textMutedLight= Color(0xFF5E6E82); // مستەد light mode

  // === SEMANTIC COLORS ===
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // === GLASS EFFECT ===
  static Color glassLight  = const Color(0xFFC49A3C).withOpacity(0.08);
  static Color glassDark   = const Color(0xFF000000).withOpacity(0.3);
  static Color glassBorder = const Color(0xFFC49A3C).withOpacity(0.18);

  // === INSTITUTION TYPE COLORS ===
  static const Map<String, Color> typeColors = {
    'university':      Color(0xFFC49A3C),
    'institute':       Color(0xFFE0B856),
    'school':          Color(0xFF22C55E),
    'kindergarten':    Color(0xFF3A7DD4),
    'language_center': Color(0xFF3A7DD4),
    'college':         Color(0xFFE05C8A),
    'other':           Color(0xFF8DA4C0),
  };

  static Color typeColor(String? type) => typeColors[type] ?? primary;

  // legacy aliases
  static const Color purple      = Color(0xFFC49A3C);
  static const Color purpleLight = Color(0xFFE0B856);
  static const Gradient cyanGradient = successGradient;
}
