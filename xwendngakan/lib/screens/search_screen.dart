import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/institution_card.dart';
import '../widgets/premium_search_bar.dart';
import '../data/constants.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _localSearch = '';
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _hasActiveFilters(AppProvider prov) {
    return prov.filterType.isNotEmpty || prov.filterCity.isNotEmpty;
  }

  List<dynamic> _getFilteredResults(AppProvider prov) {
    if (_localSearch.isEmpty &&
        _selectedType.isEmpty &&
        !_hasActiveFilters(prov))
      return [];

    final query = _localSearch.toLowerCase();
    var results = prov.allInstitutions.where((inst) {
      if (!inst.approved) return false;

      // Search filter
      if (_localSearch.isNotEmpty) {
        final matchesSearch =
            inst.nku.toLowerCase().contains(query) ||
            inst.nen.toLowerCase().contains(query) ||
            inst.city.toLowerCase().contains(query) ||
            inst.type.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Debug print for type filtering
      if (_selectedType.isNotEmpty && inst.type != _selectedType) {
        print(
          'Filtered out: inst.type = ${inst.type} _selectedType = ${_selectedType}',
        );
        return false;
      }

      // Type filter
      if (prov.filterType.isNotEmpty && inst.type != prov.filterType) {
        print(
          'Filtered by filterType: inst.type = ${inst.type} filterType = ${prov.filterType}',
        );
        return false;
      }

      // City filter
      if (prov.filterCity.isNotEmpty && inst.city != prov.filterCity) {
        print(
          'Filtered by city: inst.city = ${inst.city} filterCity = ${prov.filterCity}',
        );
        return false;
      }

      return true;
    }).toList();

    return results;
  }

  void _showFilterBottomSheet(
    BuildContext context,
    AppProvider prov,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(prov: prov, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _getFilteredResults(prov);
    final screenW = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: Directionality.of(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF3F6FC),
          body: SafeArea(
            child: Column(
              children: [
                // Search Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                  child: PremiumSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: S.of(context, 'searchHint'),
                    autofocus: true,
                    showMic: true,
                    showFilter: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (v) => setState(() => _localSearch = v),
                    onFilterTap: () =>
                        _showFilterBottomSheet(context, prov, isDark),
                    onMicTap: () {
                      HapticFeedback.mediumImpact();
                      // Voice search
                    },
                  ),
                ),

                // Results or suggestions
                Expanded(
                  child:
                      (_localSearch.isEmpty &&
                          _selectedType.isEmpty &&
                          !_hasActiveFilters(prov))
                      ? _buildSuggestions(prov, isDark)
                      : results.isEmpty
                      ? _buildNoResults(isDark)
                      : _buildResults(results, isDark, screenW),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(AppProvider prov, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches or popular
          Row(
            children: [
              Icon(Iconsax.trend_up5, size: 20, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text(
                S.of(context, 'popularSearches'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _popularSearches(
              prov.language,
            ).map((s) => _buildSuggestionChip(s, isDark)).toList(),
          ),

          const SizedBox(height: 40),

          // Categories
          Row(
            children: [
              Icon(Iconsax.category5, size: 20, color: AppTheme.accent),
              const SizedBox(width: 10),
              Text(
                S.of(context, 'categories'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...prov.institutionTypes.map((t) {
            final key = t['key'] as String;
            final label = prov.localizedField(t, 'name');
            final iconName = t['icon'] as String? ?? 'category';
            return _buildCategoryItem(key, label, iconName, isDark);
          }),
        ],
      ),
    );
  }

  List<String> _popularSearches(String lang) {
    switch (lang) {
      case 'en':
        return [
          'Salahaddin University',
          'University of Sulaimani',
          'Institute',
          'College',
          'Erbil',
          'Sulaimani',
        ];
      case 'ar':
        return [
          'جامعة صلاح الدين',
          'جامعة السليمانية',
          'معهد',
          'كلية',
          'أربيل',
          'السليمانية',
        ];
      default:
        return [
          'زانکۆی سەلاحەدین',
          'زانکۆی سلێمانی',
          'پەیمانگا',
          'کۆلێژ',
          'هەولێر',
          'سلێمانی',
        ];
    }
  }

  Widget _buildSuggestionChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        setState(() => _localSearch = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  static IconData _iconsaxFromName(String name) {
    const map = <String, IconData>{
      'teacher': Iconsax.teacher5,
      'building_4': Iconsax.building_45,
      'book_1': Iconsax.book_15,
      'bookmark_2': Iconsax.bookmark_25,
      'house': Iconsax.house5,
      'happyemoji': Iconsax.happyemoji5,
      'heart': Iconsax.heart5,
      'translate': Iconsax.translate5,
      'buildings': Iconsax.buildings5,
      'moon': Iconsax.moon5,
      'lamp': Iconsax.lamp5,
      'category': Iconsax.category5,
      'global': Iconsax.global5,
      'medal_star': Iconsax.medal_star5,
      'briefcase': Iconsax.briefcase5,
      'chart': Iconsax.chart5,
      'cup': Iconsax.cup5,
      'music': Iconsax.music5,
      'brush': Iconsax.brush5,
      'computing': Iconsax.computing5,
      'health': Iconsax.health5,
      'microscope': Iconsax.microscope5,
    };
    return map[name] ?? Iconsax.category5;
  }

  Widget _buildCategoryItem(
    String key,
    String label,
    String iconName,
    bool isDark,
  ) {
    final colors = [AppTheme.primary, AppTheme.primary2];
    final icon = _iconsaxFromName(iconName);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = key;
          _localSearch = '';
        });
        _searchController.clear();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Premium icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.primary2.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(icon, size: 26, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.darkSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.read<AppProvider>().countByType(key)} ${S.of(context, 'institution')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Iconsax.arrow_left_2
                    : Iconsax.arrow_right_3,
                size: 18,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Iconsax.search_status5,
              size: 56,
              color: AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            S.of(context, 'noResults'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.darkSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context, 'searchDifferent'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = '';
                _localSearch = '';
              });
              _searchController.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                S.of(context, 'back'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List results, bool isDark, double screenW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                S.of(context, 'resultCount', {
                  'count': results.length.toString(),
                }),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenW > 600 ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final inst = results[i];
                return AnimationConfiguration.staggeredGrid(
                  position: i,
                  duration: const Duration(milliseconds: 600),
                  columnCount: screenW > 600 ? 3 : 2,
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    curve: Curves.easeOutQuart,
                    child: FadeInAnimation(
                      child: InstitutionCard(
                        institution: inst,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(institution: inst),
                          ),
                        ),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditScreen(institution: inst),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _FilterBottomSheet extends StatelessWidget {
  final AppProvider prov;
  final bool isDark;

  const _FilterBottomSheet({required this.prov, required this.isDark});

  bool _hasActiveFilters() {
    return prov.filterType.isNotEmpty || prov.filterCity.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 14),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Iconsax.setting_45,
                    size: 24,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'filter'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.darkSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context, 'findFavorite'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      prov.clearFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.trash5,
                            size: 16,
                            color: AppTheme.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context, 'clear'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type dropdown
                Text(
                  S.of(context, 'institutionType'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterType.isEmpty ? null : prov.filterType,
                      hint: Row(
                        children: [
                          Icon(
                            Iconsax.category5,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context, 'allTypes'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Iconsax.arrow_down_1,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      items: prov.localizedTypeLabels.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.darkSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        prov.setFilterType(v ?? '');
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // City dropdown
                Text(
                  S.of(context, 'city'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterCity.isEmpty ? null : prov.filterCity,
                      hint: Row(
                        children: [
                          Icon(
                            Iconsax.location5,
                            size: 20,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context, 'allCities'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Iconsax.arrow_down_1,
                        size: 20,
                        color: AppTheme.accent,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      items: (AppConstants.cities['عێراق'] ?? [])
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.darkSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        prov.setFilterCity(v ?? '');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.tick_circle5, color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Text(
                      S.of(context, 'apply'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
