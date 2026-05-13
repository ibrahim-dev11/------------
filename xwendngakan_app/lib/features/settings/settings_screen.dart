import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final isDark = theme.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            _SectionLabel(label: '🎨 ${l.appearance}'),
            const SizedBox(height: 10),
            _SettingTile(
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              label: l.darkMode,
              trailing: Switch(
                value: isDark,
                onChanged: (_) => theme.toggle(),
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),
            // Language
            _SectionLabel(label: '🌍 ${l.language}'),
            const SizedBox(height: 10),
            _SettingTile(
              icon: Icons.translate_rounded,
              label: l.selectLanguage,
              subtitle: AppConstants.languages[locale.locale.languageCode]?['name'] ?? '',
              onTap: () => context.push('/language-select?from=settings'),
            ),

            const SizedBox(height: 20),
            // About
            _SectionLabel(label: 'ℹ️ ${l.about}'),
            const SizedBox(height: 10),
            _SettingTile(
              icon: Icons.info_outline_rounded,
              label: l.about,
              subtitle: 'v1.0.0',
            ),
            _SettingTile(
              icon: Icons.privacy_tip_outlined,
              label: l.privacyPolicy,
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.help_outline_rounded,
              label: l.helpCenter,
              onTap: () {},
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontFamily: 'Rabar', fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 12, fontFamily: 'Rabar')) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
