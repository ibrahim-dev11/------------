import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/institution_model.dart';
import '../../data/models/post_model.dart';
import '../../data/services/api_service.dart';
import '../../providers/institutions_provider.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class InstitutionDetailScreen extends StatefulWidget {
  final String id;
  const InstitutionDetailScreen({super.key, required this.id});

  @override
  State<InstitutionDetailScreen> createState() =>
      _InstitutionDetailScreenState();
}

class _InstitutionDetailScreenState extends State<InstitutionDetailScreen> {
  final _api = ApiService();
  InstitutionModel? _institution;
  bool _loading = true;
  String? _error;
  int _activeTab = 0; // 0: About, 1: Colleges, 2: Posts
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await _api.getInstitution(int.tryParse(widget.id) ?? 0);
    if (!mounted) return;
    if (r.success && r.data != null) {
      setState(() {
        _institution = r.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = r.error;
        _loading = false;
      });
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Provider.of<LocaleProvider>(context);
    final prov = Provider.of<InstitutionsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = locale.locale.languageCode;

    if (_loading) {
      return _buildShimmerLoading(context, isDark);
    }

    if (_error != null || _institution == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.institutions)),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          message: _error ?? 'Not found',
          actionLabel: l.retry,
          onAction: () => _load(),
        ),
      );
    }

    final inst = _institution!;
    final typeColor = AppColors.typeColor(inst.type);
    final isFav = prov.favorites.contains(inst.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFFBFBFE),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
          // ── Premium Sliver Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: typeColor,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 22,
                        ),
                        onPressed: () => prov.toggleFavorite(inst.id),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showTitle ? 1.0 : 0.0,
              child: Text(
                inst.name(lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Rabar',
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover image background
                    if (inst.imgUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: inst.imgUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: typeColor),
                        errorWidget: (_, __, ___) => Container(color: typeColor),
                      )
                    else
                      Container(color: typeColor),
                    // Dark gradient overlay for legibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            typeColor.withValues(alpha: 0.90),
                          ],
                        ),
                      ),
                    ),
                    // Logo Circle
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: inst.logoUrl.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: CachedNetworkImage(
                                        imageUrl: inst.logoUrl,
                                        fit: BoxFit.contain,
                                        placeholder: (_, __) => Icon(Icons.school_rounded, color: typeColor, size: 45),
                                        errorWidget: (_, __, ___) => Icon(Icons.school_rounded, color: typeColor, size: 45),
                                      ),
                                    )
                                  : Icon(Icons.school_rounded, color: typeColor, size: 45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // ── Name & Info ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        inst.name(lang),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Rabar',
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Secondary language names
                      if (lang != 'en' && inst.nen != null && inst.nen!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          inst.nen!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : AppColors.textDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                      if (lang == 'en' && inst.nku != null && inst.nku!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          inst.nku!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Rabar',
                            color: isDark ? Colors.white54 : AppColors.textDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (inst.city != null && inst.city!.isNotEmpty)
                            _InfoChip(icon: Icons.location_city_rounded, label: inst.city!, color: typeColor),
                          if (inst.country != null && inst.country!.isNotEmpty)
                            _InfoChip(icon: Icons.flag_rounded, label: inst.country!, color: const Color(0xFF6366F1)),
                          if (inst.type != null && inst.type!.isNotEmpty)
                            _InfoChip(icon: Icons.school_rounded, label: inst.type!, color: const Color(0xFFF59E0B)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Modern Action Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionItem(
                        icon: Icons.phone_in_talk_rounded,
                        label: l.contact,
                        color: const Color(0xFF10B981),
                        onTap: inst.phone != null ? () => _launch('tel:${inst.phone}') : () {},
                      ),
                      _buildActionItem(
                        icon: Icons.map_rounded,
                        label: l.map,
                        color: const Color(0xFFEC4899),
                        onTap: () => context.push('/map'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Premium Tab Switcher ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, l.about, isDark),
                      _buildTabItem(1, l.departments, isDark),
                      _buildTabItem(2, l.news, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tab Content ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: KeyedSubtree(
                      key: ValueKey(_activeTab),
                      child: _buildTabContent(inst, isDark, lang, l),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'Rabar',
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              fontFamily: 'Rabar',
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white60 : AppColors.textDark.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(InstitutionModel inst, bool isDark, String lang, AppLocalizations l) {
    switch (_activeTab) {
      case 0: // About
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            _StatsRow(isDark: isDark, inst: inst),
            const SizedBox(height: 28),

            // Description
            if (inst.desc != null && inst.desc!.isNotEmpty) ...[
              _AcademicSection(
                icon: Icons.info_outline_rounded,
                title: l.about,
                accentColor: AppColors.typeColor(inst.type),
                isDark: isDark,
                child: Text(
                  inst.desc!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.9,
                    fontFamily: 'Rabar',
                    color: isDark ? Colors.white70 : AppColors.textDark.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Video
            if (inst.video != null && inst.video!.isNotEmpty) ...[
              _VideoCard(
                videoUrl: inst.video!,
                isDark: isDark,
                typeColor: AppColors.typeColor(inst.type),
                onTap: () => _launch(inst.video!),
              ),
              const SizedBox(height: 20),
            ],

            // Contact & Social
            _AcademicSection(
              icon: Icons.contact_page_rounded,
              title: l.contact,
              accentColor: AppColors.typeColor(inst.type),
              isDark: isDark,
              child: _ContactCard(inst: inst, isDark: isDark, onLaunch: _launch),
            ),
          ],
        );
      case 1: // Colleges & Departments
        final colleges = _parseColleges(inst.colleges);
        final depts = _parseDepts(inst.depts);
        if (colleges.isEmpty && depts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: EmptyState(
              icon: Icons.account_balance_outlined,
              message: l.noInformation,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (colleges.isNotEmpty)
              _CollegesCard(colleges: colleges, isDark: isDark, l: l),
            if (depts.isNotEmpty) ...[
              if (colleges.isNotEmpty) const SizedBox(height: 20),
              _AcademicSection(
                icon: Icons.menu_book_rounded,
                title: l.departments,
                accentColor: AppColors.typeColor(inst.type),
                isDark: isDark,
                child: Column(
                  children: depts.map((dept) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.typeColor(inst.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rabar',
                              color: isDark ? Colors.white70 : AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        );
      case 2: // Posts
        if (inst.posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: EmptyState(
              icon: Icons.article_outlined,
              message: l.noPosts,
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: inst.posts.length,
          itemBuilder: (context, index) => _PostCard(post: inst.posts[index], isDark: isDark),
        );
      default:
        return const SizedBox();
    }
  }

  List<Map<String, dynamic>> _parseColleges(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final trimmed = raw.trim();
    
    // 1. Try JSON format
    if (trimmed.startsWith('[')) {
      try {
        final List<dynamic> decoded = jsonDecode(trimmed);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }
    
    // 2. Fallback to comma-separated string
    return trimmed.split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => {'name': s.trim(), 'departments': []})
        .toList();
  }

  List<String> _parseDepts(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final trimmed = raw.trim();
    if (trimmed.startsWith('[')) {
      try {
        final List<dynamic> decoded = jsonDecode(trimmed);
        return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return trimmed.split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
  }

  Widget _buildShimmerLoading(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ShimmerBox(width: double.infinity, height: 280, borderRadius: 0),
            const SizedBox(height: 32),
            const ShimmerBox(width: 250, height: 28, borderRadius: 12),
            const SizedBox(height: 12),
            const ShimmerBox(width: 150, height: 20, borderRadius: 8),
            const SizedBox(height: 40),
            Row(
              children: List.generate(3, (i) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ShimmerBox(width: double.infinity, height: 80, borderRadius: 16),
                ),
              )),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ShimmerBox(width: double.infinity, height: 64, borderRadius: 24),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 24, borderRadius: 8),
                  SizedBox(height: 16),
                  ShimmerBox(width: double.infinity, height: 120, borderRadius: 20),
                  SizedBox(height: 32),
                  ShimmerBox(width: double.infinity, height: 90, borderRadius: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Academic Section Card ────────────────────────────────────────────────────

class _AcademicSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final bool isDark;
  final Widget child;
  const _AcademicSection({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with left accent bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Rabar',
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Rabar',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isDark;
  final InstitutionModel inst;
  const _StatsRow({required this.isDark, required this.inst});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().year;
    final yearsExp =
        inst.foundedYear != null ? '${now - inst.foundedYear!}+' : '—';
    final studentsStr = inst.studentsCount != null
        ? inst.studentsCount! >= 1000
            ? '${(inst.studentsCount! / 1000).toStringAsFixed(1)}k+'
            : '${inst.studentsCount}+'
        : '—';

    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        children: [
          _StatItem(
              value: inst.foundedYear?.toString() ?? '—',
              label: l.foundedYearLabel,
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFFF59E0B)),
          const _VDivider(),
          _StatItem(
              value: yearsExp,
              label: l.experienceYears,
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primary),
          const _VDivider(),
          _StatItem(
              value: studentsStr,
              label: l.studentsLabel,
              icon: Icons.groups_rounded,
              color: const Color(0xFF10B981)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontFamily: 'Rabar')),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                  fontFamily: 'Rabar')),
        ]),
      );
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.1));
}

// ─── Video card ───────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final String videoUrl;
  final bool isDark;
  final Color typeColor;
  final VoidCallback onTap;
  const _VideoCard(
      {required this.videoUrl, required this.isDark, required this.typeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor.withValues(alpha: 0.8), typeColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.watchVideo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Rabar',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact card ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final InstitutionModel inst;
  final bool isDark;
  final Function(String) onLaunch;
  const _ContactCard(
      {required this.inst, required this.isDark, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    void add(IconData icon, String label, Color color, String? url) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 10));
      items.add(_ContactTile(
        icon: icon,
        label: label,
        color: color,
        isDark: isDark,
        onTap: url != null ? () => onLaunch(url) : () {},
      ));
    }

    if (inst.addr != null && inst.addr!.isNotEmpty)
      add(Icons.location_on_rounded, inst.addr!, const Color(0xFFF43F5E), null);
    if (inst.phone != null && inst.phone!.isNotEmpty)
      add(Icons.phone_rounded, inst.phone!, const Color(0xFF10B981), 'tel:${inst.phone}');
    if (inst.email != null && inst.email!.isNotEmpty)
      add(Icons.email_rounded, inst.email!, const Color(0xFF3B82F6), 'mailto:${inst.email}');
    if (inst.web != null && inst.web!.isNotEmpty)
      add(Icons.language_rounded, inst.web!, const Color(0xFF6366F1), inst.web);
    if (inst.fb != null && inst.fb!.isNotEmpty)
      add(Icons.facebook, 'Facebook', const Color(0xFF1877F2), inst.fb);
    if (inst.ig != null && inst.ig!.isNotEmpty)
      add(Icons.camera_alt_rounded, 'Instagram', const Color(0xFFE4405F), inst.ig);
    if (inst.tg != null && inst.tg!.isNotEmpty)
      add(Icons.telegram_rounded, 'Telegram', const Color(0xFF229ED9), inst.tg);
    if (inst.wa != null && inst.wa!.isNotEmpty)
      add(Icons.chat_bubble_outline_rounded, 'WhatsApp', const Color(0xFF25D366), 'https://wa.me/${inst.wa}');

    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _ContactTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Colleges Card ────────────────────────────────────────────────────────────

class _CollegesCard extends StatelessWidget {
  final List<Map<String, dynamic>> colleges;
  final bool isDark;
  final AppLocalizations l;
  const _CollegesCard(
      {required this.colleges, required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: colleges.map((college) {
        final departments = college['departments'] as List<dynamic>? ?? [];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
            collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
            ),
            title: Text(
              college['name'] ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontFamily: 'Rabar',
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              if (departments.isEmpty)
                Text(l.noInformation, style: const TextStyle(fontSize: 13, color: AppColors.textGrey))
              else
                ...departments.map((dept) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dept.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Rabar',
                                color: isDark ? Colors.white70 : AppColors.textDark.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool isDark;
  const _PostCard({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerBox(width: double.infinity, height: 200, borderRadius: 0),
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Rabar',
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.white70 : AppColors.textDark.withValues(alpha: 0.7),
                    fontFamily: 'Rabar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
