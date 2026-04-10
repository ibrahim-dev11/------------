import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'appName'),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                  _buildHeaderIcon(
                    icon: prov.hasUnreadNotifications ? Iconsax.notification_bing : Iconsax.notification,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    iconColor: prov.hasUnreadNotifications ? AppTheme.primary : null,
                    badge: prov.hasUnreadNotifications,
                    badgeCount: prov.unreadNotificationsCount,
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(
                    icon: favoritesCount > 0 ? Icons.favorite_rounded : Iconsax.heart,
                    onTap: onShowFavorites,
                    iconColor: favoritesCount > 0 ? Colors.redAccent : null,
                    badge: true,
                    badgeCount: favoritesCount,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569)),
              ),
            ),
            if (badge && badgeCount != null && badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
