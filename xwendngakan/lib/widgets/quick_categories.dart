import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class QuickCategories extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;

  const QuickCategories({
    super.key,
    required this.prov,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = prov.tabs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context, 'categories'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tabs.length,
            itemBuilder: (context, i) {
              final tab = tabs[i];
              final key = tab['id'] as String;
              final isOn = prov.currentTab == key;
              final label = prov.localizedField(tab, 'label');
              final cleanLabel = label.replaceFirst(RegExp(r'^[^\s]+\s'), '').trim();

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => prov.setTab(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isOn 
                        ? AppTheme.primary 
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: isOn
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        cleanLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isOn ? FontWeight.w900 : FontWeight.w600,
                          color: isOn ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
