import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';


class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'دروستکردنی هەژمار',
      'desc': 'بۆ ئەوەی بتوانیت سوود لە هەموو تایبەتمەندییەکان وەربگریت، سەرەتا پێویستە هەژمارێکی تایبەت بە خۆت دروست بکەیت.',
      'icon': Iconsax.user_add5,
      'color': const Color(0xFF10B981),
      'image': 'assets/images/step1.png', // Placeholder
    },
    {
      'title': 'زیادکردنی دامەزراوە',
      'desc': 'ئەگەر خاوەن دامەزراوەیت، دەتوانیت لە بەشی "تۆمارکردن" داواکاری بنێریت بۆ بڵاوکردنەوەی خوێندنگا یان پەیمانگەکەت.',
      'icon': Iconsax.add_circle5,
      'color': const Color(0xFF3B82F6),
      'image': 'assets/images/step2.png',
    },
    {
      'title': 'تۆمارکردنی مامۆستا',
      'desc': 'مامۆستایانی تایبەت دەتوانن زانیارییەکانیان تۆمار بکەن تا قوتابیان بە ئاسانی بیانبینن و پەیوەندییان پێوە بکەن.',
      'icon': Iconsax.teacher5,
      'color': const Color(0xFFF43F5E),
      'image': 'assets/images/step3.png',
    },
    {
      'title': 'گەڕان و دۆزینەوە',
      'desc': 'بە بەکارهێنانی فلتەرە پێشکەوتووەکان، دەتوانیت بەپێی شار و جۆر، باشترین شوێنی خوێندن بۆ خۆت بدۆزیتەوە.',
      'icon': Iconsax.search_status5,
      'color': const Color(0xFF8B5CF6),
      'image': 'assets/images/step4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _steps[_currentPage]['color'].withValues(alpha: isDark ? 0.05 : 0.02),
                    isDark ? AppTheme.darkBg : AppTheme.lightBg,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              const SizedBox(height: 60),
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2,
                        color: isDark ? Colors.white : AppTheme.darkSurface,
                      ),
                    ),
                    Text(
                      'فێرکاری بەکارهێنان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.darkSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 40), // Spacer for balance
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _steps.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Icon Container
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: step['color'].withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: step['color'].withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                step['icon'],
                                size: 56,
                                color: step['color'],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            step['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppTheme.darkSurface,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            step['desc'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: (isDark ? Colors.white : AppTheme.darkSurface).withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Placeholder for App Screen
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.mobile5, color: step['color'].withValues(alpha: 0.3), size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'نمایشی شاشە',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: step['color'].withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(_steps.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _steps[_currentPage]['color']
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next/Start Button
                    GestureDetector(
                      onTap: () {
                        if (_currentPage < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: _steps[_currentPage]['color'],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _steps[_currentPage]['color'].withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _steps.length - 1 ? 'دەستپێبکە' : 'دواتر',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _steps.length - 1
                                  ? Iconsax.tick_circle5
                                  : (Directionality.of(context) == TextDirection.rtl
                                      ? Iconsax.arrow_left_2
                                      : Iconsax.arrow_right_3),
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
