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
import '../screens/notifications_screen.dart';

/// Shows the hidden drawer as an overlay.
/// Call this from anywhere:
///   HiddenDrawer.show(context);
class HiddenDrawer {
  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;

  static bool get isOpen => _currentEntry != null;

  static void show(BuildContext context) {
    if (_currentEntry != null) return;

    final overlay = Overlay.of(context);
    late final AnimationController controller;
    late final OverlayEntry entry;

    controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 400),
    );

    entry = OverlayEntry(
      builder: (ctx) => _HiddenDrawerOverlay(
        controller: controller,
        onDismiss: () => _dismiss(controller, entry),
      ),
    );

    _currentEntry = entry;
    _currentController = controller;

    overlay.insert(entry);
    controller.forward();
  }

  static void _dismiss(AnimationController controller, OverlayEntry entry) {
    controller.reverse().then((_) {
      entry.remove();
      controller.dispose();
      _currentEntry = null;
      _currentController = null;
    });
  }

  static void hide() {
    if (_currentController != null && _currentEntry != null) {
      _dismiss(_currentController!, _currentEntry!);
    }
  }
}

class _HiddenDrawerOverlay extends StatefulWidget {
  final AnimationController controller;
  final VoidCallback onDismiss;

  const _HiddenDrawerOverlay({
    required this.controller,
    required this.onDismiss,
  });

  @override
  State<_HiddenDrawerOverlay> createState() => _HiddenDrawerOverlayState();
}

