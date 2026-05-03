import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Adaptive gradient background — uses aurora mesh for dark, soft gradient for light
class LightGradientBackground extends StatelessWidget {
  final Widget child;

  const LightGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  AppTheme.deepNavy,
                  AppTheme.backgroundDark,
                  Color(0xFF0E1230),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  AppTheme.backgroundLight,
                  Color(0xFFE8EBFF),
                  Color(0xFFF5F3FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: child,
    );
  }
}
