import 'package:flutter/material.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class ResultsHeader extends StatelessWidget {
  final int count;
  final bool isDark;

  const ResultsHeader({
    super.key,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context, 'institution'), // Or your localized key for 'Institutions'
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 14,
                  color: AppTheme.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
