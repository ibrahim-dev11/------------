import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelect(String lang) async {
    setState(() => _selected = lang);
    final prov = context.read<AppProvider>();
    await prov.setLanguageAndSave(lang);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001530),
              AppTheme.navy,
              AppTheme.navy2,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.gold, AppTheme.gold2],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌐', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 28),
                // Title
                const Text(
                  'زمان هەڵبژێرە',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تکایە زمانێک هەڵبژێرە بۆ بەردەوامبوون',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 40),
                // Language cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _LanguageCard(
                        label: 'کوردی',
                        subtitle: 'Kurdish',
                        flagWidget: _kurdistanFlag(30),
                        langCode: 'ku',
                        isSelected: _selected == 'ku',
                        onTap: () => _onSelect('ku'),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        label: 'العربية',
                        subtitle: 'Arabic',
                        flagWidget: const Text('🇸🇦', style: TextStyle(fontSize: 30)),
                        langCode: 'ar',
                        isSelected: _selected == 'ar',
                        onTap: () => _onSelect('ar'),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        label: 'English',
                        subtitle: 'English',
                        flagWidget: const Text('🇬🇧', style: TextStyle(fontSize: 30)),
                        langCode: 'en',
                        isSelected: _selected == 'en',
                        onTap: () => _onSelect('en'),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        label: 'Türkçe',
                        subtitle: 'Turkish',
                        flagWidget: const Text('🇹🇷', style: TextStyle(fontSize: 30)),
                        langCode: 'tr',
                        isSelected: _selected == 'tr',
                        onTap: () => _onSelect('tr'),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        label: 'Français',
                        subtitle: 'French',
                        flagWidget: const Text('🇫🇷', style: TextStyle(fontSize: 30)),
                        langCode: 'fr',
                        isSelected: _selected == 'fr',
                        onTap: () => _onSelect('fr'),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
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
}

class _LanguageCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Widget flagWidget;
  final String langCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.subtitle,
    required this.flagWidget,
    required this.langCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AppTheme.gold.withOpacity(0.15)
                : Colors.white.withOpacity(0.07),
            border: Border.all(
              color: isSelected
                  ? AppTheme.gold.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              flagWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppTheme.gold : Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.gold, AppTheme.gold2],
                    ),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
