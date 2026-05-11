import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/institutions_provider.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/common_widgets.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Provider.of<LocaleProvider>(context);
    final lang = locale.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F7FF),
      body: RefreshIndicator(
        onRefresh: () async =>
            Provider.of<InstitutionsProvider>(context, listen: false)
                .fetchInstitutions(refresh: true),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── AppBar ──────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F7FF),
            elevation: 0,
            title: Text(
              l.savedInstitutions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1a1a1a),
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),

          // ── Content ─────────────────────────────
          Consumer<InstitutionsProvider>(
            builder: (context, prov, _) {
              final saved = prov.favoriteInstitutions;

              if (saved.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.bookmark_border_rounded,
                    message: l.noFavorites,
                    actionLabel: l.browseInstitutions,
                    onAction: () => context.go('/home'),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.76,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final inst = saved[i];
                      return InstitutionCard(
                        institution: inst,
                        lang: lang,
                        isFavorite: true,
                        onFavorite: () => prov.toggleFavorite(inst.id),
                        onTap: () => context.push('/institutions/${inst.id}'),
                      );
                    },
                    childCount: saved.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      )  
    );
  }
}
