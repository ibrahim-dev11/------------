import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            // Gradient circle icon
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  AppTheme.accent.withValues(alpha: isDark ? 0.1 : 0.04),
                ]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.search_status_1,
                size: 48,
                color: isDark
                    ? AppTheme.neutral300
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              S.of(context, 'noResults'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context, 'changeFilters'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                searchController.clear();
                prov.clearFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF818CF8),
                      Color(0xFF38BDF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context, 'clearFilters'),
                      style: GoogleFonts.outfit(
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.danger.withValues(alpha: isDark ? 0.15 : 0.08),
                  AppTheme.accent.withValues(alpha: isDark ? 0.1 : 0.04),
                ]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.wifi_square,
                size: 48,
                color: isDark
                    ? AppTheme.neutral300
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              S.of(context, 'networkError'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context, 'connectionError'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => prov.fetchFromApi(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF818CF8),
                      Color(0xFF38BDF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context, 'retry'),
                      style: GoogleFonts.outfit(
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
