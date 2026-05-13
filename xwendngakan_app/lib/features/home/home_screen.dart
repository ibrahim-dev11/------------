import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../data/models/banner_model.dart';
import '../../data/services/api_service.dart';
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
        body: RefreshIndicator(
          onRefresh: () async {
            await prov.fetchStats();
            await prov.fetchAppData();
            await prov.fetchInstitutions(refresh: true);
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
                  child: Text(
                    l.educationTypes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Rabar',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      children:
                          _getSubFilters(prov.institutionTypes).map((item) {
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l.bestInstitutions,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Rabar',
                          ),
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
                            fontFamily: 'Rabar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Institutions List
              if (prov.loading && prov.institutions.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          color:
                              isDark ? AppColors.textGrey : AppColors.textMuted,
                          fontFamily: 'Rabar',
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
        ));
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo + Brand Name — start side (right in RTL, left in LTR)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  letterSpacing: -0.3,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'edu ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'book',
                                    style: TextStyle(color: Color(0xFFFFD54F)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Action Buttons — end side (left in RTL, right in LTR)
                        _buildGlassButton(
                          icon: isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          onTap: () => theme.toggle(),
                          size: 40,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 10),
                        _buildNotificationButton(context),
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
                                fontFamily: 'Rabar',
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
    final prov = Provider.of<InstitutionsProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // selectedCity stores the Kurdish DB value (e.g. 'هەولێر')
        String selectedCity = prov.selectedCity;
        String selectedSector = prov.selectedSector == '' ? 'all' : prov.selectedSector;
        String selectedType = prov.selectedType;

        // Map: localized display name → Kurdish API value
        final cityEntries = List.generate(
          l.filterCities.length,
          (i) => MapEntry(l.filterCities[i], AppConstants.filterCityApiValues[i]),
        );

        return StatefulBuilder(
          builder: (ctx, setState) {
            final bottomInset = MediaQuery.of(ctx).padding.bottom;
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Handle + Header (fixed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.advancedFilter,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textDark,
                                fontFamily: 'Rabar',
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: Icon(Icons.close_rounded,
                                  color: isDark ? Colors.white70 : Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── شارەکان ──
                          Text(
                            l.cities,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textDark,
                              fontFamily: 'Rabar',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: cityEntries.map((entry) {
                              final isSelected = selectedCity == entry.value;
                              return _FilterChip(
                                label: entry.key,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () => setState(() {
                                  selectedCity = isSelected ? '' : entry.value;
                                }),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 28),

                          // ── بواری دامەزراوە ──
                          Text(
                            l.institutionType,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textDark,
                              fontFamily: 'Rabar',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _FilterChip(
                                label: l.public,
                                isSelected: selectedSector == 'public',
                                isDark: isDark,
                                icon: Icons.account_balance_rounded,
                                onTap: () => setState(() {
                                  selectedSector = selectedSector == 'public' ? 'all' : 'public';
                                }),
                              ),
                              _FilterChip(
                                label: l.private,
                                isSelected: selectedSector == 'private',
                                isDark: isDark,
                                icon: Icons.business_rounded,
                                onTap: () => setState(() {
                                  selectedSector = selectedSector == 'private' ? 'all' : 'private';
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ── جۆری دامەزراوە ──
                          if (prov.institutionTypes.isNotEmpty) ...[
                            Text(
                              l.institutionTypes,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.textDark,
                                fontFamily: 'Rabar',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: prov.institutionTypes.map((t) {
                                final isSelected = selectedType == t.key;
                                return _FilterChip(
                                  label: '${t.emoji ?? ''} ${t.name}'.trim(),
                                  isSelected: isSelected,
                                  isDark: isDark,
                                  onTap: () => setState(() {
                                    selectedType = isSelected ? '' : t.key;
                                  }),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Fixed bottom buttons
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomInset),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              prov.clearFilters();
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              l.clear,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Rabar',
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              prov.setFilter(
                                city: selectedCity,
                                sector: selectedSector,
                                type: selectedType.isEmpty ? 'all' : selectedType,
                              );
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              l.applyFilter,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Rabar',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
              fontFamily: 'Rabar',
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
              fontFamily: 'Rabar',
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable filter chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : (isDark ? AppColors.darkBg : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : Colors.transparent),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white54 : AppColors.textMuted)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rabar',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : AppColors.textDark),
              ),
            ),
          ],
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
  List<BannerModel>? _apiBanners;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    final result = await ApiService().getBanners();
    if (mounted && result.success && result.data != null && result.data!.isNotEmpty) {
      setState(() => _apiBanners = result.data);
    }
    _startAutoPlay();
  }

  List<Map<String, dynamic>> _staticAds(AppLocalizations l) => [
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

  Color _hexColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return AppColors.primary;
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final count = _apiBanners?.length ?? 3;
      int next = _currentPage + 1;
      if (next >= count) {
        next = 0;
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn);
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn);
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

    if (_apiBanners != null) {
      return _buildCarousel(_apiBanners!.length, (index) {
        final b = _apiBanners![index];
        return _apiBannerCard(b);
      });
    }

    final static_ = _staticAds(l);
    return _buildCarousel(static_.length, (index) {
      return _staticBannerCard(static_[index]);
    });
  }

  Widget _buildCarousel(int count, Widget Function(int) builder) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: count,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: builder(i),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: count,
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

  Widget _apiBannerCard(BannerModel b) {
    final c1 = _hexColor(b.colorStart);
    final c2 = _hexColor(b.colorEnd);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: b.imageUrl != null
          ? _imageLayer(b)
          : _gradientLayer(
              title: b.title,
              subtitle: b.subtitle ?? '',
              tag: b.tag ?? '',
              colors: [c1, c2],
              icon: Icons.campaign_rounded,
            ),
    );
  }

  Widget _imageLayer(BannerModel b) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: b.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _hexColor(b.colorStart)),
          errorWidget: (_, __, ___) => Container(color: _hexColor(b.colorStart)),
        ),
        // Bottom gradient for text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.72),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Text anchored at bottom
        Positioned(
          bottom: 14,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (b.tag != null && b.tag!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    b.tag!,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Rabar',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                b.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Rabar',
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (b.subtitle != null && b.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  b.subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    fontFamily: 'Rabar',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradientLayer({
    required String title,
    required String subtitle,
    required String tag,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Watermark icon in background
        Positioned(
          right: -10,
          bottom: -10,
          child: Icon(
            icon,
            size: 110,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        // Text content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tag.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Rabar',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Rabar',
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Rabar',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _staticBannerCard(Map<String, dynamic> ad) {
    final colors = (ad['colors'] as List).cast<Color>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _gradientLayer(
        title: ad['title'] as String,
        subtitle: ad['subtitle'] as String,
        tag: ad['tag'] as String,
        colors: colors,
        icon: ad['icon'] as IconData,
      ),
    );
  }
}
