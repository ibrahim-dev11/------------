import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/teachers_cv_provider.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/common_widgets.dart';

class CvScreen extends StatefulWidget {
  const CvScreen({super.key});
  @override
  State<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends State<CvScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CvProvider>(context, listen: false).fetchCvs(refresh: true).then((_) {
        _animCtrl.forward();
      });
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        Provider.of<CvProvider>(context, listen: false).fetchCvs();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prov = Provider.of<CvProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      floatingActionButton: _buildPremiumFAB(context, l, isDark),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async => prov.fetchCvs(refresh: true),
          color: AppColors.primary,
          child: Stack(
            children: [
              // ── Artistic Background Decorative Blobs ──
              RepaintBoundary(
                child: Stack(
                  children: [
                    Positioned(
                      top: -150,
                      right: -100,
                      child: _CircularBlob(
                        size: 400,
                        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: -80,
                      child: _CircularBlob(
                        size: 300,
                        color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.1 : 0.04),
                      ),
                    ),
                  ],
                ),
              ),

              CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // ── Premium Artistic App Bar ──
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
                                          Icons.description_rounded,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l.cvBank,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                fontFamily: 'Rabar',
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              l.cvBankSubtitle,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                                fontFamily: 'Rabar',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Floating pill search bar (inside the app bar)
                                  _buildSearchBar(isDark, l, prov),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Active Filters Row ──
                  if (prov.selectedCity != null || prov.selectedEducation != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: FadeTransition(
                          opacity: _fade,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (prov.selectedCity != null)
                                _buildActiveFilterChip(
                                  icon: Icons.location_on_rounded,
                                  label: prov.selectedCity!,
                                  onClear: () => prov.setFilter(city: null, education: prov.selectedEducation),
                                ),
                              if (prov.selectedEducation != null)
                                _buildActiveFilterChip(
                                  icon: Icons.school_rounded,
                                  label: prov.selectedEducation!,
                                  onClear: () => prov.setFilter(city: prov.selectedCity, education: null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── CV List ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                    sliver: prov.loading && prov.cvs.isEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, __) => const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: ShimmerBox(width: double.infinity, height: 110, borderRadius: 24),
                              ),
                              childCount: 6,
                            ),
                          )
                        : prov.cvs.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: EmptyState(
                                    icon: Icons.description_outlined,
                                    message: l.noResults,
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) {
                                    if (i >= prov.cvs.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    
                                    // Staggered Animation for each card
                                    final delay = (i % 6) * 0.05;
                                    final itemFade = Tween<double>(begin: 0, end: 1).animate(
                                      CurvedAnimation(
                                        parent: _animCtrl,
                                        curve: Interval(delay, delay + 0.4 > 1.0 ? 1.0 : delay + 0.4, curve: Curves.easeOut),
                                      ),
                                    );
                                    final itemSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                                      CurvedAnimation(
                                        parent: _animCtrl,
                                        curve: Interval(delay, delay + 0.4 > 1.0 ? 1.0 : delay + 0.4, curve: Curves.easeOutBack),
                                      ),
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: FadeTransition(
                                        opacity: itemFade,
                                        child: SlideTransition(
                                          position: itemSlide,
                                          child: CvCard(
                                            cv: prov.cvs[i],
                                            onTap: () => context.push('/cvs/${prov.cvs[i].id}'),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: prov.cvs.length + (prov.hasMore ? 1 : 0),
                                ),
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l, CvProvider prov) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => prov.setSearch(v),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rabar',
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: l.searchCvHint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Rabar',
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          _VerticalDivider(isDark: isDark),
          const SizedBox(width: 4),
          _FilterIcon(
            onTap: () => _showAdvancedFilter(context, l, prov),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFAB(BuildContext context, AppLocalizations l, bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.push('/cv-form'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        label: Text(
          l.createCv,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontFamily: 'Rabar',
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildActiveFilterChip({required IconData icon, required String label, required VoidCallback onClear}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontFamily: 'Rabar',
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilter(BuildContext context, AppLocalizations l, CvProvider prov) {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AdvancedFilterSheet(prov: prov),
    );
  }
}

class _AdvancedFilterSheet extends StatefulWidget {
  final CvProvider prov;
  const _AdvancedFilterSheet({required this.prov});

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  String? _city;
  String? _education;
  
  final List<String> _eduLevels = [
    'خوێندنی ناوەندی',
    'ئامادەیی',
    'دیپلۆم',
    'بکالۆریۆس',
    'ماستەر',
    'دکتۆرا'
  ];

  @override
  void initState() {
    super.initState();
    _city = widget.prov.selectedCity;
    _education = widget.prov.selectedEducation;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + 94 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'فلتەری پێشکەوتوو',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Rabar',
                    ),
              ),
              const SizedBox(height: 24),
              
              // City Section
              Text(
                'شار / شوێنی نیشتەجێبوون',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Rabar',
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _city,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                hint: Text('هەموو شارەکان', style: TextStyle(fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black38)),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('هەموو شارەکان', style: TextStyle(fontFamily: 'Rabar')),
                  ),
                  ...AppConstants.iraqiCities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city, style: const TextStyle(fontFamily: 'Rabar')),
                    );
                  })
                ],
                onChanged: (v) => setState(() => _city = v),
              ),
              
              const SizedBox(height: 24),
              
              // Education Section
              Text(
                'ئاستی خوێندن',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Rabar',
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _eduLevels.map((edu) {
                  final isSelected = _education == edu;
                  return GestureDetector(
                    onTap: () => setState(() => _education = isSelected ? null : edu),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                        ),
                      ),
                      child: Text(
                        edu,
                        style: TextStyle(
                          fontFamily: 'Rabar',
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    widget.prov.setFilter(city: _city, education: _education);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'جێبەجێکردنی فلتەر',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Rabar',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Artistic Background Decorative Blob ──
class _CircularBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _CircularBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _BackIcon extends StatelessWidget {
  final bool isDark;
  const _BackIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final bool isDark;
  const _NotificationIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;
  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }
}

class _FilterIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _FilterIcon({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
      ),
    );
  }
}
