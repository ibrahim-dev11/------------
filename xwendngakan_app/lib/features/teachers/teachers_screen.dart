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

    // Behance-Style Dynamic Filtering and Sorting
    var displayTeachers = prov.teachers;



    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async => prov.fetchTeachers(refresh: true),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // ── BEHANCE-LEVEL ARTISTIC APP BAR ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Elegant background organic glowing shapes
                      Positioned(
                        top: -40,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
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
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),

                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.teachers, 
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFamily: 'NotoSansArabic',
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                       Text(
                                        l.teachersSubtitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                          fontFamily: 'NotoSansArabic',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Floating pill search bar
                              Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: isDark ? Colors.white54 : AppColors.primaryLight,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                     Expanded(
                                       child: TextField(
                                         controller: _searchCtrl,
                                         onChanged: (v) => prov.setSearch(v),
                                         style: TextStyle(
                                           fontSize: 14.5,
                                           fontWeight: FontWeight.w600,
                                           fontFamily: 'NotoSansArabic',
                                           color: isDark ? Colors.white : const Color(0xFF1F2937),
                                         ),
                                         decoration: InputDecoration(
                                           hintText: l.searchTeacherHint,
                                           hintStyle: const TextStyle(
                                             fontSize: 13.5,
                                             fontWeight: FontWeight.w500,
                                             fontFamily: 'NotoSansArabic',
                                             color: Colors.grey,
                                           ),
                                           border: InputBorder.none,
                                           focusedBorder: InputBorder.none,
                                           enabledBorder: InputBorder.none,
                                           errorBorder: InputBorder.none,
                                           disabledBorder: InputBorder.none,
                                           contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                           isDense: true,
                                         ),
                                       ),
                                     ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _showCityFilter(context, l),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.tune_rounded,
                                          color: isDark ? Colors.white70 : AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── BEHANCE-STYLE INTERACTIVE QUICK CHIPS ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 46,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPremiumChip(
                              l.allFilter,
                              _selectedType == null,
                              () { setState(() { _selectedType = null; }); prov.setFilter(type: ''); },
                              isDark,
                              Icons.grid_view_rounded,
                            ),
                            _buildPremiumChip(
                              l.typeUniversity,
                              _selectedType == 'university',
                              () { setState(() { _selectedType = 'university'; }); prov.setFilter(type: 'university'); },
                              isDark,
                              Icons.school_rounded,
                            ),
                            _buildPremiumChip(
                              l.typeSchool,
                              _selectedType == 'school',
                              () { setState(() { _selectedType = 'school'; }); prov.setFilter(type: 'school'); },
                              isDark,
                              Icons.menu_book_rounded,
                            ),
                          ],
                        ),
                      ),
                      
                      // Selected City Badge
                      if (_selectedCity != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedCity!,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                      fontSize: 13,
                                      fontFamily: 'NotoSansArabic',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _selectedCity = null);
                                      prov.setFilter(city: '');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textGrey),
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

              // ── Teacher Listing ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: prov.loading && displayTeachers.isEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: ShimmerBox(width: double.infinity, height: 140, borderRadius: 24),
                          ),
                          childCount: 6,
                        ),
                      )
                    : displayTeachers.isEmpty
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
                                if (i >= displayTeachers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  );
                                }
                                return TeacherCard(
                                  teacher: displayTeachers[i],
                                  lang: lang,
                                  onTap: () => context.push('/teachers/${displayTeachers[i].id}'),
                                );
                              },
                              childCount: displayTeachers.length + (prov.hasMore ? 1 : 0),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : (isDark ? const Color(0xFF262626) : const Color(0xFFEDF2F7)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityFilter(BuildContext context, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final prov = Provider.of<TeachersProvider>(context, listen: false);
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.filterByCity2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.iraqiCities.map((city) {
                  final sel = _selectedCity == city;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedCity = city);
                      prov.setFilter(city: city);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? AppColors.primaryGradient : null,
                        color: sel ? null : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        city,
                        style: TextStyle(
                          color: sel ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
