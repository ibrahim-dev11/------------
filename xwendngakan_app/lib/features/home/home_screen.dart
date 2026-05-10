import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/institutions_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/institution_type_model.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _SubFilterItem {
  final String id;
  final String name;
  final String? type;
  final String? sector;
  final IconData? icon;
  final String? emoji;

  _SubFilterItem({
    required this.id,
    required this.name,
    this.type,
    this.sector,
    this.icon,
    this.emoji,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedParentFilter = 'all'; // 'all', 'moe', 'mhe', 'others'
  String _selectedChildFilterId = 'all'; // unique id for sub-filter

  // Dynamic filters will be populated from provider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<NotificationsProvider>(context, listen: false)
          .loadUnread(auth);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Provider.of<LocaleProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final prov = Provider.of<InstitutionsProvider>(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar Header
          SliverToBoxAdapter(
            child: _buildHeader(context, l, auth, theme, isDark),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Ads Carousel
          SliverToBoxAdapter(
            child: AdsCarousel(isDark: isDark),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories / Filters Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l.educationTypes,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/institutions'),
                    child: Text(
                      l.seeAllShort,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Ministries Row (Top Row)
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildParentFilterItem(
                    key: 'all',
                    name: l.allFilter,
                    icon: Icons.grid_view_rounded,
                    isDark: isDark,
                  ),
                  _buildParentFilterItem(
                    key: 'mhe',
                    name: l.higherEducation,
                    icon: Icons.account_balance_rounded,
                    isDark: isDark,
                  ),
                  _buildParentFilterItem(
                    key: 'moe',
                    name: l.ministryOfEducation,
                    icon: Icons.school_rounded,
                    isDark: isDark,
                  ),
                  _buildParentFilterItem(
                    key: 'others',
                    name: l.otherInstitutions,
                    icon: Icons.domain_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Sub Categories Row (Bottom Row)
          if (_selectedParentFilter != 'all')
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _getSubFilters(prov.institutionTypes).map((item) {
                    return _buildSubFilterItem(
                      item: item,
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Institutions Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l.bestInstitutions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Institutions List
          if (prov.loading && prov.institutions.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: AppConstants.radiusLg,
                  ),
                  childCount: 4,
                ),
              ),
            )
          else if (prov.institutions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    l.noInstitutionsFound,
                    style: TextStyle(
                      color: isDark ? AppColors.textGrey : AppColors.textMuted,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final inst = prov.institutions[i];
                    return InstitutionCard(
                      institution: inst,
                      lang: locale.locale.languageCode,
                      isFavorite: prov.favorites.contains(inst.id),
                      onFavorite: () => prov.toggleFavorite(inst.id),
                      onTap: () => context.push('/institutions/${inst.id}'),
                    );
                  },
                  childCount: prov.institutions.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l,
      AuthProvider auth, ThemeProvider theme, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33534AB7),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Background Elements
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: User info & Actions
                  // Simplified Premium Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Logo
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                
                        // Brand Name
                        Expanded(
                          child: Text(
                            "Edu Book",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        // Action Buttons
                        Row(
                          children: [
                            _buildNotificationButton(context),
                            const SizedBox(width: 10),
                            _buildGlassButton(
                              icon: isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              onTap: () => theme.toggle(),
                              size: 40,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => context.go('/institutions'),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.primaryLight, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              l.searchHint,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                                fontFamily: 'NotoSansArabic',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  _showFilterBottomSheet(context, isDark),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.tune_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.advancedFilter,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                l.cities,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: l.filterCities.map((city) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBg
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.transparent),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              Text(
                l.ratingLevel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBg
                              : Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${5 - index}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.textDark),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded,
                            size: 16,
                            color: index == 0 ? Colors.white : Colors.amber),
                      ],
                    ),
                  );
                }),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Add filter logic later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l.applyFilter,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final notifProv = Provider.of<NotificationsProvider>(context);
    return GestureDetector(
      onTap: () {
        notifProv.markAllRead();
        context.push('/notifications');
      },
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 22),
          ),
          if (notifProv.hasUnread)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4757),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notifProv.unreadCount > 9
                        ? '9+'
                        : '${notifProv.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 44,
    double iconSize = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  List<_SubFilterItem> _getSubFilters(List<InstitutionTypeModel> allTypes) {
    final l = AppLocalizations.of(context);
    List<_SubFilterItem> items = [];
    items.add(
        _SubFilterItem(id: 'all', name: l.allFilter, icon: Icons.apps_rounded));

    if (_selectedParentFilter == 'mhe') {
      final mheKeys = ['gov', 'priv', 'inst2', 'eve_uni', 'eve_inst'];
      final mheTypes = allTypes.where((t) => mheKeys.contains(t.key));
      for (var t in mheTypes) {
        items.add(_SubFilterItem(
            id: t.key, name: t.name, type: t.key, emoji: t.emoji));
      }
    } else if (_selectedParentFilter == 'moe') {
      final moeKeys = ['school', 'kg', 'inst5'];
      final moeTypes = allTypes.where((t) => moeKeys.contains(t.key));
      for (var t in moeTypes) {
        items.add(_SubFilterItem(
            id: t.key, name: t.name, type: t.key, emoji: t.emoji));
      }
    } else if (_selectedParentFilter == 'others') {
      final knownKeys = [
        'gov',
        'priv',
        'inst5',
        'inst2',
        'eve_uni',
        'eve_inst',
        'school',
        'kg'
      ];
      final otherTypes = allTypes.where((t) => !knownKeys.contains(t.key));
      for (var t in otherTypes) {
        items.add(_SubFilterItem(
            id: t.key, name: t.name, type: t.key, emoji: t.emoji));
      }
    }

    return items;
  }

  Widget _buildParentFilterItem({
    required String key,
    required String name,
    required IconData icon,
    required bool isDark,
  }) {
    final isActive = _selectedParentFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedParentFilter = key;
          _selectedChildFilterId = 'all';
        });

        final p = Provider.of<InstitutionsProvider>(context, listen: false);
        final subCats = _getSubFilters(p.institutionTypes);

        if (key == 'all') {
          p.setFilter(type: null, sector: null);
        } else {
          // Find first available sub-category other than 'all' if present, to show some data,
          // OR just default to 'all' so it shows everything in that parent?
          // Since the API doesn't support multiple types (e.g. university AND institute),
          // we have to pick one. Let's select the first concrete child.
          final firstReal = subCats.where((s) => s.id != 'all').firstOrNull;
          if (firstReal != null) {
            setState(() {
              _selectedChildFilterId = firstReal.id;
            });
            p.setFilter(type: firstReal.type, sector: firstReal.sector);
          } else {
            p.setFilter(type: null, sector: null);
          }
        }
      },
      child: AnimatedContainer(
        duration: AppConstants.medium,
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textDark),
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubFilterItem({
    required _SubFilterItem item,
    required bool isDark,
  }) {
    final isActive = _selectedChildFilterId == item.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChildFilterId = item.id;
        });
        final p = Provider.of<InstitutionsProvider>(context, listen: false);
        p.setFilter(type: item.type ?? 'all', sector: item.sector ?? 'all');
      },
      child: AnimatedContainer(
        duration: AppConstants.medium,
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.25))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.8)
                    : AppColors.primary.withValues(alpha: 0.6))
                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            item.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : AppColors.textGrey),
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ),
      ),
    );
  }
}

