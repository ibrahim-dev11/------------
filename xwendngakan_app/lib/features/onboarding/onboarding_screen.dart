import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
    _OBPage(
      gradient: [Color(0xFF534AB7), Color(0xFF7F77DD)],
      iconType: _IconType.institution,
    ),
    _OBPage(
      gradient: [Color(0xFF1D9E75), Color(0xFF25C28F)],
      iconType: _IconType.cv,
    ),
    _OBPage(
      gradient: [Color(0xFFD4A017), Color(0xFFE8B84B)],
      iconType: _IconType.teacher,
    ),
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
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
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
    final isLast = _currentPage == _pages.length - 1;
    final page = _pages[_currentPage];

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip + counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: const TextStyle(
                      color: Color(0xFFB5B3CF),
                      fontSize: 13,
                      fontFamily: 'Rabar',
                    ),
                  ),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'بپارێزن',
                        style: TextStyle(
                          color: Color(0xFFB5B3CF),
                          fontSize: 14,
                          fontFamily: 'Rabar',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(
                  page: _pages[index],
                  title: titles[index],
                  desc: descs[index],
                ),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
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
                      dotColor: const Color(0xFFDDDBF0),
                      activeDotColor: page.gradient[0],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: page.gradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradient.last.withOpacity(0.38),
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
                        child: Text(
                          isLast ? l.getStarted : l.next,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Rabar',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/role-selection'),
                    child: const Text(
                      'بەردەوامبە • چوونەژوورەوەمە',
                      style: TextStyle(
                        color: Color(0xFFB5B3CF),
                        fontSize: 13,
                        fontFamily: 'Rabar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required _OBPage page,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D icon with decorative blobs
              OnboardingIcon(
                blobColors: page.gradient,
                icon: _buildIcon(page.iconType),
              ),
              const SizedBox(height: 48),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                  fontFamily: 'Rabar',
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8BAD),
                  fontFamily: 'Rabar',
                  height: 1.7,
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
}

enum _IconType { institution, cv, teacher }

class _OBPage {
  final List<Color> gradient;
  final _IconType iconType;

  const _OBPage({required this.gradient, required this.iconType});
}
