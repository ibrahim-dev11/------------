import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/app_3d_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _pages = [
    _OBPage(iconType: _IconType.institution),
    _OBPage(iconType: _IconType.teacher),
    _OBPage(iconType: _IconType.cv),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.medium,
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (!mounted) return;
    context.go('/role-selection');
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _pages.length - 1;

    final titles = [
      l.onboardingTitle1,
      l.onboardingTitle2,
      l.onboardingTitle3,
    ];
    final descs = [
      l.onboardingDesc1,
      l.onboardingDesc2,
      l.onboardingDesc3,
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          // ── Background Blobs ──
          RepaintBoundary(
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -60,
                  child: _Blob(
                    size: 320,
                    color: AppColors.primary
                        .withValues(alpha: isDark ? 0.12 : 0.08),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -60,
                  child: _Blob(
                    size: 260,
                    color: AppColors.primaryLight
                        .withValues(alpha: isDark ? 0.08 : 0.05),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dot-step indicator (small)
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: AppConstants.fast,
                            margin: const EdgeInsets.only(right: 5),
                            width: active ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkBorder2
                                      : AppColors.lightBorder),
                            ),
                          );
                        }),
                      ),
                      if (!isLast)
                        GestureDetector(
                          onTap: _finish,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              l.skip,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Rabar',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── PageView ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildPage(
                      page: _pages[index],
                      title: titles[index],
                      desc: descs[index],
                      isDark: isDark,
                    ),
                  ),
                ),

                // ── Bottom controls ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          expansionFactor: 3,
                          spacing: 6,
                          dotColor: isDark
                              ? AppColors.darkBorder2
                              : AppColors.lightBorder,
                          activeDotColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primaryLight,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLast ? l.getStarted : l.next,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Rabar',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required _OBPage page,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    final blobColors = [AppColors.primary, AppColors.primaryLight];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with decorative blobs
              OnboardingIcon(
                blobColors: blobColors,
                icon: _buildIcon(page.iconType),
              ),
              const SizedBox(height: 44),
              // Feature badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _badgeLabel(page.iconType),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Rabar',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                  fontFamily: 'Rabar',
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textGrey
                      : AppColors.textMutedLight,
                  fontFamily: 'Rabar',
                  height: 1.75,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_IconType type) {
    switch (type) {
      case _IconType.institution:
        return const InstitutionIcon(size: 110);
      case _IconType.cv:
        return const CvIcon(size: 110);
      case _IconType.teacher:
        return const TeacherIcon(size: 110);
    }
  }

  String _badgeLabel(_IconType type) {
    switch (type) {
      case _IconType.institution:
        return '🎓  خوێندنگا';
      case _IconType.teacher:
        return '👨‍🏫  مامۆستا';
      case _IconType.cv:
        return '📄  CV';
    }
  }
}

enum _IconType { institution, cv, teacher }

class _OBPage {
  final _IconType iconType;
  const _OBPage({required this.iconType});
}

// ── Simple circular blob ──────────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