// Ads Carousel
class AdsCarousel extends StatefulWidget {
  final bool isDark;
  const AdsCarousel({super.key, required this.isDark});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  List<Map<String, dynamic>> _buildAds(AppLocalizations l) => [
        {
          'title': l.adDiplomaTitle,
          'subtitle': l.adDiplomaSubtitle,
          'tag': l.adDiplomaTag,
          'colors': [const Color(0xFFD4A017), const Color(0xFFE8B84B)],
          'icon': Icons.school_rounded,
        },
        {
          'title': l.adComputerTitle,
          'subtitle': l.adComputerSubtitle,
          'tag': l.adComputerTag,
          'colors': [AppColors.primary, AppColors.primaryLight],
          'icon': Icons.computer_rounded,
        },
        {
          'title': l.adAmericanTitle,
          'subtitle': l.adAmericanSubtitle,
          'tag': l.adAmericanTag,
          'colors': [const Color(0xFF1D9E75), const Color(0xFF28B485)],
          'icon': Icons.account_balance_rounded,
        },
      ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= 3) {
          nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ads = _buildAds(l);
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
            },
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: (ad['colors'] as List).cast<Color>(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (ad['colors'][0] as Color).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      top: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    ad['tag'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  ad['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontFamily: 'NotoSansArabic',
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ad['subtitle'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2),
                            ),
                            child:
                                Icon(ad['icon'], color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: _buildAds(AppLocalizations.of(context)).length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            activeDotColor: AppColors.primary,
            dotColor: widget.isDark
                ? Colors.white24
                : AppColors.textGrey.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
