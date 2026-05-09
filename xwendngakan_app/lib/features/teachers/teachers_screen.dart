import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/teachers_cv_provider.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/common_widgets.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _selectedType;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeachersProvider>(context, listen: false)
          .fetchTeachers(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        Provider.of<TeachersProvider>(context, listen: false).fetchTeachers();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Provider.of<LocaleProvider>(context);
    final prov = Provider.of<TeachersProvider>(context);
    final lang = locale.locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FA),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async => prov.fetchTeachers(refresh: true),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.teachers,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${prov.teachers.length} مامۆستای پسپۆڕ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontFamily: 'NotoSansArabic',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Modern Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              ),
                            ),
                            child: AppSearchBar(
                              controller: _searchCtrl,
                              hint: l.searchHint,
                              onChanged: (v) => prov.setSearch(v),
                              onFilterTap: () => _showCityFilter(context, l),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Horizontal Filter Chips
                          SizedBox(
                            height: 48,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildPremiumChip('هەموو', _selectedType == null, () {
                                  setState(() => _selectedType = null);
                                  prov.setFilter(type: '');
                                }, isDark, Icons.grid_view_rounded),
                                _buildPremiumChip('زانکۆ', _selectedType == 'university', () {
                                  setState(() => _selectedType = 'university');
                                  prov.setFilter(type: 'university');
                                }, isDark, Icons.account_balance_rounded),
                                _buildPremiumChip('قوتابخانە', _selectedType == 'school', () {
                                  setState(() => _selectedType = 'school');
                                  prov.setFilter(type: 'school');
                                }, isDark, Icons.menu_book_rounded),
                              ],
                            ),
                          ),
                          
                          // Selected City Filter Badge
                          if (_selectedCity != null) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF374151) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedCity!,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                                          fontSize: 14,
                                          fontFamily: 'NotoSansArabic',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() => _selectedCity = null);
                                          prov.setFilter(city: '');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFF3F4F6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Teacher List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: prov.loading && prov.teachers.isEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: ShimmerBox(width: double.infinity, height: 120, borderRadius: 24),
                          ),
                          childCount: 6,
                        ),
                      )
                    : prov.teachers.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: EmptyState(
                                icon: Icons.people_outline_rounded,
                                message: l.noResults,
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) {
                                if (i >= prov.teachers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return TeacherCard(
                                  teacher: prov.teachers[i],
                                  lang: lang,
                                  onTap: () => context.push('/teachers/${prov.teachers[i].id}'),
                                  isFavorite: prov.isFavorite(prov.teachers[i].id),
                                  onFavorite: () {
                                    HapticFeedback.lightImpact();
                                    prov.toggleFavorite(prov.teachers[i].id);
                                  },
                                );
                              },
                              childCount: prov.teachers.length + (prov.hasMore ? 1 : 0),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumChip(String label, bool selected, VoidCallback onTap, bool isDark, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF374151)),
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityFilter(BuildContext context, AppLocalizations l) {
    HapticFeedback.mediumImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.filterByCity,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppConstants.iraqiCities.map((city) {
                    final isSelected = _selectedCity == city;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedCity = city);
                        Navigator.pop(sheetContext);
                        Provider.of<TeachersProvider>(context, listen: false).setFilter(city: city);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                        child: Text(
                          city,
                          style: TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
