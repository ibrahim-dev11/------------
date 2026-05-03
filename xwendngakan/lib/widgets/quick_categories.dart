import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class QuickCategories extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;

  const QuickCategories({super.key, required this.prov, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mainTabs = prov.tabs;
    final subTabs = prov.subTabs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Tabs (Glass Container) ──
        if (mainTabs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 54,
              padding: const EdgeInsets.all(5),
              decoration: AppTheme.glassDecoration(isDark: isDark, radius: 18),
              child: Row(
                children: mainTabs.map((tab) {
                  final id = tab['id'] as String;
                  final isSelected = prov.currentTab == id;
                  final label = prov.localizedField(tab, 'label');

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        prov.setTab(id);
                      },
                      child: AnimatedContainer(
                        duration: AppTheme.animFast,
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.primaryGradient : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected ? AppTheme.premiumShadow(AppTheme.primary) : null,
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // ── Sub Categories (Chips) ──
        if (subTabs.isNotEmpty) ...[
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: subTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final sub = subTabs[index];
                final id = sub['id'] as String;
                final isSelected = prov.currentSub == id || (id == 'all' && prov.currentSub.isEmpty);
                final label = prov.localizedField(sub, 'label');

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    prov.setSub(id == 'all' ? '' : id);
                  },
                  child: AnimatedContainer(
                    duration: AppTheme.animFast,
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.black12),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
