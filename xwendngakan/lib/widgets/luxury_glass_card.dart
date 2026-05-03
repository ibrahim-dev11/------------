import 'dart:ui';
import 'package:flutter/material.dart';

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
    this.blur = 10.0,
    this.opacity = 0.7,
    this.padding,
    this.hasGlow = false,
    this.glowColor,
    this.color,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (showShadow)
            BoxShadow(
              color: (glowColor ?? Colors.blue.withOpacity(0.1)),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          if (hasGlow)
            BoxShadow(
              color: (glowColor ?? Colors.blue).withOpacity(0.3),
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
              color: (color ?? Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
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
