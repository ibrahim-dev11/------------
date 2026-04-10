import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, prov, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statCard('${prov.totalApproved}', S.of(context, 'total'), isDark,
                    icon: Iconsax.element_plus, color: AppTheme.primary),
                const SizedBox(width: 8),
                _statCard('${prov.countByType('gov')}', S.of(context, 'government'), isDark,
                    icon: Iconsax.teacher, color: const Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                _statCard('${prov.countByType('priv')}', S.of(context, 'private'), isDark,
                    icon: Iconsax.building_4, color: AppTheme.accent),
                const SizedBox(width: 8),
                _statCard(
                    '${prov.countByType('inst5') + prov.countByType('inst2')}',
                    S.of(context, 'institute'),
                    isDark,
                    icon: Iconsax.book, color: const Color(0xFF0369A1)),
                const SizedBox(width: 8),
                _statCard('${prov.countByType('school')}', S.of(context, 'school'), isDark,
                    icon: Iconsax.building, color: const Color(0xFFF97316)),
                const SizedBox(width: 8),
                _statCard('${prov.countByType('kg')}', S.of(context, 'kindergarten'), isDark,
                    icon: Iconsax.lovely, color: const Color(0xFFEC4899)),
                const SizedBox(width: 8),
                _statCard('${prov.totalCities}', S.of(context, 'city'), isDark,
                    icon: Iconsax.location, color: AppTheme.success),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String num, String label, bool isDark,
      {required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                num,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
