import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: subs.map((sub) {
                final subId = sub['id'] as String;
                final isOn = prov.currentSub == subId || (prov.currentSub.isEmpty && subId.contains('_all'));
                final cnt = prov.subTabCount(subId);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => prov.setSub(subId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOn ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isOn
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Text(
                            prov.localizedField(sub, 'label'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isOn ? FontWeight.w700 : FontWeight.w600,
                              color: isOn
                                  ? AppTheme.primary
                                  : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8)),
                            ),
                          ),
                          if (cnt > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOn
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$cnt',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isOn
                                      ? AppTheme.primary
                                      : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B)),
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
      ),
    );
  }

  bool hasSubTabs(String tabId) => _getSubTabs(tabId) != null;
}
