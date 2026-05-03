import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final bool hasGlow;
  final Color? glowColor;
  final Color? color;
  final bool showShadow;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.blur = 12.0,
    this.opacity = 0.7,
    this.padding,
    this.hasGlow = false,
    this.glowColor,
    this.color,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? Colors.white : Colors.white);
    final effectiveOpacity = isDark ? (opacity > 0.3 ? 0.06 : opacity * 0.1) : opacity;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.6);
    final shadowCol = glowColor ?? (isDark ? AppTheme.primary : AppTheme.primary);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (showShadow)
            BoxShadow(
              color: shadowCol.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          if (hasGlow)
            BoxShadow(
              color: (glowColor ?? AppTheme.primary).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: effectiveOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
