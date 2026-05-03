import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:xwendngakan/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../widgets/institution_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final textColor = isDark ? Colors.white : AppTheme.lightText;

    final favorites = prov.favoriteInstitutions;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium frosted app bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor.withValues(alpha: 0.9),
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppTheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(
                  prov.isRtl ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2,
                  color: textColor,
                  size: 16,
                ),
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.heart5, color: AppTheme.danger, size: 20),
                const SizedBox(width: 10),
                Text(
                  S.of(context, 'favorites'),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${favorites.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            centerTitle: true,
          ),

          // ── Body ──
          if (favorites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _FavEmptyState(isDark: isDark),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: AnimationLimiter(
                child: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final inst = favorites[index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        duration: const Duration(milliseconds: 600),
                        child: ScaleAnimation(
                          scale: 0.95,
                          child: FadeInAnimation(
                            child: InstitutionCard(
                              institution: inst,
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      DetailScreen(institution: inst),
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  reverseTransitionDuration:
                                      const Duration(milliseconds: 400),
                                  transitionsBuilder: (_, anim, __, child) {
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOut,
                                      ),
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.05),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOutQuart,
                                        )),
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onEdit: () {},
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ANIMATED EMPTY STATE
// ═══════════════════════════════════════════════════════
class _FavEmptyState extends StatefulWidget {
  final bool isDark;
  const _FavEmptyState({required this.isDark});
  @override
  State<_FavEmptyState> createState() => _FavEmptyStateState();
}

class _FavEmptyStateState extends State<_FavEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -8 * _ctrl.value),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppTheme.darkCard
                    : AppTheme.lightSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Iconsax.heart5,
                size: 64,
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context, 'noFavorites'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? AppTheme.textPrimary : AppTheme.lightText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              S.of(context, 'noFavoritesDesc'),
              style: TextStyle(
                fontSize: 15,
                color: widget.isDark
                    ? AppTheme.textSecondary
                    : AppTheme.lightTextSub,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
