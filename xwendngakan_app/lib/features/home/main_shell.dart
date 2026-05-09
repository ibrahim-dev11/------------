import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/connectivity_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/news')) return 1;
    if (location.startsWith('/teachers')) return 2;
    if (location.startsWith('/cvs')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/news');
        break;
      case 2:
        context.go('/teachers');
        break;
      case 3:
        context.go('/cvs');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: l.home),
      const _NavItem(
          icon: Icons.article_outlined,
          activeIcon: Icons.article_rounded,
          label: 'هەواڵ'),
      _NavItem(
          icon: Icons.school_outlined,
          activeIcon: Icons.school_rounded,
          label: l.teachers),
      _NavItem(
          icon: Icons.work_outline_rounded,
          activeIcon: Icons.work_rounded,
          label: l.cvBank),
      _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: l.profile),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        body: Column(
          children: [
            Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                if (connectivity.isOffline) {
                  return const OfflineBanner();
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(child: child),
          ],
        ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : Colors.white)
                    .withOpacity(0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isActive = currentIndex == i;
                  return GestureDetector(
                    onTap: () => _onTap(context, i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: AppConstants.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textGrey
                                    : AppColors.textMuted),
                            size: 24,
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
