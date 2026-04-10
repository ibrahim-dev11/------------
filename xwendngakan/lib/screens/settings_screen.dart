import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F6FC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Header ──
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.15),
                        AppTheme.accent.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Iconsax.setting_2, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'settings'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Account Card ──
            _buildAccountCard(context, prov, isDark, cardBg, borderColor, textPrimary, textSecondary),

            const SizedBox(height: 16),

            // ── Preferences Group ──
            _sectionLabel(S.of(context, 'appearance'), textSecondary),
            const SizedBox(height: 8),
            _buildGroupCard(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              children: [
                _groupTile(
                  icon: isDark ? Iconsax.moon5 : Iconsax.sun_15,
                  iconBg: isDark ? const Color(0xFFFDE68A) : const Color(0xFFF59E0B),
                  title: isDark ? S.of(context, 'darkMode') : S.of(context, 'lightMode'),
                  subtitle: S.of(context, 'changeAppTheme'),
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  trailing: Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => prov.toggleTheme(),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppTheme.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                _divider(isDark),
                _languageTile(context, prov, isDark, textPrimary, textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            // ── About Group ──
            _sectionLabel(S.of(context, 'about'), textSecondary),
            const SizedBox(height: 8),
            _buildGroupCard(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              children: [
                // App info tile
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('📚', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context, 'appName'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      S.of(context, 'appDescription'),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.8,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                _divider(isDark),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse('https://www.facebook.com/profile.php?id=61559861546507'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: _groupTile(
                    icon: Iconsax.code_1,
                    iconBg: AppTheme.accent,
                    title: S.of(context, 'developer'),
                    subtitle: 'ibrahim dev',
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  Widget _sectionLabel(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
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
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
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
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Directionality(
                textDirection: Directionality.of(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      S.of(context, 'chooseLanguage'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...languages.map((lang) {
                      final isSelected = lang['code'] == prov.language;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              prov.setLanguageAndSave(lang['code']!);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.4)
                                      : isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (lang['code'] == 'ku')
                                    _kurdistanFlag(24)
                                  else
                                    Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      lang['name']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? AppTheme.primary : textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Iconsax.tick_circle5, color: AppTheme.primary, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.global, color: Color(0xFF0EA5E9), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context, 'language'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current['name']!,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (current['code'] == 'ku')
                    _kurdistanFlag(16)
                  else
                    Text(current['flag']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Icon(
                    Iconsax.arrow_down_1,
                    size: 14,
                    color: textSecondary,
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
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF1A2332)]
                      : [const Color(0xFFF0F4FF), const Color(0xFFF8F9FE)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.accent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          S.of(context, 'active'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF1A2332)]
                    : [const Color(0xFFF0F4FF), const Color(0xFFF8F9FE)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(isDark ? 0.15 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.user, size: 30, color: AppTheme.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  S.of(context, 'notLoggedIn'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.of(context, 'loginForFeatures'),
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Iconsax.login, size: 18),
                label: Text(S.of(context, 'login')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.logout, color: AppTheme.danger, size: 30),
            ),
            title: Text(
              S.of(context, 'logout'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            content: Text(
              S.of(context, 'logoutConfirm'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
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
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Text(
                  S.of(context, 'no'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
          color: AppTheme.danger.withOpacity(isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.danger.withOpacity(isDark ? 0.2 : 0.15),
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
