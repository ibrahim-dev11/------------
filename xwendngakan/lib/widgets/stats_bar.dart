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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
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
                    icon: Iconsax.lovely, color: AppTheme.accent),
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
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder.withValues(alpha: 0.5) : AppTheme.lightBorder,
        ),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                num,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
