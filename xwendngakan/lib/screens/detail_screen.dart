import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final Institution institution;

  const DetailScreen({super.key, required this.institution});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  int _activeSection = 0;

  // Posts state
  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _isPostingNew = false;

  String _secondaryName(Institution d, String lang) {
    if (lang == 'en') return d.nku.isNotEmpty ? d.nku : d.nar;
    if (lang == 'ar') return d.nku.isNotEmpty ? d.nku : d.nen;
    return d.nen; // For Kurdish, show English as secondary
  }

  final List<String> _sectionKeys = [
    'aboutTab',
    'postsTab',
    '', // will be set in initState
    'locationTab',
    'contactTab',
    'socialTab',
  ];

  List<String> _sections(BuildContext context) {
    final keys = List<String>.from(_sectionKeys);
    keys[2] = _isUniversity ? 'college' : 'department';
    return keys.map((k) => S.of(context, k)).toList();
  }

  late final bool _isUniversity;

  @override
  void initState() {
    super.initState();
    final type = widget.institution.type;
    _isUniversity = (type == 'gov' || type == 'priv' || type == 'eve_uni');
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await ApiService.getInstitutionPosts(widget.institution.id);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = widget.institution;
    final size = MediaQuery.of(context).size;
    final colors = AppConstants.typeGradients[d.type] ??
        [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFF667eea)];
    final primaryColor = colors[1];

    return Directionality(
      textDirection: Directionality.of(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF2F4F8),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Hero Header ───
                SliverAppBar(
                  expandedHeight: size.height * 0.42,
                  pinned: true,
                  stretch: true,
                  backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: _buildGlassButton(
                    icon: Iconsax.arrow_right_3,
                    onTap: () => Navigator.pop(context),
                  ),
                  actions: [
                    // Favorite Button
                    _buildGlassButton(
                      icon: context.watch<AppProvider>().isFavorite(d.id)
                          ? Iconsax.heart5
                          : Iconsax.heart,
                      onTap: () => context.read<AppProvider>().toggleFavorite(d.id),
                      iconColor: context.watch<AppProvider>().isFavorite(d.id)
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                    // Share Button
                    _buildGlassButton(
                      icon: Iconsax.share,
                      onTap: () => _shareInstitution(d),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image
                        if (d.logo.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: d.logo,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _buildGradientBackground(colors),
                          )
                        else
                          _buildGradientBackground(colors),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.6),
                                Colors.black.withValues(alpha: 0.85),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),

                        // Bottom Info Overlay
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Badge
                              _buildTypeBadge(d, primaryColor),
                              const SizedBox(height: 12),

                              // University Name
                              Text(
                                d.nameForLang(context.read<AppProvider>().language),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Secondary Name (show alternate language)
                              if (_secondaryName(d, context.read<AppProvider>().language).isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _secondaryName(d, context.read<AppProvider>().language),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // Location & Rating Row
                              Row(
                                children: [
                                  // Location
                                  if (d.city.isNotEmpty) ...[
                                    Icon(Iconsax.location5,
                                        size: 14,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.city,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (d.city.isNotEmpty) ...[
                                    const SizedBox(width: 16),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Body Content ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Section Tabs ───
                        _buildSectionTabs(isDark, primaryColor),
                        const SizedBox(height: 20),

                        // ─── Section Content Based on Active Tab ───
                        ..._buildActiveSectionContent(d, isDark, primaryColor),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          AppConstants.typeEmojis[widget.institution.type] ?? '🏫',
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Institution d, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.typeEmojis[d.type] ?? '🏫',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 6),
              Text(
                context.read<AppProvider>().typeLabel(d.type),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTabs(bool isDark, Color primaryColor) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sections(context).length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = _activeSection == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeSection = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? primaryColor
                    : isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.5)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _sections(context)[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassCard({required bool isDark, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(Institution d, bool isDark, Color primaryColor) {
    final actions = <_QuickAction>[];
    if (d.phone.isNotEmpty) {
      actions.add(_QuickAction(
        icon: Iconsax.call5,
        label: S.of(context, 'contactTab'),
        color: const Color(0xFF10B981),
        onTap: () => _launchUrl('tel:${d.phone}'),
      ));
    }
    if (d.email.isNotEmpty) {
      actions.add(_QuickAction(
        icon: Iconsax.sms5,
        label: S.of(context, 'email'),
        color: const Color(0xFF6366F1),
        onTap: () => _launchUrl('mailto:${d.email}'),
      ));
    }
    if (d.web.isNotEmpty) {
      actions.add(_QuickAction(
        icon: Iconsax.global5,
        label: S.of(context, 'website'),
        color: const Color(0xFF3B82F6),
        onTap: () => _launchUrl(d.web),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final action = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i < actions.length - 1 ? 10 : 0),
            child: _buildQuickActionButton(action, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionButton(_QuickAction action, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? action.color.withValues(alpha: 0.12)
                  : action.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: action.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(action.icon, color: action.color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SECTION CONTENT BUILDER
  // ═══════════════════════════════════════════

  List<Widget> _buildActiveSectionContent(
      Institution d, bool isDark, Color primaryColor) {
    switch (_activeSection) {
      case 0: // دەربارە
        return _buildAboutSection(d, isDark);
      case 1: // پۆستەکان
        return _buildPostsSection(d, isDark, primaryColor);
      case 2: // بەشەکان
        return _buildDepartmentsSection(d, isDark);
      case 3: // شوێن
        return _buildLocationSection(d, isDark, primaryColor);
      case 4: // پەیوەندی
        return _buildContactSection(d, isDark);
      case 5: // سۆشیال
        return _buildSocialSection(d, isDark);
      default:
        return [];
    }
  }

  List<Widget> _buildAboutSection(Institution d, bool isDark) {
    if (d.desc == null || d.desc.trim().isEmpty) {
      return [_buildEmptyState(S.of(context, 'noAboutInfo'), isDark)];
    }
    return [
      _buildGlassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              S.of(context, 'aboutTab'),
              Iconsax.document_text_15,
              const Color(0xFF8B5CF6),
              isDark,
            ),
            const SizedBox(height: 14),
            Text(
              d.desc,
              style: TextStyle(
                fontSize: 14,
                height: 1.8,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDepartmentsSection(Institution d, bool isDark) {
    final hasColleges = d.colleges.isNotEmpty;
    final hasDepts = d.depts.isNotEmpty;
    final isUniversity = d.type == 'gov' || d.type == 'priv' || d.type == 'eve_uni';
    if (!hasColleges && !hasDepts) {
      return [_buildEmptyState('هیچ بەشێک زیاد نەکراوە', isDark)];
    }

    // Try parsing JSON format (new structured data)
    if (hasColleges && d.colleges.trimLeft().startsWith('[')) {
      try {
        final List<dynamic> parsed = jsonDecode(d.colleges);
        if (parsed.isEmpty) {
          return [_buildEmptyState(S.of(context, 'noDepartments'), isDark)];
        }
        return [
          _buildGlassCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSectionHeader(
                      isUniversity ? S.of(context, 'collegesAndDepts') : S.of(context, 'departments'),
                      Iconsax.building_45,
                      const Color(0xFF6366F1),
                      isDark,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUniversity ? S.of(context, 'collegeCount', {'count': parsed.length.toString()}) : S.of(context, 'deptCount', {'count': parsed.length.toString()}),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...parsed.asMap().entries.map((entry) {
                  final college = entry.value as Map<String, dynamic>;
                  final name = college['name'] as String? ?? '';
                  final depts = (college['depts'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .where((s) => s.isNotEmpty)
                          .toList() ??
                      [];
                  return _buildCollegeItem(name, depts, isDark);
                }),
              ],
            ),
          ),
        ];
      } catch (_) {
        // Fall through to legacy format
      }
    }

    // Legacy plain-text format
    return [
      if (hasColleges) ...[
        _buildGlassCard(
          isDark: isDark,
          child: _buildDepartmentsContent(
            isUniversity ? S.of(context, 'colleges') : S.of(context, 'departments'),
            Iconsax.building_45,
            const Color(0xFF6366F1),
            d.colleges.split('\n'),
            isDark,
          ),
        ),
        const SizedBox(height: 14),
      ],
      if (hasDepts)
        _buildGlassCard(
          isDark: isDark,
          child: _buildDepartmentsContent(
            S.of(context, 'departments'),
            Iconsax.hierarchy_square_25,
            const Color(0xFF10B981),
            d.depts.split('\n'),
            isDark,
          ),
        ),
    ];
  }

  Widget _buildCollegeItem(String name, List<String> depts, bool isDark) {
    const collegeColor = Color(0xFF6366F1);
    const deptColor = Color(0xFF10B981);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? collegeColor.withValues(alpha: 0.08)
            : collegeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: collegeColor.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.building_45, size: 18, color: collegeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (depts.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: deptColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    S.of(context, 'deptCount', {'count': depts.length.toString()}),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: deptColor,
                    ),
                  ),
                ),
            ],
          ),
          if (depts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: depts
                  .map((dept) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? deptColor.withValues(alpha: 0.12)
                              : deptColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: deptColor.withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? deptColor.withValues(alpha: 0.9) : deptColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildLocationSection(
      Institution d, bool isDark, Color primaryColor) {
    return [
      _buildGlassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              S.of(context, 'locationTab'),
              Iconsax.location5,
              const Color(0xFF3B82F6),
              isDark,
            ),
            const SizedBox(height: 16),
            _buildGlassMap(d, isDark, primaryColor),
            const SizedBox(height: 16),
            if (d.city.isNotEmpty || d.addr.isNotEmpty)
              _buildLocationDetails(d, isDark),
            const SizedBox(height: 16),
            _buildMapButtons(d, isDark, primaryColor),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildContactSection(Institution d, bool isDark) {
    if (!_hasContact()) {
      return [_buildEmptyState(S.of(context, 'noContactInfo'), isDark)];
    }
    final colors = AppConstants.typeGradients[d.type] ??
        [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFF667eea)];
    final primaryColor = colors[1];
    return [
      _buildQuickActions(d, isDark, primaryColor),
      const SizedBox(height: 14),
      _buildGlassCard(
        isDark: isDark,
        child: _buildContactContent(d, isDark),
      ),
    ];
  }

  List<Widget> _buildSocialSection(Institution d, bool isDark) {
    if (!_hasSocial()) {
      return [_buildEmptyState(S.of(context, 'noSocial'), isDark)];
    }
    return [
      _buildGlassCard(
        isDark: isDark,
        child: _buildSocialContent(d, isDark),
      ),
    ];
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return _buildGlassCard(
      isDark: isDark,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Icon(
                Iconsax.document,
                size: 40,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentsContent(String title, IconData icon, Color color,
      List<String> items, bool isDark) {
    final validItems = items.where((s) => s.trim().isNotEmpty).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionHeader(title, icon, color, isDark),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${validItems.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: validItems
              .map((item) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDark
                          ? color.withValues(alpha: 0.12)
                          : color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      item.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? color.withValues(alpha: 0.9) : color,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ─── Glass Map ───
  Widget _buildGlassMap(Institution d, bool isDark, Color primaryColor) {
    // Show real map if lat/lng are available
    if (d.lat != null && d.lng != null) {
      final pos = LatLng(d.lat!, d.lng!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: pos,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.xwendngakan.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.location_pin,
                      color: primaryColor,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Fallback: decorative glass map
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A2332),
                      const Color(0xFF0D1520),
                    ]
                  : [
                      const Color(0xFFE8F0FE),
                      const Color(0xFFD4E4F7),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.blue.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Grid lines for map effect
              ...List.generate(6, (i) {
                return Positioned(
                  top: i * 36.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 0.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.blue.withValues(alpha: 0.06),
                  ),
                );
              }),
              ...List.generate(8, (i) {
                return Positioned(
                  left: i * 50.0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 0.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.blue.withValues(alpha: 0.06),
                  ),
                );
              }),
              // Glass roads
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                bottom: 30,
                right: 80,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Positioned(
                top: 110,
                left: 60,
                right: 40,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Location Pin
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.location5,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (d.city.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          d.city,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
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
    );
  }

  Widget _buildLocationDetails(Institution d, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Iconsax.map_15, color: Color(0xFF3B82F6), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${d.city}${d.country.isNotEmpty ? '، ${d.country}' : ''}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (d.addr.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  d.addr,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButtons(Institution d, bool isDark, Color primaryColor) {
    return Row(
      children: [
  
        // Open Map Button
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openMap(d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.map5, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    S.of(context, 'openMap'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Contact Content ───
  bool _hasContact() {
    final d = widget.institution;
    return d.phone.isNotEmpty || d.email.isNotEmpty || d.web.isNotEmpty;
  }

  Widget _buildContactContent(Institution d, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          S.of(context, 'contactTab'),
          Iconsax.call5,
          const Color(0xFF10B981),
          isDark,
        ),
        const SizedBox(height: 16),
        if (d.phone.isNotEmpty)
          _buildContactRow(
            Iconsax.call5,
            S.of(context, 'phone'),
            d.phone,
            const Color(0xFF10B981),
            () => _launchUrl('tel:${d.phone}'),
            isDark,
          ),
        if (d.email.isNotEmpty)
          _buildContactRow(
            Iconsax.sms5,
            S.of(context, 'email'),
            d.email,
            const Color(0xFF6366F1),
            () => _launchUrl('mailto:${d.email}'),
            isDark,
          ),
        if (d.web.isNotEmpty)
          _buildContactRow(
            Iconsax.global5,
            S.of(context, 'website'),
            d.web,
            const Color(0xFF3B82F6),
            () => _launchUrl(d.web),
            isDark,
          ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value,
      Color color, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Social Content ───
  bool _hasSocial() {
    final d = widget.institution;
    return d.fb.isNotEmpty ||
        d.ig.isNotEmpty ||
        d.tg.isNotEmpty ||
        d.wa.isNotEmpty ||
        d.tk.isNotEmpty ||
        d.yt.isNotEmpty;
  }

  Widget _buildSocialContent(Institution d, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          S.of(context, 'socialMedia'),
          Iconsax.share5,
          const Color(0xFFEC4899),
          isDark,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (d.fb.isNotEmpty)
              _buildSocialChip(
                  S.of(context, 'facebook'), Iconsax.link5, const Color(0xFF1877F2), d.fb, isDark),
            if (d.wa.isNotEmpty)
              _buildSocialChip(
                  S.of(context, 'whatsapp'), Iconsax.message5, const Color(0xFF25D366), d.wa, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialChip(
      String label, IconData icon, Color color, String url, bool isDark) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareInstitution(Institution d) {
    final lang = context.read<AppProvider>().language;
    final name = d.nameForLang(lang);
    final type = context.read<AppProvider>().typeLabel(d.type);
    final parts = <String>[
      name,
      type,
      if (d.city.isNotEmpty) d.city,
      if (d.web.isNotEmpty) d.web,
      if (d.phone.isNotEmpty) d.phone,
    ];
    SharePlus.instance.share(ShareParams(text: parts.join('\n')));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: try in-app browser
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }

  // ══════════════════════════════════════════
  //  POSTS SECTION — Facebook Style
  // ═══════════════════════════════════════════

  List<Widget> _buildPostsSection(Institution d, bool isDark, Color primaryColor) {
    return [
      // ── Facebook-style "Create Post" bar ──
      if (ApiService.isLoggedIn)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2035) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE4E6EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _showCreatePostSheet(d, isDark, primaryColor),
            child: Row(
              children: [
                // Profile avatar
                _buildInstitutionAvatar(d, primaryColor, 38),
                const SizedBox(width: 10),
                // "What's on your mind?" bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCCD0D5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      S.of(context, 'postContentHint'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Image button
                GestureDetector(
                  onTap: () => _showCreatePostSheet(d, isDark, primaryColor),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Iconsax.image,
                      color: const Color(0xFF45BD62),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      // ── Divider line ──
      if (ApiService.isLoggedIn)
        Container(
          height: 8,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

      // ── Loading state ──
      if (_isLoadingPosts)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2035) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),
        ),

      // ── Empty state ──
      if (!_isLoadingPosts && _posts.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2035) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE4E6EB),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.document_text,
                  size: 40,
                  color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context, 'noPosts'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF050505),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context, 'noPostsDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

      // ── Posts list — Facebook style cards ──
      if (!_isLoadingPosts && _posts.isNotEmpty)
        ..._posts.asMap().entries.map((entry) {
          final index = entry.key;
          final post = entry.value;
          return Column(
            children: [
              _buildFbPostCard(post, d, isDark, primaryColor),
              // Grey divider between posts (like Facebook)
              if (index < _posts.length - 1)
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          );
        }),
    ];
  }

  /// Facebook-style circular/rounded avatar for institution
  Widget _buildInstitutionAvatar(Institution d, Color primaryColor, double size) {
    if (d.logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: d.logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildFallbackAvatar(d, primaryColor, size),
          errorWidget: (_, __, ___) => _buildFallbackAvatar(d, primaryColor, size),
        ),
      );
    }
    return _buildFallbackAvatar(d, primaryColor, size);
  }

  Widget _buildFallbackAvatar(Institution d, Color primaryColor, double size) {
    final lang = context.read<AppProvider>().language;
    final name = d.nameForLang(lang);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  /// Facebook-style post card
  Widget _buildFbPostCard(Post post, Institution d, bool isDark, Color primaryColor) {
    final lang = context.read<AppProvider>().language;
    final instName = d.nameForLang(lang);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2035) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE4E6EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Post Header (avatar + name + time + more) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
            child: Row(
              children: [
                _buildInstitutionAvatar(d, primaryColor, 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              instName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF050505),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Verified badge
                          Icon(
                            Icons.verified,
                            size: 15,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[600] : const Color(0xFF65676B),
                            ),
                          ),
                          Icon(
                            Icons.public,
                            size: 12,
                            color: isDark ? Colors.grey[500] : const Color(0xFF65676B),
                          ),
                          if (!post.approved) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                S.of(context, 'pending'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 3-dot menu icon
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_horiz,
                        size: 22,
                        color: isDark ? Colors.grey[400] : const Color(0xFF65676B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Post text content ──
          if (post.title.isNotEmpty || post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.title.isNotEmpty)
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF050505),
                        height: 1.3,
                      ),
                    ),
                  if (post.title.isNotEmpty && post.content.isNotEmpty)
                    const SizedBox(height: 4),
                  if (post.content.isNotEmpty)
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[200] : const Color(0xFF050505),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

          // ── Post image (full width, no side padding — like FB) ──
          if (post.image.isNotEmpty) ...[
            const SizedBox(height: 10),
            CachedNetworkImage(
              imageUrl: post.image,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 250,
                color: isDark ? const Color(0xFF242D42) : const Color(0xFFF0F2F5),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ],

          // ── Reactions / Like count bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                // Reaction emojis
                SizedBox(
                  width: 48,
                  height: 20,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF1A2035) : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.thumb_up, color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFED4956),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF1A2035) : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.favorite, color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : const Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCCD0D5),
            ),
          ),

          // ── Facebook action buttons (Like, Comment, Share) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                _buildFbActionBtn(
                  icon: Iconsax.like_1,
                  label: S.of(context, 'like'),
                  color: isDark ? Colors.grey[400]! : const Color(0xFF65676B),
                  isDark: isDark,
                ),
                _buildFbActionBtn(
                  icon: Iconsax.message,
                  label: S.of(context, 'comment'),
                  color: isDark ? Colors.grey[400]! : const Color(0xFF65676B),
                  isDark: isDark,
                ),
                _buildFbActionBtn(
                  icon: Iconsax.share,
                  label: S.of(context, 'shareLabel'),
                  color: isDark ? Colors.grey[400]! : const Color(0xFF65676B),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Facebook-style action button (Like, Comment, Share)
  Widget _buildFbActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreatePostSheet(Institution d, bool isDark, Color primaryColor) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    File? selectedImage;
    final lang = context.read<AppProvider>().language;
    final instName = d.nameForLang(lang);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2035) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Directionality(
                textDirection: Directionality.of(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header bar ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE4E6EB),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white : const Color(0xFF050505),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                S.of(context, 'writePost'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF050505),
                                ),
                              ),
                            ),
                          ),
                          // Publish button
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: ElevatedButton(
                              onPressed: _isPostingNew
                                  ? null
                                  : () async {
                                      if (titleCtrl.text.isEmpty && contentCtrl.text.isEmpty) return;
                                      setSheetState(() => _isPostingNew = true);
                                      try {
                                        final res = await ApiService.createPost(
                                          institutionId: d.id,
                                          title: titleCtrl.text,
                                          content: contentCtrl.text,
                                          imageFile: selectedImage,
                                        );
                                        if (mounted) Navigator.pop(ctx);
                                        if (res['success'] == true) {
                                          await _loadPosts();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(S.of(context, 'postAwaitingApproval')),
                                                backgroundColor: primaryColor,
                                              ),
                                            );
                                          }
                                        }
                                      } catch (_) {
                                        if (mounted) Navigator.pop(ctx);
                                      }
                                      setState(() => _isPostingNew = false);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1877F2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                minimumSize: const Size(0, 34),
                              ),
                              child: _isPostingNew
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      S.of(context, 'publishPost'),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── User info row ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          _buildInstitutionAvatar(d, primaryColor, 42),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF050505),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE4E6EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.public,
                                      size: 12,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF65676B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Public',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.grey[400] : const Color(0xFF65676B),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 14,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF65676B),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Title field ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: titleCtrl,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF050505),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: S.of(context, 'postTitleHint'),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : const Color(0xFFC0C0C0),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),

                    // ── Content field ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: contentCtrl,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            color: isDark ? Colors.grey[200] : const Color(0xFF050505),
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            hintText: S.of(context, 'postContentHint'),
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[700] : const Color(0xFFC0C0C0),
                              fontSize: 22,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    // ── Selected image preview ──
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setSheetState(() => selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Bottom toolbar ──
                    Container(
                      padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE4E6EB),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _fbToolbarBtn(
                            icon: Iconsax.image,
                            color: const Color(0xFF45BD62),
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null && result.files.single.path != null) {
                                setSheetState(() {
                                  selectedImage = File(result.files.single.path!);
                                });
                              }
                            },
                          ),
                          _fbToolbarBtn(
                            icon: Iconsax.camera,
                            color: const Color(0xFF1877F2),
                            onTap: () {},
                          ),
                          _fbToolbarBtn(
                            icon: Iconsax.emoji_happy,
                            color: const Color(0xFFF7B928),
                            onTap: () {},
                          ),
                          _fbToolbarBtn(
                            icon: Iconsax.location,
                            color: const Color(0xFFED4956),
                            onTap: () {},
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fbToolbarBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  void _openMap(Institution d) {
    final query = Uri.encodeComponent('${d.nameForLang('en')} ${d.city}');
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    _launchUrl(googleUrl);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
