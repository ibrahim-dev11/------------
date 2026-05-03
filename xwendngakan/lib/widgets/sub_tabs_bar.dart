import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../data/constants.dart';
import '../theme/app_theme.dart';

class SubTabsBar extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;

  const SubTabsBar({
    super.key,
    required this.prov,
    required this.isDark,
  });

  List<Map<String, dynamic>>? _getSubTabs(String tabId) {
    final tab = AppConstants.tabDefs.where((t) => t['id'] == tabId).firstOrNull;
    if (tab == null || tab['subs'] == null) return null;
    return (tab['subs'] as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final subs = _getSubTabs(prov.currentTab);
    if (subs == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: subs.map((sub) {
              final subId = sub['id'] as String;
              final isOn = prov.currentSub == subId || (prov.currentSub.isEmpty && subId.contains('_all'));
              final cnt = prov.subTabCount(subId);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => prov.setSub(subId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOn 
                        ? (isDark ? AppTheme.primary.withValues(alpha: 0.2) : Colors.white) 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isOn && !isDark ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : [],
                    ),
                    child: Row(
                      children: [
                        Text(
                          prov.localizedField(sub, 'label'),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: isOn ? FontWeight.w800 : FontWeight.w600,
                            color: isOn
                                ? (isDark ? AppTheme.primary : AppTheme.primary)
                                : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                          ),
                        ),
                        if (cnt > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$cnt',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isOn
                                    ? AppTheme.primary
                                    : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
