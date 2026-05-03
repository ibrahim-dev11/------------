import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Row(
          children: [
            // User Avatar
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Iconsax.user, color: AppTheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Greeting Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بەخێربێیتەوە 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'پلان و ئامانجەکانت چییە؟',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // Notification Action
            _buildAction(Iconsax.notification, () {}),
            const SizedBox(width: 8),
            _buildAction(Iconsax.setting_2, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}
