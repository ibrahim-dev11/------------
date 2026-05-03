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

class _SectionSelectionScreenState extends State<SectionSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<double>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimations = List.generate(3, (index) => 
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2 * index, 0.6 + (0.1 * index), curve: Curves.easeOut),
        ),
      ),
    );

    _slideAnimations = List.generate(3, (index) => 
      Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2 * index, 0.6 + (0.1 * index), curve: Curves.easeOut),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo & Greeting
                    FadeTransition(
                      opacity: _fadeAnimations[0],
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school_rounded, size: 48, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'خوێندنگاکانم',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'بەخێربێیت بۆ گەورەترین پلاتفۆرمی خوێندن',
                            style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Cards
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSectionCard(
                            index: 0,
                            title: 'بەشی زانکۆ و قوتابخانەکان',
                            icon: Icons.school_rounded,
                            bgColor: AppTheme.sectionBlue,
                            iconColor: AppTheme.sectionBlueDark,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainNavScreen())),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            index: 1,
                            title: 'بەشی CV Bank',
                            icon: Icons.badge_rounded,
                            bgColor: AppTheme.sectionPink,
                            iconColor: AppTheme.sectionPinkDark,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CvBankScreen())),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            index: 2,
                            title: 'بەشی مامۆستاکانم',
                            icon: Icons.person_rounded,
                            bgColor: AppTheme.sectionGreen,
                            iconColor: AppTheme.sectionGreenDark,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherRequestScreen())),
                          ),
                        ],
                      ),
                    ),

                    // User Info / Logout
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              appProvider.logout();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            },
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            label: const Text('چوونەدەرەوە', style: TextStyle(color: Colors.redAccent)),
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
    );
  }

  Widget _buildSectionCard({
    required int index,
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimations[index % 3].value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimations[index % 3].value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: iconColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
