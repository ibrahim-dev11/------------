import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium animated mesh gradient background with floating aurora orbs
class AuroraMeshBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const AuroraMeshBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<AuroraMeshBackground> createState() => _AuroraMeshBackgroundState();
}

class _AuroraMeshBackgroundState extends State<AuroraMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (widget.animate) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = widget.animate ? _ctrl.value : 0.5;
        return Stack(
          children: [
            // Base gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.deepNavy,
                    AppTheme.backgroundDark,
                    Color(0xFF0E1230),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Aurora Orb 1 — Violet
            Positioned(
              top: -60 + t * 40,
              right: -40 + t * 30,
              child: _AuroraOrb(
                size: 300,
                color: AppTheme.auroraViolet.withValues(alpha: 0.15),
              ),
            ),

            // Aurora Orb 2 — Cyan
            Positioned(
              bottom: -80 + t * 30,
              left: -50 - t * 20,
              child: _AuroraOrb(
                size: 260,
                color: AppTheme.auroraCyan.withValues(alpha: 0.12),
              ),
            ),

            // Aurora Orb 3 — Pink
            Positioned(
              top: 300 - t * 40,
              left: 40 + t * 20,
              child: _AuroraOrb(
                size: 180,
                color: AppTheme.auroraPink.withValues(alpha: 0.08),
              ),
            ),

            // Aurora Orb 4 — Green
            Positioned(
              bottom: 200 + t * 20,
              right: -20 + t * 30,
              child: _AuroraOrb(
                size: 140,
                color: AppTheme.auroraGreen.withValues(alpha: 0.06),
              ),
            ),

            // Blur overlay for smooth mesh effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),

            // Subtle noise / grain effect
            Positioned.fill(
              child: CustomPaint(
                painter: _GrainPainter(opacity: 0.03),
              ),
            ),

            // Content
            widget.child,
          ],
        );
      },
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _AuroraOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0), Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          radius: 0.8,
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  _GrainPainter({this.opacity = 0.03});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false;
}
