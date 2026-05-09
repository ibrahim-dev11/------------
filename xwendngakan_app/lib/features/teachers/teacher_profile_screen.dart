import 'dart:ui';
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
      r'^.*((youtu.be\/)|(v\/)|(\u002Fu\/\w\/)|(embed\/)|(watch\?))\\??v?=?([^#&?]*).*',
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
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _teacher == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
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
        ? 'مامۆستای ${t.subject!.trim()}' 
        : (t.typeLabel ?? '');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.light, // Top is always dark gradient
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        bottomNavigationBar: _buildStickyContact(t, l, isDark),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── TOP BACKGROUND ──
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                              const Color(0xFF4F46E5),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Subtle pattern / glow
                            Positioned(
                              top: -50, right: -50,
                              child: Container(
                                width: 200, height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20, left: -30,
                              child: Container(
                                width: 140, height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ── BACK BUTTON ──
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GestureDetector(
                            onTap: _goBack,
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),

                      // ── MAIN INFO CARD ──
                      Padding(
                        padding: const EdgeInsets.only(top: 200, left: 20, right: 20, bottom: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 65, left: 20, right: 20, bottom: 24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      t.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                        fontFamily: 'NotoSansArabic',
                                      ),
                                    ),
                                  ),
                                  if (t.isApproved) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                                  ],
                                ],
                              ),
                              
                              if (displaySubject.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    displaySubject,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Stats Grid
                              Row(
                                children: [
                                  Expanded(child: _buildStatItem(
                                    icon: Icons.history_edu_rounded,
                                    value: t.experienceYears != null ? '${t.experienceYears}' : '—',
                                    unit: l.years,
                                    label: l.experience,
                                    color: const Color(0xFFF59E0B),
                                    isDark: isDark,
                                  )),
                                  _buildDivider(isDark),
                                  Expanded(child: _buildStatItem(
                                    icon: Icons.payments_rounded,
                                    value: t.hourlyRate != null ? '\$${t.hourlyRate}' : '—',
                                    unit: '',
                                    label: l.hourlyRate,
                                    color: AppColors.success,
                                    isDark: isDark,
                                  )),
                                  _buildDivider(isDark),
                                  Expanded(child: _buildStatItem(
                                    icon: Icons.location_on_rounded,
                                    value: t.city ?? '—',
                                    unit: '',
                                    label: l.city,
                                    color: const Color(0xFF3B82F6),
                                    isDark: isDark,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── AVATAR ──
                      Positioned(
                        top: 130, // Overlaps top bg and card
                        left: 0, right: 0,
                        child: Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                width: 6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: t.photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: t.photoUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : _avatarFallback(t.name, AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── OTHER SECTIONS ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      
                      // About
                      if (t.about != null && t.about!.isNotEmpty)
                        _buildCreativeSection(
                          isDark: isDark,
                          title: l.about,
                          icon: Icons.format_quote_rounded,
                          child: Text(
                            t.about!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.9,
                              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                        ),

                      // Subject Photo
                      if (t.subjectPhotoUrl.isNotEmpty)
                        _buildCreativeSection(
                          isDark: isDark,
                          title: l.subjectPhoto,
                          icon: Icons.image_rounded,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: t.subjectPhotoUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Video
                      if (t.videoUrl != null && t.videoUrl!.isNotEmpty)
                        _buildCreativeSection(
                          isDark: isDark,
                          title: 'ڤیدیۆی مامۆستا',
                          icon: Icons.play_circle_fill_rounded,
                          iconColor: const Color(0xFFEF4444),
                          child: _buildVideoPlayer(t),
                        ),

                      const SizedBox(height: 40),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // bottom safe area padding
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
              label: l.contactTeacher,
              color: const Color(0xFF3B82F6),
              onTap: () => _launch('tel:${t.phone}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StickyBtn(
              icon: Icons.wechat_rounded, // Best builtin alternative to whatsapp icon
              label: 'WhatsApp',
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

  Widget _buildStatItem({
    required IconData icon, required String value, required String unit,
    required String label, required Color color, required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontFamily: 'NotoSansArabic',
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontFamily: 'NotoSansArabic',
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 50, width: 1,
      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
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
                fontSize: 15,
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
