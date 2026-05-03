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
import '../screens/map_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GLOBAL DRAWER CONTROLLER
// Controls the drawer from anywhere in the app
// ═══════════════════════════════════════════════════════════════════════════
class AppDrawerController extends ChangeNotifier {
  static final AppDrawerController instance = AppDrawerController._();
  AppDrawerController._();

  bool _isOpen = false;
  bool get isOpen => _isOpen;

  _AnimatedDrawerWrapperState? _state;

  void _register(_AnimatedDrawerWrapperState state) {
    _state = state;
  }

  void _unregister() {
    _state = null;
  }

  void open() => _state?._openDrawer();
  void close() => _state?._closeDrawer();
  void toggle() => _state?._toggleDrawer();

  void _setOpen(bool value) {
    _isOpen = value;
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED DRAWER WRAPPER
// Wraps the main content with a 3D animated drawer effect
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedDrawerWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedDrawerWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedDrawerWrapper> createState() => _AnimatedDrawerWrapperState();
}

class _AnimatedDrawerWrapperState extends State<AnimatedDrawerWrapper>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _shadowAnimation;

  bool _isOpen = false;

  // Animation Configuration
  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const Curve _animationCurve = Curves.easeInOutCubic;
  
  // Transform values
  static const double _scaleEnd = 0.85;
  static const double _slidePercent = 0.70;
  static const double _rotateAngle = -0.15;
  static const double _radiusEnd = 30.0;
  
