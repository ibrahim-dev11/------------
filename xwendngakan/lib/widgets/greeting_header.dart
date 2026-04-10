import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../screens/notifications_screen.dart';

class GreetingHeader extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onShowFavorites;
  final int favoritesCount;

  const GreetingHeader({
    super.key,
    required this.prov,
    required this.isDark,
    required this.onToggleTheme,
    required this.onShowFavorites,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Text (Logo Section)
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.book_1,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'edu',
                            style: GoogleFonts.outfit(                           
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                              letterSpacing: -0.5,

                            ),
                          ),
                          TextSpan(
                            text: 'book',
                            style: GoogleFonts.outfit(
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.8,                  
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                  _buildHeaderIcon(
                    icon: prov.hasUnreadNotifications ? Iconsax.notification_bing5 : Iconsax.notification,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    iconColor: prov.hasUnreadNotifications ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(
                    icon: favoritesCount > 0 ? Iconsax.heart5 : Iconsax.heart,
                    onTap: onShowFavorites,
                    iconColor: favoritesCount > 0 ? Colors.redAccent : null,
                    badge: favoritesCount > 0,
                    badgeCount: favoritesCount,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
    int? badgeCount,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
            if (badge && badgeCount != null && badgeCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
