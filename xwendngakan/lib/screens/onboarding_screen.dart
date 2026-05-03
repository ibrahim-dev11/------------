import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import 'language_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  late AnimationController _bgCtrl;
  late AnimationController _floatCtrl;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/3d/books_stack.png',
      titleKey: 'onboarding1Title',
      descKey: 'onboarding1Desc',
      gradient: [const Color(0xFF6C5CE7), const Color(0xFF00D2FF)],
      bgOrbs: [const Color(0xFF6C5CE7), const Color(0xFF8B5CF6)],
    ),
    _OnboardingData(
      image: 'assets/images/3d/magnifier.png',
      titleKey: 'onboarding2Title',
      descKey: 'onboarding2Desc',
      gradient: [const Color(0xFF00D2FF), const Color(0xFF00F5D4)],
      bgOrbs: [const Color(0xFF00D2FF), const Color(0xFF00F5D4)],
    ),
    _OnboardingData(
      image: 'assets/images/3d/map_pin.png',
      titleKey: 'onboarding3Title',
      descKey: 'onboarding3Desc',
      gradient: [const Color(0xFF00F5D4), const Color(0xFFFFD700)],
      bgOrbs: [const Color(0xFF00F5D4), const Color(0xFF00D2FF)],
    ),
    _OnboardingData(
      image: 'assets/images/3d/heart.png',
      titleKey: 'onboarding4Title',
      descKey: 'onboarding4Desc',
      gradient: [const Color(0xFFFF6B9D), const Color(0xFF6C5CE7)],
      bgOrbs: [const Color(0xFFFF6B9D), const Color(0xFF8B5CF6)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    HapticFeedback.mediumImpact();
    await context.read<AppProvider>().completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LanguageScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: Stack(
        children: [
          // ── Animated aurora background ──
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              final t = _bgCtrl.value;
              return Stack(
                children: [
                  // Base
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF060919), AppTheme.backgroundDark, Color(0xFF0E1230)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Dynamic orb 1
                  Positioned(
                    top: -80 + t * 40,
                    right: -40 + t * 30,
                    child: _GlowOrb(
                      size: 280,
                      color: page.bgOrbs[0].withValues(alpha: 0.18),
                    ),
                  ),
                  // Dynamic orb 2
                  Positioned(
                    bottom: -100 + t * 20,
                    left: -60,
                    child: _GlowOrb(
                      size: 240,
                      color: page.bgOrbs[1].withValues(alpha: 0.12),
                    ),
                  ),
                  // Ambient orb
                  Positioned(
                    top: size.height * 0.5,
                    right: size.width * 0.3,
                    child: _GlowOrb(
                      size: 120,
                      color: page.gradient[1].withValues(alpha: 0.06),
                    ),
                  ),
                ],
              );
            },
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: const SizedBox(),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _complete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            S.of(context, 'skip'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = i);
                    },
                    itemBuilder: (_, i) => _buildPage(_pages[i]),
                  ),
                ),

                // Dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = _currentPage == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(colors: _pages[_currentPage].gradient)
                              : null,
                          color: isActive ? null : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _pages[_currentPage].gradient[0].withValues(alpha: 0.6),
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                ),

                // Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: page.gradient),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradient[0].withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: page.gradient[1].withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (_currentPage < _pages.length - 1) {
                            _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          } else {
                            _complete();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage < _pages.length - 1
                                  ? S.of(context, 'next')
                                  : S.of(context, 'getStarted'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Illustration with floating effect + glow
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) {
              final float = _floatCtrl.value;
              return Transform.translate(
                offset: Offset(0, -10 + float * 20),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: page.gradient[0].withValues(alpha: 0.2),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Image.asset(
                page.image,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        page.gradient[0].withValues(alpha: 0.15),
                        page.gradient[1].withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: page.gradient[0].withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          LinearGradient(colors: page.gradient).createShader(b),
                      child: const Icon(Icons.school_rounded, size: 80, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 56),

          // Title with gradient
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [Colors.white, ...page.gradient]).createShader(bounds),
            child: Text(
              S.of(context, page.titleKey),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),

          // Description
          Text(
            S.of(context, page.descKey),
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.8,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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

class _OnboardingData {
  final String image;
  final String titleKey;
  final String descKey;
  final List<Color> gradient;
  final List<Color> bgOrbs;

  const _OnboardingData({
    required this.image,
    required this.titleKey,
    required this.descKey,
    required this.gradient,
    required this.bgOrbs,
  });
}

// Keep original class name alias for backward compatibility
class OnboardingPage extends _OnboardingData {
  const OnboardingPage({
    required super.image,
    required String titleKey,
    required String descriptionKey,
    required Color color,
  }) : super(
          titleKey: titleKey,
          descKey: descriptionKey,
          gradient: const [AppTheme.primary, AppTheme.accent],
          bgOrbs: const [AppTheme.primary, AppTheme.accent],
        );
}
