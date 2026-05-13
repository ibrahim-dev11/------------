import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/locale_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool fromSettings;
  const LanguageSelectionScreen({super.key, this.fromSettings = false});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLang = 'en';

  static const List<_LangOption> _languages = [
    _LangOption(
      code: 'ku',
      name: 'کوردی (سۆرانی)',
      subtitle: 'Kurdish · Sorani',
      flagType: _FlagType.kurdistan,
      iconColor: Color(0xFFC49A3C),
      isRTL: true,
    ),
    _LangOption(
      code: 'kbd',
      name: 'کوردی (بادینی)',
      subtitle: 'Kurdish · Badini',
      flagType: _FlagType.kurdistan,
      iconColor: Color(0xFFE0B856),
      isRTL: true,
    ),
    _LangOption(
      code: 'ar',
      name: 'العربية',
      subtitle: 'Arabic · عربی',
      flagType: _FlagType.emoji,
      flag: '🇮🇶',
      iconColor: Color(0xFF22C55E),
      isRTL: true,
    ),
    _LangOption(
      code: 'en',
      name: 'English',
      subtitle: 'ئینگلیزی · الإنجليزية',
      flagType: _FlagType.emoji,
      flag: '🇬🇧',
      iconColor: Color(0xFF3B82F6),
      isRTL: false,
    ),
  ];

  Future<void> _confirm() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(_selectedLang);

    if (!mounted) return;

    if (widget.fromSettings) {
      context.pop();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.langSelectedKey, true);
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App name badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Edu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.selectLanguage,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Rabar',
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Section Label ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l.language,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Rabar',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Language List ───────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = _selectedLang == lang.code;
                  return _LangTile(
                    lang: lang,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedLang = lang.code),
                  );
                },
              ),
            ),

            // ── Confirm Button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.next,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Rabar',
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────

enum _FlagType { kurdistan, emoji }

class _LangOption {
  final String code;
  final String name;
  final String subtitle;
  final _FlagType flagType;
  final String? flag; // emoji, only when flagType == emoji
  final Color iconColor;
  final bool isRTL;

  const _LangOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flagType,
    this.flag,
    required this.iconColor,
    required this.isRTL,
  });
}

// ─── Kurdistan flag widget ────────────────────────────────────────────────────

class _KurdistanFlag extends StatelessWidget {
  const _KurdistanFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 36,
        height: 24,
        child: Column(
          children: [
            // Red stripe
            Expanded(child: Container(color: const Color(0xFFCC0000))),
            // White stripe with sun
            Expanded(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Text(
                  '☀',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFFD700),
                    height: 1,
                  ),
                ),
              ),
            ),
            // Green stripe
            Expanded(child: Container(color: const Color(0xFF007A3D))),
          ],
        ),
      ),
    );
  }
}

// ─── Language Tile ────────────────────────────────────────────────────────────

class _LangTile extends StatelessWidget {
  final _LangOption lang;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LangTile({
    required this.lang,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? lang.iconColor.withValues(alpha: 0.08)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isSelected
              ? lang.iconColor.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Flag box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: lang.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: lang.flagType == _FlagType.kurdistan
                    ? const _KurdistanFlag()
                    : Text(
                        lang.flag ?? '',
                        style: const TextStyle(fontSize: 22),
                      ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Text(
                  lang.name,
                  textDirection: lang.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Rabar',
                    color: isSelected
                        ? lang.iconColor
                        : (isDark ? Colors.white : AppColors.textDark),
                  ),
                ),
              ),
              // Checkmark
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Container(
                        key: const ValueKey('check'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: lang.iconColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    : Container(
                        key: const ValueKey('empty'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
