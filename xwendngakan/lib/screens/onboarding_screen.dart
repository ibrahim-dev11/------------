import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Iconsax.building,
      titleKey: 'onboarding1Title',
      descKey: 'onboarding1Desc',
      gradient: [Color(0xFF7C6FFF), Color(0xFF00D4FF)],
    ),
    _OnboardingData(
      icon: Iconsax.search_normal,
      titleKey: 'onboarding2Title',
      descKey: 'onboarding2Desc',
      gradient: [Color(0xFF00C896), Color(0xFF00D4FF)],
    ),
    _OnboardingData(
      icon: Iconsax.map,
      titleKey: 'onboarding3Title',
      descKey: 'onboarding3Desc',
      gradient: [Color(0xFFFFB547), Color(0xFFFF5C7A)],
    ),
    _OnboardingData(
      icon: Iconsax.heart,
      titleKey: 'onboarding4Title',
      descKey: 'onboarding4Desc',
      gradient: [Color(0xFFFF5C7A), Color(0xFF7C6FFF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await context.read<AppProvider>().completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LanguageScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // Animated bg blob
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => Positioned(
              top: -80 + _bgCtrl.value * 30,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      page.gradient[0].withValues(alpha: isDark ? 0.15 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: _complete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkElevated : AppTheme.lightSurface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                        child: Text(
                          S.of(context, 'skip'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _buildPage(_pages[i], isDark),
                  ),
                ),

                // Dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = _currentPage == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(colors: _pages[_currentPage].gradient)
                              : null,
                          color: isActive
                              ? null
                              : (isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _pages[_currentPage]
                                        .gradient[0]
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: page.gradient),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradient[0].withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 400),
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
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? S.of(context, 'next')
                              : S.of(context, 'getStarted'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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

  Widget _buildPage(_OnboardingData page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (_, value, __) => Transform.scale(
              scale: value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      page.gradient[0].withValues(alpha: isDark ? 0.15 : 0.1),
                      page.gradient[1].withValues(alpha: isDark ? 0.08 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: page.gradient[0].withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: page.gradient,
                    ).createShader(b),
                    child: Icon(page.icon, size: 68, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            S.of(context, page.titleKey),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            S.of(context, page.descKey),
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final List<Color> gradient;

  const _OnboardingData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.gradient,
  });
}

// Keep original class name alias for backward compatibility
class OnboardingPage extends _OnboardingData {
  const OnboardingPage({
    required super.icon,
    required String titleKey,
    required String descriptionKey,
    required Color color,
  }) : super(
          titleKey: titleKey,
          descKey: descriptionKey,
          gradient: const [AppTheme.primary, AppTheme.accent],
        );
}
