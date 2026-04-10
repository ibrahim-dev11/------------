import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/institution_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_categories.dart';
import '../widgets/sub_tabs_bar.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/home_states.dart';
import '../widgets/results_header.dart';
import '../data/constants.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      final prov = context.read<AppProvider>();
      if (prov.hasMoreToShow && !prov.isLoading) {
        _isLoadingMore = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            prov.loadMore();
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = prov.filteredInstitutions;
    final displayed = prov.displayedInstitutions;
    final screenW = MediaQuery.of(context).size.width;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final hasSubTabs = _getSubTabs(prov.currentTab) != null;

    return Directionality(
      textDirection: Directionality.of(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => prov.fetchFromApi(),
              color: AppTheme.primary,
              backgroundColor: cardColor,
              strokeWidth: 2.5,
              child: CustomScrollView(
                controller: _scrollController,
                cacheExtent: 200,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: GreetingHeader(
                      prov: prov,
                      isDark: isDark,
                      onToggleTheme: () => prov.toggleTheme(),
                      onShowFavorites: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      ),
                      favoritesCount: prov.favoritesCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: QuickCategories(prov: prov, isDark: isDark),
                  ),
                  if (!prov.isOnline)
                    SliverToBoxAdapter(
                      child: _OfflineBanner(isDark: isDark, prov: prov),
                    ),
                  if (hasSubTabs)
                    SliverToBoxAdapter(
                      child: SubTabsBar(prov: prov, isDark: isDark),
                    ),
                  if (!prov.isLoading && filtered.isNotEmpty)
                    SliverToBoxAdapter(
                      child: ResultsHeader(
                        count: filtered.length,
                        isDark: isDark,
                      ),
                    ),
                  if (prov.isLoading)
                    SliverToBoxAdapter(child: LoadingShimmer(isDark: isDark))
                  else if (prov.hasError && filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: HomeErrorState(prov: prov, isDark: isDark),
                    )
                  else if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: HomeEmptyState(
                        prov: prov,
                        isDark: isDark,
                        searchController: _searchController,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenW > 600 ? 3 : 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final inst = displayed[i];
                            return RepaintBoundary(
                              child: InstitutionCard(
                                institution: inst,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(institution: inst),
                                  ),
                                ),
                                onEdit: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditScreen(institution: inst),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: displayed.length,
                          addRepaintBoundaries: true,
                          addAutomaticKeepAlives: false,
                        ),
                      ),
                    ),
                  if (!prov.isLoading &&
                      filtered.isNotEmpty &&
                      prov.hasMoreToShow)
                    SliverToBoxAdapter(
                      child: _LoadingMoreIndicator(isDark: isDark),
                    ),
                  if (!prov.isLoading && filtered.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>>? _getSubTabs(String tabId) {
    final tab = AppConstants.tabDefs.where((t) => t['id'] == tabId).firstOrNull;
    if (tab == null || tab['subs'] == null) return null;
    return (tab['subs'] as List).cast<Map<String, dynamic>>();
  }
}

// ── Offline Banner ──────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final bool isDark;
  final AppProvider prov;

  const _OfflineBanner({required this.isDark, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _S(context, 'noInternet'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    _S(context, 'noInternetDesc'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.orange.shade200
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => prov.fetchFromApi(),
              child: Text(
                _S(context, 'retry'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _S(BuildContext ctx, String key) {
    return prov.language == 'ar'
        ? _ar[key] ?? key
        : prov.language == 'en'
        ? _en[key] ?? key
        : _ku[key] ?? key;
  }

  static const _ku = {
    'noInternet': 'ئینتەرنەت نییە',
    'noInternetDesc': 'داتای کەش نیشاندەدرێت. پەیوەندیت بپشکنە.',
    'retry': 'دووبارە هەوڵبدەوە',
  };
  static const _ar = {
    'noInternet': 'لا يوجد اتصال بالإنترنت',
    'noInternetDesc': 'يتم عرض البيانات المخزنة. تحقق من اتصالك.',
    'retry': 'إعادة المحاولة',
  };
  static const _en = {
    'noInternet': 'No Internet Connection',
    'noInternetDesc': 'Showing cached data. Check your connection.',
    'retry': 'Retry',
  };
}

// ── Loading More Indicator ──────────────────────────────────────────

class _LoadingMoreIndicator extends StatelessWidget {
  final bool isDark;

  const _LoadingMoreIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? const Color(0xFF93C5FD) : AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
