import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                  _buildHeaderIcon(
                    icon: prov.hasUnreadNotifications ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    iconColor: prov.hasUnreadNotifications ? AppTheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(
                    icon: favoritesCount > 0 ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
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
