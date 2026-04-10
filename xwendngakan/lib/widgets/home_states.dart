import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class HomeEmptyState extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;
  final TextEditingController searchController;

  const HomeEmptyState({
    super.key,
    required this.prov,
    required this.isDark,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primary.withOpacity(isDark ? 0.12 : 0.06),
                  AppTheme.accent.withOpacity(isDark ? 0.08 : 0.03),
                ]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.search_status_1,
                size: 52,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              S.of(context, 'noResults'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context, 'changeFilters'),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                searchController.clear();
                prov.clearFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF6366F1), AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context, 'clearFilters'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
}

class HomeErrorState extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;

  const HomeErrorState({
    super.key,
    required this.prov,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(isDark ? 0.12 : 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.wifi_square,
                size: 52,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              S.of(context, 'networkError'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context, 'connectionError'),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => prov.fetchFromApi(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF6366F1), AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context, 'retry'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
}
