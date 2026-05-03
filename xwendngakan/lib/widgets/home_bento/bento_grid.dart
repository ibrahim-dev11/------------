import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class HomeBentoGrid extends StatelessWidget {
  final bool isDark;
  const HomeBentoGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildBentoItem(
              flex: 2,
              title: 'زانکۆکان',
              count: '24',
              icon: Iconsax.teacher,
              color: AppTheme.sectionBlue,
              iconColor: AppTheme.sectionBlueDark,
            ),
            const SizedBox(width: 16),
            _buildBentoItem(
              flex: 1,
              title: 'سیڤی',
              count: '150+',
              icon: Iconsax.document_text,
              color: AppTheme.sectionPink,
              iconColor: AppTheme.sectionPinkDark,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBentoItem(
              flex: 1,
              title: 'قوتابخانە',
              count: '48',
              icon: Iconsax.book_1,
              color: AppTheme.sectionPurple,
              iconColor: AppTheme.sectionPurpleDark,
            ),
            const SizedBox(width: 16),
            _buildBentoItem(
              flex: 2,
              title: 'مامۆستایان',
              count: '320',
              icon: Iconsax.user_octagon,
              color: AppTheme.sectionGreen,
              iconColor: AppTheme.sectionGreenDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoItem({
    required int flex,
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const Icon(Icons.arrow_outward_rounded, color: Colors.black26, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
