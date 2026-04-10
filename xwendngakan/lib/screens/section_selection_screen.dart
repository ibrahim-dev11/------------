import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';
import 'cv_bank_screen.dart';
import 'teacher_request_screen.dart';

class SectionSelectionScreen extends StatefulWidget {
  const SectionSelectionScreen({super.key});

  @override
  State<SectionSelectionScreen> createState() => _SectionSelectionScreenState();
}

class _SectionSelectionScreenState extends State<SectionSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < 4; i++) {
      _slideAnimations.add(Tween<double>(begin: 60.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 * i, 0.6 + (0.1 * i), curve: Curves.easeOutCubic),
        ),
      ));
      _fadeAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 * i, 0.6 + (0.1 * i), curve: Curves.easeOut),
        ),
      ));
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
              Color(0xFFEFF6FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative shapes for modern background
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.warning.withValues(alpha: 0.04),
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimations[0].value,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimations[0].value),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // App icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppTheme.primary, Color(0xFF60A5FA)],
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  '📚 edu book',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navy,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'دلیلی دامەزراوە پەروەردەییەکانی عێراق و کوردستان',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAnimatedCard(
                            index: 1,
                            title: 'دامەزراوە ئەکادیمییەکان',
                            subtitle: 'زانکۆ • پەیمانگە • قوتابخانە',
                            icon: Icons.account_balance_rounded,
                            color1: AppTheme.primary,
                            color2: const Color(0xFF60A5FA),
                            onTap: () async {
                              final prov = context.read<AppProvider>();
                              if (prov.isLoggedIn) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainNavScreen()),
                                );
                              } else {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                if (context.mounted && context.read<AppProvider>().isLoggedIn) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainNavScreen()),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedCard(
                            index: 2,
                            title: ' CV',
                            subtitle: 'سیڤی • هەلی کار',
                            icon: Icons.badge_rounded,
                            color1: AppTheme.success,
                            color2: const Color(0xFF34D399),
                            onTap: () async {
                              final prov = context.read<AppProvider>();
                              if (prov.isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CvBankScreen()),
                                );
                              } else {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                if (context.mounted && context.read<AppProvider>().isLoggedIn) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CvBankScreen()),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedCard(
                            index: 3,
                            title: 'ماموستاکانم',
                            subtitle: 'ماموستای تایبەت • زانکۆ • قوتابخانە',
                            icon: Icons.school_rounded,
                            color1: AppTheme.warning,
                            color2: const Color(0xFFFCD34D),
                            onTap: () async {
                              final prov = context.read<AppProvider>();
                              if (prov.isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TeacherRequestScreen()),
                                );
                              } else {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                if (context.mounted && context.read<AppProvider>().isLoggedIn) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TeacherRequestScreen()),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 40),
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
    );
  }

  Widget _buildAnimatedCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimations[index].value),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color1.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            highlightColor: color1.withValues(alpha: 0.05),
            splashColor: color1.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color1, color2],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: color1.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B), // Slate 500
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color1.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: color1,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
