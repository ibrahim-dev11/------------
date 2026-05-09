import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
    final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;

    if (!mounted) return;
    if (onboardingDone) {
      context.go('/role-selection');
    } else {
      context.go('/onboarding');
    }
  }

  Future<void> _showUpdateDialog(Map<String, dynamic> data, {required bool force}) async {
    return showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(force ? 'پێویستە ئەپەکە نوێ بکەیتەوە' : 'وەشانێکی نوێ بەردەستە'),
        content: Text(data['release_notes'] ?? 'تکایە دوایین وەشانی ئەپەکە دابەزێنە بۆ ئەوەی باشترین ئەزموونت هەبێت.'),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('پاشان'),
            ),
          ElevatedButton(
            onPressed: () {
              // Launch store URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('نوێکردنەوە', style: TextStyle(color: Colors.white)),
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
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
          // Decorative blobs
            Positioned(
              top: -60,
              left: -60,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06 * _glowAnim.value),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
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
                                color: Colors.white.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35 + ((_glowAnim.value - 0.4) * 0.2)),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1 + ((_glowAnim.value - 0.4) * 0.2)),
                                    blurRadius: 20 + ((_glowAnim.value - 0.4) * 20),
                                    spreadRadius: (_glowAnim.value - 0.4) * 10,
                                    offset: const Offset(0, 0),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.white,
                                  size: 52,
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
                            Text(
                              'EduBook',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
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
                                width: 8 + (14 * closeness),
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35 + (0.65 * closeness)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: Colors.white38,
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
