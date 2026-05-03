import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium glassmorphic card with gradient border and neon glow
class AuroraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final List<Color>? glowColors;
  final double glowIntensity;
  final double backgroundOpacity;
  final VoidCallback? onTap;
  final bool enableBlur;

  const AuroraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.glowColors,
    this.glowIntensity = 0.15,
    this.backgroundOpacity = 0.06,
    this.onTap,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = glowColors ?? [AppTheme.primary, AppTheme.accent];

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.first.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: glowIntensity * 0.5),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colors.last.withValues(alpha: glowIntensity * 0.2),
            blurRadius: 50,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: enableBlur
              ? ImageFilter.blur(sigmaX: 16, sigmaY: 16)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: backgroundOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: backgroundOpacity + 0.02),
                  Colors.white.withValues(alpha: backgroundOpacity),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
