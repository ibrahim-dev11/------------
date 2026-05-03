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
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _pulseCtrl;
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

    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
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
        transitionDuration: const Duration(milliseconds: 800),
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
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: Stack(
        children: [
          // ── Animated aurora mesh background ──
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              final t = _bgCtrl.value;
              return Stack(
                children: [
                  // Base gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF060919),
                          AppTheme.backgroundDark,
                          Color(0xFF0E1230),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Violet orb
                  Positioned(
                    top: -100 + t * 50,
                    right: -60 + t * 40,
                    child: _GlowOrb(
                      size: 350,
                      color: AppTheme.auroraViolet.withValues(alpha: 0.2),
                    ),
                  ),
                  // Cyan orb
                  Positioned(
                    bottom: -120 + t * 30,
                    left: -80 - t * 20,
                    child: _GlowOrb(
                      size: 300,
                      color: AppTheme.auroraCyan.withValues(alpha: 0.15),
                    ),
                  ),
                  // Pink orb
                  Positioned(
                    top: size.height * 0.4 - t * 30,
                    left: size.width * 0.3 + t * 20,
                    child: _GlowOrb(
                      size: 200,
                      color: AppTheme.auroraPink.withValues(alpha: 0.08),
                    ),
                  ),
                  // Green orb
                  Positioned(
                    bottom: size.height * 0.3 + t * 20,
                    right: -30 + t * 40,
                    child: _GlowOrb(
                      size: 160,
                      color: AppTheme.auroraGreen.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Heavy blur for mesh effect ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          // ── Floating particles ──
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(
                progress: _particleCtrl.value,
                particleCount: 30,
              ),
            ),
          ),

          // ── Orbit rings with glow ──
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_particleCtrl, _pulseCtrl]),
              builder: (_, __) => CustomPaint(
                size: const Size(320, 320),
                painter: _AuroraOrbitPainter(
                  angle: _particleCtrl.value * 2 * math.pi,
                  pulse: _pulseCtrl.value,
                ),
              ),
            ),
          ),

          // ── Main content ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Logo with pulse glow
                AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _buildLogo(),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Text + loader
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          // App name with aurora gradient
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFD0CCFF),
                                AppTheme.auroraCyan,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'خوێندنگاکانم',
                              style: TextStyle(
                                fontFamily: 'AppFont',
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'دلیلی دامەزراوە پەروەردەییەکان',
                            style: TextStyle(
                              fontFamily: 'AppFont',
                              fontSize: 14,
                              color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 56),
                          // Aurora pulsing loader
                          _AuroraLoader(ctrl: _pulseCtrl),
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
                opacity: _textOpacity.value * 0.3,
                child: const Text(
                  'v2.0.0 — Midnight Aurora',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryDark,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final pulse = _pulseCtrl.value;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3 + pulse * 0.15),
            blurRadius: 40 + pulse * 10,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.auroraCyan.withValues(alpha: 0.15 + pulse * 0.1),
            blurRadius: 60,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Glass background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.9),
                    AppTheme.auroraViolet.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Light streak
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 3D graduation cap image
            Center(
              child: Image.asset(
                'assets/images/3d/graduation_cap.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  '🎓',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glow Orb ──
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

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

// ── Aurora Orbit Painter ──
class _AuroraOrbitPainter extends CustomPainter {
  final double angle;
  final double pulse;
  _AuroraOrbitPainter({required this.angle, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring with gradient-like effect
    final ringPaint1 = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.06 + pulse * 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 140, ringPaint1);

    // Middle ring
    final ringPaint2 = Paint()
      ..color = AppTheme.auroraCyan.withValues(alpha: 0.04 + pulse * 0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 105, ringPaint2);

    // Inner ring
    final ringPaint3 = Paint()
      ..color = AppTheme.auroraPink.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, 75, ringPaint3);

    // Orbiting dot 1 — Purple
    final dot1 = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final pos1 = Offset(
      center.dx + 140 * math.cos(angle),
      center.dy + 140 * math.sin(angle),
    );
    canvas.drawCircle(pos1, 4 + pulse * 2, dot1);
    // Dot1 glow
    final glow1 = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos1, 10 + pulse * 4, glow1);

    // Orbiting dot 2 — Cyan
    final dot2 = Paint()
      ..color = AppTheme.auroraCyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final pos2 = Offset(
      center.dx + 105 * math.cos(-angle * 1.3),
      center.dy + 105 * math.sin(-angle * 1.3),
    );
    canvas.drawCircle(pos2, 3 + pulse, dot2);
    final glow2 = Paint()
      ..color = AppTheme.auroraCyan.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos2, 8 + pulse * 3, glow2);

    // Orbiting dot 3 — Pink
    final dot3 = Paint()
      ..color = AppTheme.auroraPink.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final pos3 = Offset(
      center.dx + 75 * math.cos(angle * 2),
      center.dy + 75 * math.sin(angle * 2),
    );
    canvas.drawCircle(pos3, 2.5 + pulse * 0.5, dot3);
  }

  @override
  bool shouldRepaint(_AuroraOrbitPainter old) => true;
}

// ── Floating Particles Painter ──
class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;
  _ParticlePainter({required this.progress, this.particleCount = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final colors = [
      AppTheme.primary,
      AppTheme.auroraCyan,
      AppTheme.auroraGreen,
      AppTheme.auroraPink,
    ];

    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final radius = 1.0 + random.nextDouble() * 2.5;
      final color = colors[i % colors.length];

      final x = baseX + math.sin(progress * 2 * math.pi * speed + i) * 20;
      final y = baseY + math.cos(progress * 2 * math.pi * speed + i) * 15;

      final opacity = 0.15 + 0.2 * math.sin(progress * 2 * math.pi + i * 0.5);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── Aurora Loader ──
class _AuroraLoader extends StatelessWidget {
  final AnimationController ctrl;
  const _AuroraLoader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final colors = [
              AppTheme.primary,
              AppTheme.auroraCyan,
              AppTheme.auroraGreen,
              AppTheme.auroraPink,
            ];
            final delay = i / 4;
            final phase = ((ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 0.5 + 0.5 * math.sin(phase * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(phase * math.pi);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[i].withValues(alpha: opacity),
                    boxShadow: [
                      BoxShadow(
                        color: colors[i].withValues(alpha: opacity * 0.5),
                        blurRadius: 8,
                      ),
                    ],
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
