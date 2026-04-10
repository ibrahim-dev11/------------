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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Iconsax.building,
      titleKey: 'onboarding1Title',
      descriptionKey: 'onboarding1Desc',
      color: AppTheme.primary,
    ),
    OnboardingPage(
      icon: Iconsax.search_normal,
      titleKey: 'onboarding2Title',
      descriptionKey: 'onboarding2Desc',
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      icon: Iconsax.map,
      titleKey: 'onboarding3Title',
      descriptionKey: 'onboarding3Desc',
      color: const Color(0xFFF59E0B),
    ),
    OnboardingPage(
      icon: Iconsax.heart,
      titleKey: 'onboarding4Title',
      descriptionKey: 'onboarding4Desc',
      color: const Color(0xFFEF4444),
    ),
  ];

  Future<void> _completeOnboarding() async {
    await context.read<AppProvider>().completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    S.of(context, 'skip'),
                    style: TextStyle(color: hintColor),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, textColor, hintColor);
                },
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index, isDark),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? S.of(context, 'next')
                        : S.of(context, 'getStarted'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, Color textColor, Color hintColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated background
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      page.icon,
                      size: 64,
                      color: page.color,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            S.of(context, page.titleKey),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            S.of(context, page.descriptionKey),
            style: TextStyle(
              fontSize: 16,
              color: hintColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : (isDark ? Colors.white24 : Colors.grey[300]),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
  });
}