class _HiddenDrawerOverlayState extends State<_HiddenDrawerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;

  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _blurAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _slideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _blurAnim = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.82;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred + dimmed backdrop
            GestureDetector(
              onTap: widget.onDismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnim.value,
                  sigmaY: _blurAnim.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(
                    _fadeAnim.value * (isDark ? 0.5 : 0.35),
                  ),
                ),
              ),
            ),

            // Drawer panel (slides from right for RTL)
            Positioned(
              top: 0,
              bottom: 0,
              right: _slideAnim.value * drawerWidth,
              child: Transform.scale(
                scale: _scaleAnim.value,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: drawerWidth,
                  child: _buildDrawerContent(context, prov, isDark),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    AppProvider prov,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 50,
            offset: const Offset(-10, 0),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 30,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        child: Column(
          children: [
            _buildHeader(context, prov, isDark),
            Expanded(
              child: _buildMenuList(context, prov, isDark),
            ),
            _buildFooter(context, prov, isDark),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader(BuildContext context, AppProvider prov, bool isDark) {
    final hasUser = prov.isLoggedIn && prov.currentUser != null;
    final userName = hasUser
        ? (prov.currentUser!['name'] as String? ?? '')
        : '';
    final userEmail = hasUser
        ? (prov.currentUser!['email'] as String? ?? '')
        : '';
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          // Background gradient
          Container(
            padding: EdgeInsets.fromLTRB(22, topPadding + 18, 22, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF161B2E),
                        const Color(0xFF111827),
                        AppTheme.darkBg,
                      ]
                    : [
                        const Color(0xFFF0EDFF),
                        const Color(0xFFF5F8FF),
                        Colors.white,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: brand + close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildLogo(isDark),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  Color(0xFF8B83FF),
                                  AppTheme.accent,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'خوێندنگاکان',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'edu book',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary.withValues(alpha: 0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Close button
                    _buildCloseButton(isDark),
                  ],
                ),

                const SizedBox(height: 22),

                // Profile card
                _buildProfileCard(
                  context,
                  prov,
                  isDark,
                  hasUser,
                  userName,
                  userEmail,
                ),
              ],
            ),
          ),

          // Floating orb
          Positioned(
            top: topPadding - 10,
            left: -25,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (_, child) {
                final v = _orbController.value;
                return Transform.translate(
                  offset: Offset(
                    math.sin(v * math.pi * 2) * 6,
                    math.cos(v * math.pi * 2) * 5,
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withValues(alpha: isDark ? 0.15 : 0.1),
                      AppTheme.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom shimmer line
          Positioned(
            bottom: 0,
            left: 22,
            right: 22,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                    AppTheme.accent.withValues(alpha: isDark ? 0.15 : 0.08),
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

  Widget _buildLogo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B83FF), Color(0xFF3ECFCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Icon(Iconsax.book_1, color: Colors.white, size: 20),
    );
  }

  Widget _buildCloseButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onDismiss();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          Iconsax.close_circle,
          size: 18,
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AppProvider prov,
    bool isDark,
    bool hasUser,
    String userName,
    String userEmail,
  ) {
    return GestureDetector(
      onTap: () {
        if (!hasUser) {
          widget.onDismiss();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.primary.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : AppTheme.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(isDark, hasUser, userName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasUser ? userName : S.of(context, 'guest'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (hasUser) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.success.withValues(alpha: 0.4),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          hasUser
                              ? userEmail
                              : S.of(context, 'loginForMore'),
                          style: TextStyle(
                            fontSize: 11,
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
            if (!hasUser)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.login, size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      S.of(context, 'login'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool hasUser, String userName) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: hasUser
            ? const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasUser
            ? null
            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        borderRadius: BorderRadius.circular(15),
        boxShadow: hasUser
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          gradient: hasUser ? AppTheme.accentGradient : null,
          color: hasUser
              ? null
              : (isDark ? AppTheme.darkCard : const Color(0xFFF0F2F8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasUser
            ? Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            : Icon(
                Iconsax.user,
                size: 22,
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.lightTextSub,
              ),
      ),
    );
  }

  // ─── MENU LIST ───
  Widget _buildMenuList(BuildContext context, AppProvider prov, bool isDark) {
    final menuItems = _getMenuItems(context, prov);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        if (item['isDivider'] == true) {
          return _buildSectionDivider(isDark, item['label'] as String?);
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-25 * (1 - value), 0),
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

  Widget _buildSectionDivider(bool isDark, String? label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Row(
        children: [
          if (label != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? AppTheme.darkBorder.withValues(alpha: 0.4)
                        : AppTheme.lightBorder.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: isDark ? 0.16 : 0.1),
                        color.withValues(alpha: isDark ? 0.06 : 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.1 : 0.07),
                    ),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimary
                              : AppTheme.lightText,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.textSecondary.withValues(alpha: 0.6)
                                : AppTheme.lightTextSub.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (trailing == null)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Iconsax.arrow_left_2,
                      size: 12,
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
        18, 14, 18, MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.5)
            : const Color(0xFFFAFBFF),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.darkBorder.withValues(alpha: 0.3)
                : AppTheme.lightBorder.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // Version
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withValues(alpha: 0.5)
                  : AppTheme.lightBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.cpu, size: 12,
                    color: AppTheme.primary.withValues(alpha: 0.5)),
                const SizedBox(width: 5),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textSecondary.withValues(alpha: 0.6)
                        : AppTheme.lightTextSub.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          if (prov.isLoggedIn) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showLogoutDialog(context, prov);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.danger.withValues(alpha: isDark ? 0.12 : 0.07),
                      AppTheme.danger.withValues(alpha: isDark ? 0.06 : 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.danger.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.logout, size: 16, color: AppTheme.danger),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context, 'logout'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── MENU ITEMS ───
  List<Map<String, dynamic>> _getMenuItems(
      BuildContext context, AppProvider prov) {
    return [
      {
        'icon': Iconsax.search_normal_1,
        'label': S.of(context, 'search'),
        'subtitle': 'گەڕان لە دامەزراوەکان',
        'iconColor': AppTheme.primary,
        'onTap': () {
          widget.onDismiss();
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
          widget.onDismiss();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        },
      },
      {
        'icon': Iconsax.notification_bing,
        'label': S.of(context, 'notifications'),
        'subtitle': 'ئاگاداریەکان',
        'iconColor': AppTheme.gold,
        'onTap': () {
          widget.onDismiss();
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const NotificationsScreen()),
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
          scale: 0.75,
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
          _showLanguageSheet(context, prov);
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
        'onTap': () {},
      },
      {
        'icon': Iconsax.message_question,
        'label': S.of(context, 'help'),
        'iconColor': const Color(0xFF9B59B6),
        'onTap': () {},
      },
    ];
  }

  // ─── HELPERS ───
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

  void _showLanguageSheet(BuildContext context, AppProvider prov) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
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
            _langOption(context, prov, 'ku', 'کوردی', '🇮🇶', isDark),
            _langOption(context, prov, 'ar', 'العربية', '🇸🇦', isDark),
            _langOption(context, prov, 'en', 'English', '🇺🇸', isDark),
            SizedBox(
                height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, AppProvider prov, String code,
      String name, String flag, bool isDark) {
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
                  : (isDark
                      ? AppTheme.darkBorder
                      : AppTheme.lightBorder),
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
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.lightText,
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
                  child: const Icon(Icons.check,
                      size: 14, color: Colors.white),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          S.of(context, 'logout'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
          ),
        ),
        content: Text(
          'دڵنیایت لە چوونەدەرەوە؟',
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context, 'cancel'),
              style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.lightTextSub,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDismiss();
              prov.logoutUser();
            },
            child: const Text(
              'بەڵێ',
              style: TextStyle(
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
