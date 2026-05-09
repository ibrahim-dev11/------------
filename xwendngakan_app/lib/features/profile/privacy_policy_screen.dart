import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('سیاسەتی تایبەتمەندی', style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '١. کۆکردنەوەی زانیاری',
              'ئێمە هەندێک زانیاری کەسی کۆدەکەینەوە وەک ناو، ئیمەیڵ، و ژمارەی مۆبایل کاتێک هەژمار دروست دەکەیت بۆ ئەوەی خزمەتگوزارییەکانمان پێشکەش بکەین.',
              isDark,
            ),
            _buildSection(
              '٢. چۆنیەتی بەکارهێنانی زانیاری',
              'زانیارییەکانت بەکاردێن بۆ باشترکردنی خزمەتگوزارییەکان، ناردنی ئاگادارکردنەوەی گرنگ، و دڵنیابوونەوە لە ناسنامەی بەکارهێنەر.',
              isDark,
            ),
            _buildSection(
              '٣. پاراستنی زانیاری',
              'ئێمە ڕێکاری توندی تەکنیکی دەگرینەبەر بۆ پاراستنی زانیارییەکانت لە هەر دەستوەردانێکی دەرەکی یان دزەپێکردن.',
              isDark,
            ),
            _buildSection(
              '٤. مافەکانی بەکارهێنەر',
              'تۆ مافی ئەوەت هەیە داوای سڕینەوەی هەژمارەکەت و هەموو زانیارییەکانت بکەیت لە هەر کاتێکدا بێت لە ڕێگەی ڕێکخستنەکانەوە.',
              isDark,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'دواهەمین نوێکردنەوە: ٩/٥/٢٠٢٤',
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontSize: 12,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ],
      ),
    );
  }
}