  // Drawer gradient colors
  static const Color _gradientStart = Color(0xFF667EEA);
  static const Color _gradientEnd = Color(0xFF764BA2);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: _scaleEnd).animate(
      CurvedAnimation(parent: _controller, curve: _animationCurve),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: _slidePercent).animate(
      CurvedAnimation(parent: _controller, curve: _animationCurve),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: _rotateAngle).animate(
      CurvedAnimation(parent: _controller, curve: _animationCurve),
    );

    _radiusAnimation = Tween<double>(begin: 0.0, end: _radiusEnd).animate(
      CurvedAnimation(parent: _controller, curve: _animationCurve),
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: _animationCurve),
    );

    AppDrawerController.instance._register(this);
  }

  void _openDrawer() {
    if (!_isOpen) {
      _controller.forward();
      setState(() => _isOpen = true);
      AppDrawerController.instance._setOpen(true);
    }
  }

  void _closeDrawer() {
    if (_isOpen) {
      _controller.reverse();
      setState(() => _isOpen = false);
      AppDrawerController.instance._setOpen(false);
    }
  }

  void _toggleDrawer() {
    _isOpen ? _closeDrawer() : _openDrawer();
  }

  @override
  void dispose() {
    AppDrawerController.instance._unregister();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isRtl = prov.isRtl;
    final slideDirection = isRtl ? -1.0 : 1.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [_gradientStart, _gradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // DRAWER CONTENT
            Positioned(
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: screenWidth * 0.70,
                child: _DrawerContent(
                  prov: prov,
                  isDark: isDark,
                  onClose: _closeDrawer,
                  isRtl: isRtl,
                ),
              ),
            ),

            // MAIN CONTENT
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(_slideAnimation.value * screenWidth * slideDirection)
                  ..scale(_scaleAnimation.value)
                  ..rotateY(_rotateAnimation.value * slideDirection);

                return Transform(
                  alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  transform: transform,
                  child: GestureDetector(
                    onTap: _isOpen ? _closeDrawer : null,
                    onHorizontalDragUpdate: _isOpen
                        ? (details) {
                            if (isRtl
                                ? details.delta.dx > 10
                                : details.delta.dx < -10) {
                              _closeDrawer();
                            }
                          }
                        : null,
                    child: AbsorbPointer(
                      absorbing: _isOpen,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkBg : Colors.white,
                          borderRadius: BorderRadius.circular(_radiusAnimation.value),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.1 + (_shadowAnimation.value * 0.2),
                              ),
                              blurRadius: 20 + (_shadowAnimation.value * 30),
                              offset: Offset(
                                -15 * _shadowAnimation.value * slideDirection,
                                10 * _shadowAnimation.value,
                              ),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DRAWER CONTENT
// ═══════════════════════════════════════════════════════════════════════════
class _DrawerContent extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;
  final VoidCallback onClose;
  final bool isRtl;

  const _DrawerContent({
    required this.prov,
    required this.isDark,
    required this.onClose,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final hasUser = prov.isLoggedIn && prov.currentUser != null;
    final userName = hasUser
        ? (prov.currentUser!['name'] as String? ?? 'User')
        : S.of(context, 'guest');
    final userEmail = hasUser
        ? (prov.currentUser!['email'] as String? ?? '')
        : S.of(context, 'loginForMore');
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROFILE SECTION
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!hasUser) {
                      onClose();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  child: _buildAvatar(hasUser, userName),
                ),
                const SizedBox(height: 16),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    if (hasUser) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // MENU ITEMS
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _DrawerMenuItem(
                    icon: Iconsax.search_normal_1,
                    label: S.of(context, 'search'),
                    onTap: () {
                      onClose();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.heart,
                    label: S.of(context, 'favorites'),
                    iconColor: const Color(0xFFFF6B6B),
                    onTap: () {
                      onClose();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.notification,
                    label: S.of(context, 'notifications'),
                    iconColor: const Color(0xFFFFD93D),
                    badge: prov.unreadNotificationsCount > 0
                        ? prov.unreadNotificationsCount.toString()
                        : null,
                    onTap: () {
                      onClose();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.map_1,
                    label: S.of(context, 'map'),
                    iconColor: const Color(0xFF00D9FF),
                    onTap: () {
                      onClose();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),

                  const SizedBox(height: 16),

                  _DrawerMenuItem(
                    icon: prov.isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                    label: prov.isDarkMode
                        ? S.of(context, 'darkMode')
                        : S.of(context, 'lightMode'),
                    iconColor: const Color(0xFFFFD93D),
                    trailing: _buildThemeSwitch(),
                    onTap: () => prov.toggleTheme(),
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.language_square,
                    label: S.of(context, 'language'),
                    iconColor: const Color(0xFF6BCB77),
                    onTap: () => _showLanguageSheet(context),
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.message_question,
                    label: S.of(context, 'help'),
                    iconColor: const Color(0xFF4ECDC4),
                    onTap: () {},
                  ),

                  _DrawerMenuItem(
                    icon: Iconsax.info_circle,
                    label: S.of(context, 'about'),
                    iconColor: const Color(0xFFB388FF),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // LOGOUT BUTTON
          if (prov.isLoggedIn)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 24),
              child: _buildLogoutButton(context),
            ),

          if (!prov.isLoggedIn)
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: bottomPadding + 24,
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.code,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool hasUser, String userName) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUser
            ? const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasUser ? null : Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: hasUser ? 0.3 : 0.1),
          width: 3,
        ),
        boxShadow: hasUser
            ? [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: hasUser
          ? Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : Icon(
              Iconsax.user,
              size: 36,
              color: Colors.white.withValues(alpha: 0.6),
            ),
    );
  }

  Widget _buildThemeSwitch() {
    return Transform.scale(
      scale: 0.7,
      child: Switch.adaptive(
        value: prov.isDarkMode,
        onChanged: (_) => prov.toggleTheme(),
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.white.withValues(alpha: 0.3),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.logout, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              S.of(context, 'logout'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
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
            _languageOption(context, 'ku', 'کوردی', '🇮🇶'),
            _languageOption(context, 'ar', 'العربية', '🇸🇦'),
            _languageOption(context, 'en', 'English', '🇺🇸'),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(
      BuildContext context, String code, String name, String flag) {
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
                  ? AppTheme.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Iconsax.tick_circle5, color: AppTheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context, 'logoutConfirmTitle'),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          S.of(context, 'logoutConfirmMessage'),
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.lightText.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context, 'cancel'),
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClose();
              prov.logoutUser();
            },
            child: Text(
              S.of(context, 'logout'),
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DRAWER MENU ITEM
// ═══════════════════════════════════════════════════════════════════════════
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.badge,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.white).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(icon, size: 22, color: iconColor ?? Colors.white),
                      ),
                      if (badge != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (trailing != null)
                  trailing!
                else
                  Icon(Iconsax.arrow_left_2, size: 16, color: Colors.white.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
