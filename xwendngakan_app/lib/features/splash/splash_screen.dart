import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowAnim;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  
  late AnimationController _floatController;
  late Animation<Offset> _floatAnim;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _floatAnim = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    ));

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Check for updates (Production ready)
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';
      final buildNumber = int.tryParse(info.buildNumber) ?? 0;

      final updateRes = await ApiService().checkUpdate(platform, buildNumber);
      
      if (updateRes.success && updateRes.data != null) {
        final data = updateRes.data!;
        if (data['force_update'] == true) {
          _showUpdateDialog(data, force: true);
          return;
        } else if (data['update_available'] == true) {
          await _showUpdateDialog(data, force: false);
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }

    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    // First launch: show language selection before anything else
    final langSelected = prefs.getBool(AppConstants.langSelectedKey) ?? false;
    if (!langSelected) {
      context.go('/language-select');
      return;
    }

    final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;
    if (!mounted) return;
    if (onboardingDone) {
      context.go('/role-selection');
    } else {
      context.go('/onboarding');
    }
  }

  Future<void> _showUpdateDialog(Map<String, dynamic> data, {required bool force}) async {
    final l = AppLocalizations.of(context);
    return showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(force ? l.forceUpdateTitle : l.updateAvailable),
        content: Text(data['release_notes'] ?? l.updateDesc),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.later),
            ),
          ElevatedButton(
            onPressed: () {
              // Launch store URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l.update, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF8),
              Color(0xFFF8F4EC),
              Color(0xFFF2EBE0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Gold glow — top right
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC49A3C).withOpacity(0.10 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Gold glow — bottom left
            Positioned(
              bottom: 60,
              left: -100,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC49A3C).withOpacity(0.06 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (_, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo icon — white rounded square with book icon
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: SlideTransition(
                          position: _floatAnim,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (_, child) => Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: const Color(0xFFC49A3C).withOpacity(
                                      0.35 + (_glowAnim.value - 0.4) * 0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC49A3C).withOpacity(
                                        0.18 + (_glowAnim.value - 0.4) * 0.18),
                                    blurRadius: 28 + (_glowAnim.value - 0.4) * 28,
                                    spreadRadius: (_glowAnim.value - 0.4) * 6,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Brand name
                    Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  Color(0xFFB8820A),
                                  Color(0xFF8A6010),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'EduBook',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (ctx) {
                                final l = AppLocalizations.of(ctx);
                                return Text(
                                  l.appTagline,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF5E6E82).withOpacity(0.85),
                                    letterSpacing: 0.5,
                                    fontFamily: 'Rabar',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dot indicator bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (_, __) => Opacity(
                  opacity: _textOpacity.value,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (_, __) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              double value = _dotsController.value;
                              double offset = i / 3.0;
                              double sineValue = math.sin((value - offset) * math.pi * 2);
                              double closeness = (sineValue + 1) / 2; // 0 to 1
                              
                              return Container(
                                width: 6 + (10 * closeness),
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC49A3C).withOpacity(
                                      0.25 + (0.75 * closeness)),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: const Color(0xFF8A9BB0).withOpacity(0.55),
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
