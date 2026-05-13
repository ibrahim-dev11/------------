import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHero(
              auth: auth,
              isDark: isDark,
              l: l,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (auth.isAuthenticated) ...[
                    _SectionLabel(label: l.myAccount),
                    const SizedBox(height: 8),
                    _SettingsGroup(isDark: isDark, children: [
                      _NavTile(
                        icon: Icons.notifications_rounded,
                        iconBg: const Color(0xFFE05C8A),
                        label: l.notifications,
                        onTap: () => context.push('/notifications'),
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                  _SectionLabel(label: l.settings),
                  const SizedBox(height: 8),
                  _SettingsGroup(isDark: isDark, children: [
                    _SwitchTile(
                      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      iconBg: isDark ? const Color(0xFF7F77DD) : const Color(0xFF534AB7),
                      label: l.darkMode,
                      value: isDark,
                      onChanged: (_) => theme.toggle(),
                    ),
                    _Divider(isDark: isDark),
                    _NavTile(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFF1D9E75),
                      label: l.language,
                      subtitle: AppConstants.languages[locale.locale.languageCode]?['name'] ?? '',
                      onTap: () => _showLanguagePicker(context, locale, l),
                    ),
                    _Divider(isDark: isDark),
                    _NavTile(
                      icon: Icons.privacy_tip_rounded,
                      iconBg: const Color(0xFFFF6B35),
                      label: l.privacyPolicy,
                      onTap: () => context.push('/privacy-policy'),
                    ),
                  ]),
                  const SizedBox(height: 56),
                  if (auth.isAuthenticated) ...[
                    _LogoutTile(isDark: isDark, l: l, auth: auth),
                  ] else ...[
                    _LoginPrompt(l: l),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'v1.0.0  •  ${l.appName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontFamily: 'Rabar',
                      ),
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

  void _showLanguagePicker(BuildContext context, LocaleProvider locale, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(locale: locale, l: l),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final AuthProvider auth;
  final bool isDark;
  final AppLocalizations l;

  const _ProfileHero({
    required this.auth,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final initials = auth.isAuthenticated && (auth.user?.name.isNotEmpty == true)
        ? auth.user!.name.trim().split(' ').take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(initials: initials, size: 68, isDark: isDark),
                    const SizedBox(height: 12),
                    if (auth.isAuthenticated) ...[
                      Text(
                        auth.user?.name ?? '',
                        style: const TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Rabar',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?.email ?? '',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Rabar',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Text(
                        l.guest,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Rabar',
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            l.login,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFamily: 'Rabar',
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _Avatar extends StatelessWidget {
  final String? initials;
  final double size;
  final bool isDark;
  const _Avatar({this.initials, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: const Color(0xFFF59E0B), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: initials != null
          ? Center(
              child: Text(
                initials!,
                style: TextStyle(
                  fontSize: size * 0.34,
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Rabar',
                ),
              ),
            )
          : const Icon(Icons.person_rounded, size: 32, color: Color(0xFFF59E0B)),
    );
  }
}

// ─── Settings Components ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade500,
        fontFamily: 'Rabar',
      ),
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsGroup({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 64),
    child: Divider(
      height: 0.5,
      thickness: 0.5,
      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
    ),
  );
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  const _IconBadge({required this.icon, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: Colors.white, size: 19),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  const _NavTile({required this.icon, required this.iconBg, required this.label, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              _IconBadge(icon: icon, bg: iconBg),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Rabar',
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontFamily: 'Rabar',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white30 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.iconBg, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBadge(icon: icon, bg: iconBg),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rabar',
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          Transform.scale(scale: 0.85, child: Switch.adaptive(value: value, onChanged: onChanged)),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final AuthProvider auth;
  const _LogoutTile({required this.isDark, required this.l, required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l.logout, style: const TextStyle(fontFamily: 'Rabar', fontWeight: FontWeight.w800)),
          content: Text(l.logoutConfirm, style: const TextStyle(fontFamily: 'Rabar', fontWeight: FontWeight.w500)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel, style: const TextStyle(fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () {
                context.pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  auth.logout();
                });
              },
              child: Text(l.logout, style: const TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFFFF4757).withValues(alpha: isDark ? 0.2 : 0.1),
            const Color(0xFFFF6B81).withValues(alpha: isDark ? 0.12 : 0.06),
          ]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFF4757).withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.exit_to_app_rounded, color: Color(0xFFFF4757), size: 20),
            const SizedBox(width: 10),
            Text(
              l.logout,
              style: const TextStyle(
                color: Color(0xFFFF4757),
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFamily: 'Rabar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final AppLocalizations l;
  const _LoginPrompt({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.primaryLight.withValues(alpha: 0.04),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 36),
          const SizedBox(height: 12),
          Text(
            l.login,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              fontFamily: 'Rabar',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.noAccount,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontFamily: 'Rabar',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                l.login,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Rabar',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language Sheet ───────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final LocaleProvider locale;
  final AppLocalizations l;
  const _LanguageSheet({required this.locale, required this.l});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const _IconBadge(icon: Icons.language_rounded, bg: Color(0xFF1D9E75)),
                    const SizedBox(width: 12),
                    Text(
                      l.language,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Rabar',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...AppConstants.languages.entries.map((e) {
                final selected = locale.locale.languageCode == e.key;
                return _LangTile(
                  flag: e.value['flag'] ?? '',
                  name: e.value['name'] ?? '',
                  selected: selected,
                  isDark: isDark,
                  onTap: () {
                    locale.setLocale(e.key);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag, name;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _LangTile({required this.flag, required this.name, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                flag == '❤️☀️💚'
                    ? const KurdishFlag(width: 28, height: 19)
                    : Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      fontFamily: 'Rabar',
                      color: selected ? AppColors.primary : null,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KurdishFlag extends StatelessWidget {
  final double width;
  final double height;
  const KurdishFlag({super.key, this.width = 28, this.height = 19});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.5),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: Container(color: const Color(0xFFE53935))), // Red
                Expanded(child: Container(color: Colors.white)),            // White
                Expanded(child: Container(color: const Color(0xFF43A047))), // Green
              ],
            ),
            Center(
              child: Container(
                width: height * 0.48,
                height: height * 0.48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB300), // Golden yellow
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  size: 6,
                  color: Color(0xFFFF6F00), // Orange rays
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
