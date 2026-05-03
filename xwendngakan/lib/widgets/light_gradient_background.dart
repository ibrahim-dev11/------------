import 'package:flutter/material.dart';

class LightGradientBackground extends StatelessWidget {
  final Widget child;

  const LightGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD9E7FF), // Soft Blue
            Color(0xFFF0F5FF), // Lighter Blue
            Colors.white,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blurry shapes
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(300, const Color(0xFFA5C5FF).withOpacity(0.3)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _buildBlurCircle(400, const Color(0xFFBDD7FF).withOpacity(0.2)),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _buildBlurCircle(200, Colors.white.withOpacity(0.4)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
