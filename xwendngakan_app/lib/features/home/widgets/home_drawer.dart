import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/locale_provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FD),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      auth.user?.name.substring(0, 1).toUpperCase() ?? 'X',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.user?.name ?? 'خوێندکار',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionTitle('ئامرازەکان', isDark),
                _buildDrawerItem(
                  context,
                  icon: Icons.psychology_rounded,
                  title: 'ڕێبەرە زیرەکەکەت',
                  subtitle: 'یارمەتیت دەدات بۆ هەڵبژاردنی بەش',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    context.pop();
                    context.push('/path-finder');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.key_rounded,
                  title: 'ونبوو و دۆزراوە',
                  subtitle: 'شتێکت لێ ون بووە؟ لێرە بڵاوی بکەرەوە',
                  color: const Color(0xFFFF4757),
                  onTap: () {
                    context.pop();
                    context.push('/lost-and-found');
                  },
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_rounded,
                  title: 'کۆچنووس (CV)',
                  subtitle: 'دروستکردنی سیڤی تایبەت بە خۆت',
                  color: const Color(0xFF2ED573),
                  onTap: () {
                    context.pop();
                    context.push('/cvs');
                  },
                  isDark: isDark,
                ),

                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 32)),

                _buildSectionTitle('ڕێکخستنەکان', isDark),
                _buildDrawerItem(
                  context,
                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  title: 'دۆخی تاریک و ڕووناک',
                  color: isDark ? Colors.amber : const Color(0xFF3742FA),
                  onTap: () => theme.toggle(),
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.translate_rounded,
                  title: 'گۆڕینی زمان',
                  color: const Color(0xFFFFA502),
                  onTap: () {
                    final newLang = locale.locale.languageCode == 'ku' ? 'ar' : 'ku';
                    locale.setLocale(newLang);
                  },
                  trailing: Text(
                    locale.locale.languageCode.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                  isDark: isDark,
                ),

                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 32)),

                _buildSectionTitle('زانیاری', isDark),
                _buildDrawerItem(
                  context,
                  icon: Icons.shield_rounded,
                  title: 'سیاسەتی تایبەتمەندی',
                  color: Colors.grey,
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'دەربارەی ئەپەکە',
                  color: Colors.grey,
                  onTap: () {},
                  isDark: isDark,
                ),
                
                const SizedBox(height: 24),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'چوونە دەرەوە',
                  color: Colors.red,
                  onTap: () {
                    context.pop();
                    auth.logout();
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white54 : Colors.black54,
          fontFamily: 'NotoSansArabic',
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textDark,
          fontFamily: 'NotoSansArabic',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
                fontFamily: 'NotoSansArabic',
              ),
            )
          : null,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white30 : Colors.black26),
      onTap: onTap,
    );
  }
}
