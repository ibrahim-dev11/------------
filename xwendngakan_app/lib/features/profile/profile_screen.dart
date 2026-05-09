import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/institutions_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/teachers_cv_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final instProv = Provider.of<InstitutionsProvider>(context);
    final teachProv = Provider.of<TeachersProvider>(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHero(
              auth: auth,
              isDark: isDark,
              l: l,
              savedCount: instProv.favoriteInstitutions.length,
              teacherFavCount: teachProv.favoriteTeachers.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      label: 'سیاسەتی تایبەتمەندی',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  if (auth.isAuthenticated) ...[
                    _CvProgressCard(isDark: isDark, l: l),
                    const SizedBox(height: 24),
                    _SectionLabel(label: l.profile),
                    const SizedBox(height: 8),
                    _SettingsGroup(isDark: isDark, children: [
                      _NavTile(
                        icon: Icons.notifications_rounded,
                        iconBg: const Color(0xFFE05C8A),
                        label: l.notifications,
                        onTap: () => context.push('/notifications'),
                      ),
                      _Divider(isDark: isDark),
                      _NavTile(
                        icon: Icons.settings_rounded,
                        iconBg: const Color(0xFF3A7DD4),
                        label: l.settings,
                        onTap: () => context.push('/settings'),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _LogoutTile(isDark: isDark, l: l, auth: auth),
                  ] else ...[
                    _LoginPrompt(l: l),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'v1.0.0  •  خوێندنگاکانم',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontFamily: 'NotoSansArabic',
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
  final int savedCount;
  final int teacherFavCount;

  const _ProfileHero({
    required this.auth,
    required this.isDark,
    required this.l,
    required this.savedCount,
    required this.teacherFavCount,
  });

  @override
  Widget build(BuildContext context) {
    final initials = auth.isAuthenticated && (auth.user?.name.isNotEmpty == true)
        ? auth.user!.name.trim().split(' ').take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3E389A), Color(0xFF534AB7), Color(0xFF7F77DD)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            children: [
              _Avatar(initials: initials, size: 90),
              const SizedBox(height: 14),
              if (auth.isAuthenticated) ...[
                Text(
                  auth.user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'NotoSansArabic',
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    auth.user?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'NotoSansArabic'),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBubble(icon: Icons.bookmark_rounded, count: savedCount, label: l.saved),
                    _StatDivider(),
                    _StatBubble(icon: Icons.favorite_rounded, count: teacherFavCount, label: l.teachers),
                  ],
                ),
              ] else ...[
                Text(l.guest,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'NotoSansArabic')),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/login'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Text(l.login,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700,
                            fontSize: 14, fontFamily: 'NotoSansArabic')),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? initials;
  final double size;
  const _Avatar({this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF9B95E8), Color(0xFF534AB7)],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: const Color(0xFF534AB7).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: initials != null
          ? Center(
              child: Text(initials!,
                  style: TextStyle(fontSize: size * 0.34, color: Colors.white,
                      fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic')))
          : const Icon(Icons.person_rounded, size: 40, color: Colors.white),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  const _StatBubble({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60, fontFamily: 'NotoSansArabic')),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white.withOpacity(0.25));
}

// ─── Settings Components ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(label.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.1, color: Colors.grey.shade500, fontFamily: 'NotoSansArabic')),
  );
}

class _SettingsGroup extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsGroup({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
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
    child: Divider(height: 0.5, thickness: 0.5,
        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      fontFamily: 'NotoSansArabic', color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: 'NotoSansArabic')),
                  ],
                ]),
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
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              fontFamily: 'NotoSansArabic', color: isDark ? Colors.white : const Color(0xFF1A1A2E)))),
          Transform.scale(scale: 0.85, child: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary)),
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
          title: Text(l.logout, style: const TextStyle(fontFamily: 'NotoSansArabic')),
          content: Text(l.logoutConfirm, style: const TextStyle(fontFamily: 'NotoSansArabic')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
            TextButton(
              onPressed: () {
                context.pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  auth.logout();
                });
              },
              child: Text(l.logout, style: const TextStyle(color: Color(0xFFFF4757))),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFFFF4757).withOpacity(isDark ? 0.2 : 0.1),
            const Color(0xFFFF6B81).withOpacity(isDark ? 0.12 : 0.06),
          ]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.35)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout_rounded, color: Color(0xFFFF4757), size: 20),
          const SizedBox(width: 10),
          Text(l.logout, style: const TextStyle(color: Color(0xFFFF4757),
              fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'NotoSansArabic')),
        ]),
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
          AppColors.primary.withOpacity(0.08),
          AppColors.primaryLight.withOpacity(0.04),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(children: [
        const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 36),
        const SizedBox(height: 12),
        Text(l.login, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: AppColors.primary, fontFamily: 'NotoSansArabic')),
        const SizedBox(height: 6),
        Text(l.noAccount, style: const TextStyle(fontSize: 13, color: AppColors.textGrey,
            fontFamily: 'NotoSansArabic'), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.push('/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Text(l.login, style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'NotoSansArabic')),
          ),
        ),
      ]),
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
            color: isDark ? const Color(0xFF1E1E2E).withOpacity(0.95) : Colors.white.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.35), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                const _IconBadge(icon: Icons.language_rounded, bg: Color(0xFF1D9E75)),
                const SizedBox(width: 12),
                Text(l.language, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'NotoSansArabic')),
              ]),
            ),
            const SizedBox(height: 12),
            ...AppConstants.languages.entries.map((e) {
              final selected = locale.locale.languageCode == e.key;
              return _LangTile(flag: e.value['flag'] ?? '', name: e.value['name'] ?? '',
                  selected: selected, isDark: isDark, onTap: () { locale.setLocale(e.key); Navigator.pop(context); });
            }),
            const SizedBox(height: 24),
          ]),
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
        color: selected ? AppColors.primary.withOpacity(isDark ? 0.2 : 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(child: Text(name, style: TextStyle(fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: 'NotoSansArabic', color: selected ? AppColors.primary : null))),
              if (selected)
                Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CvProgressCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  const _CvProgressCard({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    const double progress = 0.65; // Mock progress for demonstration
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_ind_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تەواوکردنی کۆچنووس (CV)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    Text(
                      'بۆ ئەوەی زیاتر دەرفەتی کارت بۆ بڕەخسێت',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/cv-form'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'بەردەوامبە لە پڕکردنەوە',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
