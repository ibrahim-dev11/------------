import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../data/constants.dart';

class FilterBottomSheet extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;
  final TextEditingController searchController;

  const FilterBottomSheet({
    super.key,
    required this.prov,
    required this.isDark,
    required this.searchController,
  });

  bool _hasActiveFilters() {
    return prov.filterType.isNotEmpty ||
        prov.filterCity.isNotEmpty ||
        prov.sortMode != SortMode.defaultSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primary.withOpacity(0.15),
                        AppTheme.accent.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Iconsax.setting_4, size: 22, color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'filter'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      S.of(context, 'findFavorite'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      prov.clearFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.trash, size: 16, color: AppTheme.danger),
                          const SizedBox(width: 6),
                          Text(
                            S.of(context, 'clear'),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.danger),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
          ),

          // Filter options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type dropdown
                Text(
                  S.of(context, 'institutionType'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterType.isEmpty ? null : prov.filterType,
                      hint: Row(
                        children: [
                          Icon(Iconsax.category, size: 18, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context, 'allTypes'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(Iconsax.arrow_down_1, size: 18, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      items: prov.localizedTypeLabels.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                              ))
                          .toList(),
                      onChanged: (v) => prov.setFilterType(v ?? ''),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // City dropdown
                Text(
                  S.of(context, 'city'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterCity.isEmpty ? null : prov.filterCity,
                      hint: Row(
                        children: [
                          Icon(Iconsax.location, size: 18, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context, 'allCities'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(Iconsax.arrow_down_1, size: 18, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      items: (AppConstants.cities['عێراق'] ?? [])
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                              ))
                          .toList(),
                      onChanged: (v) => prov.setFilterCity(v ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF6366F1), AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context, 'apply'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
