import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/institution_card.dart';
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
    if (_localSearch.isEmpty && _selectedType.isEmpty && !_hasActiveFilters(prov)) return [];

    final query = _localSearch.toLowerCase();
    var results = prov.allInstitutions.where((inst) {
      if (!inst.approved) return false;

      // Search filter
      if (_localSearch.isNotEmpty) {
        final matchesSearch = inst.nku.toLowerCase().contains(query) ||
               inst.nen.toLowerCase().contains(query) ||
               inst.city.toLowerCase().contains(query) ||
               inst.type.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Debug print for type filtering
      if (_selectedType.isNotEmpty && inst.type != _selectedType) {
        print('Filtered out: inst.type = ${inst.type} _selectedType = ${_selectedType}');
        return false;
      }

      // Type filter
      if (prov.filterType.isNotEmpty && inst.type != prov.filterType) {
        print('Filtered by filterType: inst.type = ${inst.type} filterType = ${prov.filterType}');
        return false;
      }

      // City filter
      if (prov.filterCity.isNotEmpty && inst.city != prov.filterCity) {
        print('Filtered by city: inst.city = ${inst.city} filterCity = ${prov.filterCity}');
        return false;
      }

      return true;
    }).toList();

    return results;
  }

  void _showFilterBottomSheet(BuildContext context, AppProvider prov, bool isDark) {
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
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F6FC),
          body: SafeArea(
            child: Column(
              children: [
                // Search Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      // Back button
                     
                      const SizedBox(width: 12),
                      // Search field
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            onChanged: (v) => setState(() => _localSearch = v),
                            textDirection: Directionality.of(context),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: S.of(context, 'searchHint'),
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[200] : Colors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Iconsax.search_normal_1,
                                size: 20,
                                color: AppTheme.primary,
                              ),
                              suffixIcon: (_localSearch.isNotEmpty || _selectedType.isNotEmpty)
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _localSearch = '';
                                          _selectedType = '';
                                        });
                                      },
                                      child: Icon(
                                        Iconsax.close_circle5,
                                        size: 20,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter button
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context, prov, isDark),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Iconsax.setting_4,
                                size: 20,
                                color: isDark ? Colors.grey[200] : Colors.grey[600],
                              ),
                              if (_hasActiveFilters(prov))
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Results or suggestions
                Expanded(
                  child: (_localSearch.isEmpty && _selectedType.isEmpty && !_hasActiveFilters(prov))
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches or popular
          Row(
            children: [
              Icon(
                Iconsax.trend_up,
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context, 'popularSearches'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSearches(prov.language).map((s) =>
              _buildSuggestionChip(s, isDark),
            ).toList(),
          ),

          const SizedBox(height: 32),

          // Categories
          Row(
            children: [
              Icon(
                Iconsax.category,
                size: 18,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context, 'categories'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        return ['Salahaddin University', 'University of Sulaimani', 'Institute', 'College', 'Erbil', 'Sulaimani'];
      case 'ar':
        return ['جامعة صلاح الدين', 'جامعة السليمانية', 'معهد', 'كلية', 'أربيل', 'السليمانية'];
      default:
        return ['زانکۆی سەلاحەدین', 'زانکۆی سلێمانی', 'پەیمانگا', 'کۆلێژ', 'هەولێر', 'سلێمانی'];
    }
  }

  Widget _buildSuggestionChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        setState(() => _localSearch = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[200] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  static IconData _iconsaxFromName(String name) {
    const map = <String, IconData>{
      'teacher': Iconsax.teacher,
      'building_4': Iconsax.building_4,
      'book_1': Iconsax.book_1,
      'bookmark_2': Iconsax.bookmark_2,
      'house': Iconsax.house,
      'happyemoji': Iconsax.happyemoji,
      'heart': Iconsax.heart,
      'translate': Iconsax.translate,
      'buildings': Iconsax.buildings,
      'moon': Iconsax.moon,
      'lamp': Iconsax.lamp,
      'category': Iconsax.category,
      'global': Iconsax.global,
      'medal_star': Iconsax.medal_star,
      'briefcase': Iconsax.briefcase,
      'chart': Iconsax.chart,
      'cup': Iconsax.cup,
      'music': Iconsax.music,
      'brush': Iconsax.brush,
      'computing': Iconsax.computing,
      'health': Iconsax.health,
      'microscope': Iconsax.microscope,
    };
    return map[name] ?? Iconsax.category;
  }

  Widget _buildCategoryItem(String key, String label, String iconName, bool isDark) {
    final colors = AppConstants.typeGradients[key] ?? [Colors.grey, Colors.grey];
    
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: colors[1].withOpacity(isDark ? 0.08 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 3D-style icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[1].withOpacity(isDark ? 0.25 : 0.15),
                    colors[1].withOpacity(isDark ? 0.10 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors[1].withOpacity(isDark ? 0.2 : 0.12),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer for depth
                  Positioned(
                    bottom: 2,
                    child: Icon(
                      icon,
                      size: 22,
                      color: colors[0].withOpacity(0.15),
                    ),
                  ),
                  // Main icon
                  Icon(
                    icon,
                    size: 22,
                    color: colors[1],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.read<AppProvider>().countByType(key)} ${S.of(context, 'institution')}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors[1].withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors[1].withOpacity(isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.arrow_left_2,
                size: 16,
                color: colors[1],
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.search_status,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context, 'noResults'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[200] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context, 'searchDifferent'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = '';
                _localSearch = '';
              });
              _searchController.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                S.of(context, 'back'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(
            S.of(context, 'resultCount', {'count': results.length.toString()}),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenW > 600 ? 3 : 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.65,
              ),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final inst = results[i];
                return AnimationConfiguration.staggeredGrid(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  columnCount: screenW > 600 ? 3 : 2,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: InstitutionCard(
                        institution: inst,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(institution: inst)),
                        ),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditScreen(institution: inst)),
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

  const _FilterBottomSheet({
    required this.prov,
    required this.isDark,
  });

  bool _hasActiveFilters() {
    return prov.filterType.isNotEmpty || prov.filterCity.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primary.withOpacity(0.15),
                        AppTheme.accent.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Iconsax.setting_4, size: 22, color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context, 'filter'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      S.of(context, 'findFavorite'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: () => prov.clearFilters(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.trash, size: 16, color: AppTheme.danger),
                          const SizedBox(width: 6),
                          Text(
                            S.of(context, 'clear'),
                             style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.danger),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
          ),
          
          // Filter options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type dropdown
                Text(
                  S.of(context, 'institutionType'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterType.isEmpty ? null : prov.filterType,
                      hint: Row(
                        children: [
                          Icon(Iconsax.category, size: 18, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context, 'allTypes'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(Iconsax.arrow_down_1, size: 18, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      items: prov.localizedTypeLabels.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                              ))
                          .toList(),
                      onChanged: (v) => prov.setFilterType(v ?? ''),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // City dropdown
                Text(
                  S.of(context, 'city'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prov.filterCity.isEmpty ? null : prov.filterCity,
                      hint: Row(
                        children: [
                          Icon(Iconsax.location, size: 18, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context, 'allCities'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      icon: Icon(Iconsax.arrow_down_1, size: 18, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF9CA3AF)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      items: (AppConstants.cities['عێراق'] ?? [])
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                              ))
                          .toList(),
                      onChanged: (v) => prov.setFilterCity(v ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Apply button
          Padding(
            padding:  EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding:  EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF6366F1), AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      S.of(context, 'apply'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
