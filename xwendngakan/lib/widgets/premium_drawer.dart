import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/app_localizations.dart';
import '../screens/login_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/search_screen.dart';

/// A stunning, ultra-premium drawer with glassmorphism header, floating orbs,
/// staggered animations, and cinematic design.
class PremiumDrawer extends StatefulWidget {
  final VoidCallback? onClose;

  const PremiumDrawer({super.key, this.onClose});

  @override
  State<PremiumDrawer> createState() => _PremiumDrawerState();
}

class _PremiumDrawerState extends State<PremiumDrawer>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _orbController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutExpo),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.84,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 60,
                offset: const Offset(15, 0),
                spreadRadius: -10,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 40,
                offset: const Offset(8, 0),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            child: Column(
              children: [
                _buildGlassHeader(context, prov, isDark),
                Expanded(
                  child: _buildMenuList(context, prov, isDark),
                ),
                _buildFooter(context, prov, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── GLASSMORPHISM HEADER WITH FLOATING ORBS ───
  Widget _buildGlassHeader(BuildContext context, AppProvider prov, bool isDark) {
    final userName = _getUserName(prov);
    final userEmail = _getUserEmail(prov);
    final hasUser = prov.isLoggedIn && prov.currentUser != null;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          // ── Background gradient
          Container(
            padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1A1040),
                        const Color(0xFF0F1A2E),
                        AppTheme.darkBg,
                      ]
                    : [
                        AppTheme.primary.withValues(alpha: 0.12),
                        AppTheme.accent.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBrandRow(context, isDark),
                const SizedBox(height: 28),
                _buildProfileSection(context, prov, isDark, hasUser, userName, userEmail),
              ],
            ),
          ),

          // ── Floating orb 1 (top-right)
          Positioned(
            top: topPadding - 10,
            right: -20,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final value = _orbController.value;
                return Transform.translate(
                  offset: Offset(
                    math.sin(value * math.pi * 2) * 8,
                    math.cos(value * math.pi * 2) * 6,
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                      AppTheme.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Floating orb 2 (mid-left)
          Positioned(
            bottom: 10,
            left: -15,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final value = _orbController.value;
                return Transform.translate(
                  offset: Offset(
                    math.cos(value * math.pi * 2) * 6,
                    math.sin(value * math.pi * 2) * 8,
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withValues(alpha: isDark ? 0.18 : 0.1),
                      AppTheme.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle shimmer line at bottom
          Positioned(
            bottom: 0,
            left: 24,
            right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                    AppTheme.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Logo/Brand
        Row(
          children: [
            // Glowing logo container
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B83FF), Color(0xFF3ECFCF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.book_1,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خوێندنگاکان',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'edu book',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Close button with glass effect
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Iconsax.close_circle,
                  size: 20,
                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    AppProvider prov,
    bool isDark,
    bool hasUser,
    String userName,
    String userEmail,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (!hasUser) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppTheme.primary.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(prov, isDark, hasUser, userName),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasUser ? userName : S.of(context, 'guest'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (hasUser)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.success.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          if (hasUser) const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              hasUser ? userEmail : S.of(context, 'loginForMore'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : AppTheme.lightTextSub,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!hasUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.login,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          S.of(context, 'login'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppProvider prov, bool isDark, bool hasUser, String userName) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: hasUser
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Gradient border ring
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: hasUser
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF3ECFCF),
                        Color(0xFF8B83FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasUser ? null : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: hasUser ? AppTheme.accentGradient : null,
                color: hasUser
                    ? null
                    : (isDark ? AppTheme.darkCard : const Color(0xFFF0F2F8)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: hasUser
                  ? Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      Iconsax.user,
                      size: 24,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENU LIST WITH STAGGERED ANIMATIONS ───
  Widget _buildMenuList(BuildContext context, AppProvider prov, bool isDark) {
    final menuItems = _getMenuItems(context, prov);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        if (item['isDivider'] == true) {
          return _buildSectionHeader(isDark, item['label'] as String?);
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + (index * 60)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildMenuItem(
            context,
            isDark,
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            subtitle: item['subtitle'] as String?,
            iconColor: item['iconColor'] as Color?,
            onTap: item['onTap'] as VoidCallback?,
            trailing: item['trailing'] as Widget?,
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(bool isDark, String? label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
      child: Row(
        children: [
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: 0.7)
                      : AppTheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? AppTheme.darkBorder.withValues(alpha: 0.5)
                        : AppTheme.lightBorder.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final color = iconColor ?? AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Gradient icon container with glow
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: isDark ? 0.18 : 0.12),
                        color.withValues(alpha: isDark ? 0.08 : 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                // Label & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppTheme.textSecondary.withValues(alpha: 0.7)
                                : AppTheme.lightTextSub.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing
                if (trailing != null) trailing,
                if (trailing == null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Iconsax.arrow_right_3,
                      size: 14,
                      color: isDark
                          ? AppTheme.textHint.withValues(alpha: 0.5)
                          : AppTheme.lightTextSub.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── FOOTER ───
  Widget _buildFooter(BuildContext context, AppProvider prov, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.darkBorder.withValues(alpha: 0.4)
                : AppTheme.lightBorder.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Version badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withValues(alpha: 0.6)
                  : AppTheme.lightBorder.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppTheme.darkBorder.withValues(alpha: 0.3)
                    : AppTheme.lightBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.cpu,
                  size: 13,
                  color: AppTheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textSecondary.withValues(alpha: 0.7)
                        : AppTheme.lightTextSub.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Logout Button (if logged in)
          if (prov.isLoggedIn)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showLogoutDialog(context, prov);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.danger.withValues(alpha: isDark ? 0.15 : 0.08),
                      AppTheme.danger.withValues(alpha: isDark ? 0.08 : 0.04),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.danger.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.logout,
                      size: 18,
                      color: AppTheme.danger,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context, 'logout'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── MENU ITEMS DATA ───
  List<Map<String, dynamic>> _getMenuItems(BuildContext context, AppProvider prov) {
    return [
      {
        'icon': Iconsax.search_normal_1,
        'label': S.of(context, 'search'),
        'subtitle': 'گەڕان لە دامەزراوەکان',
        'iconColor': AppTheme.primary,
        'onTap': () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
      },
      {
        'icon': Iconsax.heart5,
        'label': S.of(context, 'favorites'),
        'subtitle': 'دامەزراوە دڵخوازەکان',
        'iconColor': AppTheme.danger,
        'onTap': () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        },
      },
      {
        'isDivider': true,
        'label': 'ڕێکخستنەکان',
      },
      {
        'icon': prov.isDarkMode ? Iconsax.moon5 : Iconsax.sun_15,
        'label': prov.isDarkMode
            ? S.of(context, 'darkMode')
            : S.of(context, 'lightMode'),
        'subtitle': 'گۆڕینی ڕووکاری ئەپ',
        'iconColor': AppTheme.gold,
        'onTap': () {
          prov.toggleTheme();
        },
        'trailing': Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: prov.isDarkMode,
            onChanged: (_) => prov.toggleTheme(),
            activeThumbColor: AppTheme.primary,
          ),
        ),
      },
      {
        'icon': Iconsax.language_square,
        'label': S.of(context, 'language'),
        'subtitle': _getLanguageName(prov.language),
        'iconColor': AppTheme.accent,
        'onTap': () {
          _showLanguageDialog(context, prov);
        },
      },
      {
        'isDivider': true,
        'label': 'زیاتر',
      },
      {
        'icon': Iconsax.info_circle,
        'label': S.of(context, 'about'),
        'iconColor': AppTheme.success,
        'onTap': () {
          // Show about dialog
        },
      },
      {
        'icon': Iconsax.message_question,
        'label': S.of(context, 'help'),
        'iconColor': const Color(0xFF9B59B6),
        'onTap': () {
          // Show help
        },
      },
    ];
  }

  // ─── HELPERS ───
  String _getUserName(AppProvider prov) {
    if (prov.isLoggedIn && prov.currentUser != null) {
      return prov.currentUser!['name'] as String? ?? '';
    }
    return '';
  }

  String _getUserEmail(AppProvider prov) {
    if (prov.isLoggedIn && prov.currentUser != null) {
      return prov.currentUser!['email'] as String? ?? '';
    }
    return '';
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'کوردی';
    }
  }

  void _showLanguageDialog(BuildContext context, AppProvider prov) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context, 'selectLanguage'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(context, prov, 'ku', 'کوردی', '🇮🇶', isDark),
            _buildLanguageOption(context, prov, 'ar', 'العربية', '🇸🇦', isDark),
            _buildLanguageOption(context, prov, 'en', 'English', '🇺🇸', isDark),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppProvider prov,
    String code,
    String name,
    String flag,
    bool isDark,
  ) {
    final isSelected = prov.language == code;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          prov.setLanguage(code);
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                : (isDark ? AppTheme.darkCard : AppTheme.lightBg),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.5)
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppProvider prov) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context, 'logout'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
          ),
        ),
        content: Text(
          S.of(context, 'logoutConfirm'),
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              S.of(context, 'cancel'),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              prov.logoutUser();
            },
            child: Text(
              S.of(context, 'logout'),
              style: const TextStyle(
                color: AppTheme.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility widget for AnimatedBuilder pattern
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWidget2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedWidget2 extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedWidget2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
