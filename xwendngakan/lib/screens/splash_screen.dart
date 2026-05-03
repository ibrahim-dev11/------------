import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'language_screen.dart';
import 'onboarding_screen.dart';
import 'section_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _textCtrl;
  late AnimationController _orbitCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    if (_hasNavigated) return;
    final prov = context.read<AppProvider>();
    if (prov.isInitDone) {
      _doNavigate(prov);
    } else {
      void listener() {
        if (prov.isInitDone && mounted && !_hasNavigated) {
          prov.removeListener(listener);
          _doNavigate(prov);
        }
      }
      prov.addListener(listener);
    }
  }

  void _doNavigate(AppProvider prov) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final Widget dest;
    if (!prov.hasCompletedOnboarding) {
      dest = const OnboardingScreen();
    } else if (!prov.hasSelectedLanguage) {
      dest = const LanguageScreen();
    } else {
      dest = const SectionSelectionScreen();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _bgCtrl.dispose();
    _textCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // ── Animated aurora background ──
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              final t = _bgCtrl.value;
              return Stack(
                children: [
                  Positioned(
                    top: -120 + t * 40,
                    right: -80 + t * 30,
                    child: _AuroraBlob(
                      size: 320,
                      color: AppTheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  Positioned(
                    bottom: -100 + t * 20,
                    left: -60 - t * 20,
                    child: _AuroraBlob(
                      size: 280,
                      color: AppTheme.accent.withValues(alpha: 0.14),
                    ),
                  ),
                  Positioned(
                    top: 200 - t * 30,
                    left: 30 + t * 10,
                    child: _AuroraBlob(
                      size: 160,
                      color: AppTheme.success.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Blur overlay ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),

          // ── Orbit rings ──
          Center(
            child: AnimatedBuilder(
              animation: _orbitCtrl,
              builder: (_, __) {
                return CustomPaint(
                  size: const Size(300, 300),
                  painter: _OrbitPainter(angle: _orbitCtrl.value * 2 * math.pi),
                );
              },
            ),
          ),

          // ── Main content ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _LogoWidget(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Text
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFD0CCFF),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'خوێندنگاکانم',
                              style: TextStyle(
                                fontFamily: 'AppFont',
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'دلیلی دامەزراوە پەروەردەییەکان',
                            style: TextStyle(
                              fontFamily: 'AppFont',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          // Pulsing dots loader
                          _DotsLoader(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom version ──
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value * 0.4,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aurora Blob ──
class _AuroraBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _AuroraBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          radius: 0.8,
        ),
      ),
    );
  }
}

// ── Logo Widget ──
class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppTheme.primary,
        boxShadow: AppTheme.coloredShadow(AppTheme.primary),
      ),
      child: const Center(
        child: Text('📚', style: TextStyle(fontSize: 46)),
      ),
    );
  }
}

// ── Orbit Painter ──
class _OrbitPainter extends CustomPainter {
  final double angle;
  _OrbitPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring
    final ringPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 130, ringPaint);

    // Middle ring
    ringPaint.color = AppTheme.accent.withValues(alpha: 0.04);
    canvas.drawCircle(center, 95, ringPaint);

    // Orbiting dot 1
    final dot1 = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final pos1 = Offset(
      center.dx + 130 * math.cos(angle),
      center.dy + 130 * math.sin(angle),
    );
    canvas.drawCircle(pos1, 5, dot1);

    // Orbiting dot 2
    final dot2 = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final pos2 = Offset(
      center.dx + 95 * math.cos(-angle * 1.5),
      center.dy + 95 * math.sin(-angle * 1.5),
    );
    canvas.drawCircle(pos2, 4, dot2);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.angle != angle;
}

// ── Dots Loader ──
class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(phase * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
