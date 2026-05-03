import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'tutorial_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? AppTheme.darkCard : AppTheme.lightBorder;
    final textPrimary = isDark ? Colors.white : AppTheme.darkSurface;
    final textSecondary = isDark ? AppTheme.textPrimary : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 400),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 30,
                child: FadeInAnimation(child: widget),
              ),
              children: [
            // ── Header ──
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Iconsax.setting_25, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'settings'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context, 'customizeExperience'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Account Card ──
            _buildAccountCard(context, prov, isDark, cardBg, borderColor, textPrimary, textSecondary),

            const SizedBox(height: 24),

            // ── Preferences Group ──
            _sectionLabel(S.of(context, 'appearance'), textSecondary),
            const SizedBox(height: 12),
            _buildGroupCard(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              children: [
                _groupTile(
                  icon: isDark ? Iconsax.moon5 : Iconsax.sun_15,
                  iconBg: isDark ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  title: isDark ? S.of(context, 'darkMode') : S.of(context, 'lightMode'),
                  subtitle: S.of(context, 'changeAppTheme'),
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  context: context,
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isDark,
                      onChanged: (_) {
                        HapticFeedback.mediumImpact();
                        prov.toggleTheme();
                      },
                      activeColor: Colors.white,
                      activeTrackColor: AppTheme.primary,
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                ),
                _divider(isDark),
                _languageTile(context, prov, isDark, textPrimary, textSecondary),
              ],
            ),
            const SizedBox(height: 24),
            // ── Support Group ──
            _sectionLabel(S.of(context, 'support'), textSecondary),
            const SizedBox(height: 12),
            _buildGroupCard(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              children: [
                _groupTile(
                  icon: Iconsax.teacher5,
                  iconBg: const Color(0xFFF43F5E),
                  title: S.of(context, 'tutorial'),
                  subtitle: S.of(context, 'tutorialDesc'),
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  context: context,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialScreen()),
                    );
                  },
                ),
                _divider(isDark),
                _groupTile(
                  icon: Iconsax.info_circle5,
                  iconBg: AppTheme.primary,
                  title: S.of(context, 'about'),
                  subtitle: S.of(context, 'appDescription').substring(0, 30) + '...',
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  context: context,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AboutScreen(),
                        transitionsBuilder: (_, anim, __, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart)),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _sectionLabel(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _groupTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    Widget? trailing,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconBg, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null && onTap != null)
                Icon(
                  Directionality.of(context) == TextDirection.rtl 
                      ? Iconsax.arrow_left_2 : Iconsax.arrow_right_3,
                  size: 16,
                  color: textSecondary.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: isDark ? Colors.white.withValues(alpha: 0.03) : AppTheme.lightBorder.withValues(alpha: 0.5),
    );
  }

  Widget _languageTile(
    BuildContext context,
    AppProvider prov,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final languages = [
      {'code': 'ku', 'name': S.of(context, 'kurdish'), 'flag': ''},
      {'code': 'ar', 'name': S.of(context, 'arabic'), 'flag': '🇸🇦'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    ];
    final current = languages.firstWhere(
      (l) => l['code'] == prov.language,
      orElse: () => languages.first,
    );

    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Directionality(
                textDirection: prov.isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      S.of(context, 'chooseLanguage'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...languages.map((lang) {
                      final isSelected = lang['code'] == prov.language;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              prov.setLanguageAndSave(lang['code']!);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withValues(alpha: 0.08)
                                    : isDark ? AppTheme.darkCard : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary.withValues(alpha: 0.3)
                                      : isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (lang['code'] == 'ku')
                                    _kurdistanFlag(24)
                                  else
                                    Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      lang['name']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? AppTheme.primary : textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Iconsax.tick_circle5, color: AppTheme.primary, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Iconsax.global5, color: AppTheme.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context, 'language'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (current['code'] == 'ku')
                    _kurdistanFlag(16)
                  else
                    Text(current['flag']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Icon(
                    Iconsax.arrow_down_1,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kurdistanFlag(double size) {
    final h = size * 0.75;
    final w = h * 1.4;
    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Column(
          children: [
            Expanded(
              child: Container(color: const Color(0xFFED1C24)),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Icon(
                    Icons.wb_sunny,
                    color: const Color(0xFFFFC72C),
                    size: h * 0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(color: const Color(0xFF009639)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AppProvider prov,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (prov.isLoggedIn && prov.currentUser != null) {
      final user = prov.currentUser!;
      final name = user['name'] as String? ?? '';
      final email = user['email'] as String? ?? '';
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.emeraldGlowGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.premiumShadow(AppTheme.primary),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          S.of(context, 'active'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: _LogoutButton(prov: prov),
            ),
          ],
        ),
      );
    }

    // Not logged in
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withValues(alpha: 0.5)
                  : AppTheme.lightBg.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.user5, size: 36, color: AppTheme.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  S.of(context, 'notLoggedIn'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context, 'loginForFeatures'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (_, anim, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                          child: child,
                        );
                      },
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Iconsax.login5, size: 20),
                label: Text(
                  S.of(context, 'login'),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final AppProvider prov;
  const _LogoutButton({required this.prov});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoading = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Directionality(
          textDirection: Directionality.of(ctx),
          child: AlertDialog(
            backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.logout, color: AppTheme.danger, size: 30),
            ),
            title: Text(
              S.of(context, 'logout'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.darkSurface,
              ),
            ),
            content: Text(
              S.of(context, 'logoutConfirm'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextSub,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? AppTheme.textSecondary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                child: Text(
                  S.of(context, 'no'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextSub,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child:  Text(
                  S.of(context, 'yesLogout'),
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    await widget.prov.logoutUser();
    if (!mounted) return;
    setState(() => _isLoading = false);

    AppSnackbar.success(context, S.of(context, 'loggedOutSuccess'));

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: _isLoading ? null : _logout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.danger.withValues(alpha: isDark ? 0.2 : 0.15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.danger,
                ),
              )
            else
              Icon(Iconsax.logout, size: 16, color: AppTheme.danger),
            const SizedBox(width: 8),
            Text(
              _isLoading ? S.of(context, 'loading') : S.of(context, 'logout'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
