import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/common_widgets.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String id;
  const TeacherProfileScreen({super.key, required this.id});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  TeacherModel? _teacher;
  bool _loading = true;
  String? _error;
  String? _ytVideoId;
  YoutubePlayerController? _youtubeController;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _load();
  }

  Future<void> _load() async {
    final result = await _api.getTeacher(int.tryParse(widget.id) ?? 0);
    if (!mounted) return;
    if (result.success && result.data != null) {
      final t = result.data!;
      if (t.videoUrl != null && t.videoUrl!.isNotEmpty) {
        _ytVideoId = _extractYtId(t.videoUrl!);
        if (_ytVideoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: _ytVideoId!,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      }
      setState(() { _teacher = t; _loading = false; });
      _animCtrl.forward();
    } else {
      setState(() { _error = result.error; _loading = false; });
    }
  }

  String? _extractYtId(String url) {
    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\\??v?=?([^#&?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.group(7)!.length == 11) return match.group(7);
    return null;
  }

  @override
  void deactivate() { _youtubeController?.pause(); super.deactivate(); }

  @override
  void dispose() { _animCtrl.dispose(); _youtubeController?.dispose(); super.dispose(); }

  void _goBack() => context.canPop() ? context.pop() : context.go('/teachers');

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _teacher == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _goBack,
          ),
        ),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          message: _error ?? l.noData,
          actionLabel: l.retry,
          onAction: () { setState(() { _loading = true; _error = null; }); _load(); },
        ),
      );
    }

    final t = _teacher!;
    final String displaySubject = t.subject != null && t.subject!.trim().isNotEmpty
        ? l.teacherOf(t.subject!.trim())
        : (t.typeLabel ?? l.educationSpecialization);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        bottomNavigationBar: _buildStickyContact(t, l, isDark),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── CURVED HERO HEADER ──
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                        child: t.videoUrl != null && t.videoUrl!.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                                color: Colors.black,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: _buildVideoPlayer(t),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -30, right: -30,
                                      child: Container(
                                        width: 140, height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.08),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      // Floating Back Button
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: GestureDetector(
                            onTap: _goBack,
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),

                      // Avatar
                      Positioned(
                        bottom: -48,
                        left: 0, right: 0,
                        child: Center(
                          child: Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 3.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: t.photoUrl.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: t.photoUrl, fit: BoxFit.cover)
                                  : _avatarFallback(t.name, AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 60)),

                // ── PROFILE CONTENT ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Name + subject badge
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    t.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                                if (t.isApproved) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (displaySubject.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  displaySubject,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── THREE TILE CARDS ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildTileCard(
                              icon: Icons.history_edu_rounded,
                              title: l.tileExperience,
                              value: t.experienceYears != null ? '${t.experienceYears} ${l.yearsUnit}' : '—',
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTileCard(
                              icon: Icons.location_on_rounded,
                              title: l.tileProvince,
                              value: t.city ?? '—',
                              color: const Color(0xFF3B82F6),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTileCard(
                              icon: Icons.menu_book_rounded,
                              title: l.tileCurriculum,
                              value: t.subject ?? l.specializationFallback,
                              color: const Color(0xFF8B5CF6),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Biography
                      if (t.about != null && t.about!.isNotEmpty)
                        _buildCreativeSection(
                          isDark: isDark,
                          title: l.about,
                          icon: Icons.info_outline_rounded,
                          child: Text(
                            t.about!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.8,
                              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                              fontFamily: 'NotoSansArabic',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Subject Photo / Curriculum
                      if (t.subjectPhotoUrl.isNotEmpty)
                        _buildCreativeSection(
                          isDark: isDark,
                          title: l.curriculumSection,
                          icon: Icons.auto_stories_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: t.subjectPhotoUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l.curriculumCaption,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'NotoSansArabic',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyContact(TeacherModel t, AppLocalizations l, bool isDark) {
    if (t.phone == null || t.phone!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StickyBtn(
              icon: Icons.call_rounded,
              label: l.contactPhone,
              color: const Color(0xFF3B82F6),
              onTap: () => _launch('tel:${t.phone}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StickyBtn(
              icon: Icons.wechat_rounded,
              label: l.contactWhatsapp,
              color: const Color(0xFF10B981),
              onTap: () => _launch('https://wa.me/${t.phone?.replaceAll(RegExp(r'[^0-9]'), '')}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(TeacherModel t) {
    if (_youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
        ),
      );
    }
    return GestureDetector(
      onTap: () => _launch(t.videoUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ytVideoId != null
                ? CachedNetworkImage(
                    imageUrl: 'https://img.youtube.com/vi/$_ytVideoId/hqdefault.jpg',
                    height: 220, width: double.infinity, fit: BoxFit.cover,
                  )
                : Container(height: 220, color: const Color(0xFF1E293B)),
            Container(height: 220, color: Colors.black.withValues(alpha: 0.3)),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFEF4444), size: 38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreativeSection({
    required bool isDark, required String title, required IconData icon,
    Color iconColor = AppColors.primary, required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEDF2F7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name, Color color) {
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String init = '?';
    if (parts.length >= 2) {
      init = '${parts[0][0]}${parts[1][0]}';
    } else if (name.isNotEmpty) {
      init = name[0];
    }
    return Container(
      color: color,
      child: Center(
        child: Text(
          init.toUpperCase(),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTileCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontFamily: 'NotoSansArabic',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StickyBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
