import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class HomeSearchSection extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;

  const HomeSearchSection({
    super.key,
    required this.isDark,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.lightBorder),
              boxShadow: AppTheme.softShadow(isDark),
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Advanced search',
                border: InputBorder.none,
                icon: Icon(Iconsax.search_normal, color: AppTheme.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Advanced', true),
                const SizedBox(width: 8),
                _buildFilterChip('Filter', false),
                const SizedBox(width: 8),
                _buildFilterChip('Filter', false),
                const SizedBox(width: 8),
                _buildFilterChip('Search', false, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool hasDropdown, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPrimary ? AppTheme.primary : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : AppTheme.textPrimaryLight,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isPrimary ? Colors.white : AppTheme.textPrimaryLight,
            ),
          ],
        ],
      ),
    );
  }
}
