import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/common_widgets.dart';

// ── Academic gold palette ────────────────────────────────────
const _kGold = Color(0xFFD4A017);
const _kGoldLight = Color(0xFFF0C040);
const _kGoldGrad = LinearGradient(
  colors: [Color(0xFFC99A0A), Color(0xFFE8B84B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
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
      r'(?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/|v/))([^#&?]{11})',
      caseSensitive: false,
    );
    return regExp.firstMatch(url)?.group(1);
  }

  @override
  void deactivate() { _youtubeController?.pause(); super.deactivate(); }

  @override
  void dispose() { _animCtrl.dispose(); _youtubeController?.dispose(); super.dispose(); }

  void _goBack() => context.canPop() ? context.pop() : context.go('/teachers');

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareTeacher(TeacherModel t) {
    final text = '${t.name}\n${t.subject ?? ""}\n\nخوێندنگاکانم App';
    Share.share(text);
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF2F5FB),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _teacher == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF2F5FB),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          message: _error ?? l.noData,
          actionLabel: l.retry,
          onAction: () { setState(() { _loading = true; _error = null; }); _load(); },
        ),
      );
    }

    final t = _teacher!;
    final bgColor = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF2F5FB);
    final cardColor = isDark ? const Color(0xFF131D2E) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(t, isDark, cardColor, l)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsRow(t, isDark, cardColor, l),
                      const SizedBox(height: 20),
                      if (t.about != null && t.about!.isNotEmpty) ...[
                        _buildSection(
                          title: l.about,
                          icon: Icons.info_outline_rounded,
                          isDark: isDark, cardColor: cardColor,
                          child: Text(t.about!, style: TextStyle(fontSize: 15, height: 1.9, fontFamily: 'Rabar', color: isDark ? Colors.white70 : Colors.black87)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (t.hourlyRate != null && t.hourlyRate! > 0) ...[
                        _buildPriceCard(t, isDark, cardColor, l),
                        const SizedBox(height: 16),
                      ],
                      _buildContactCard(t, isDark, cardColor, l),
                      const SizedBox(height: 16),
                      if (t.subjectPhotoUrl.isNotEmpty) ...[
                        _buildSection(
                          title: l.curriculumSection,
                          icon: Icons.auto_stories_rounded,
                          isDark: isDark, cardColor: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(imageUrl: t.subjectPhotoUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 10),
                              Text(l.curriculumCaption, style: const TextStyle(fontSize: 12, fontFamily: 'Rabar', fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (t.videoUrl != null && t.videoUrl!.isNotEmpty)
                        _buildSection(
                          title: 'ڤیدیۆی پێناسەکردن',
                          icon: Icons.play_circle_outline_rounded,
                          isDark: isDark, cardColor: cardColor,
                          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildVideoPlayer(t)),
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

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(TeacherModel t, bool isDark, Color cardColor, AppLocalizations l) {
    final displaySubject = (t.subject != null && t.subject!.trim().isNotEmpty)
        ? t.subject!.trim()
        : (t.typeLabel ?? l.educationSpecialization);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: _kGoldGrad,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48),
            ),
          ),
          child: Stack(children: [
            Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)))),
            Positioned(bottom: 20, left: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)))),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(Icons.arrow_back_ios_new_rounded, _goBack),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(l.profile, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Rabar')),
                ),
                _circleBtn(Icons.ios_share_rounded, () => _shareTeacher(t)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 170, left: 20, right: 20,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Text(t.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Rabar', color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [_kGold, _kGoldLight]), borderRadius: BorderRadius.circular(20)),
                  child: Text(displaySubject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Rabar')),
                ),
                if (t.typeLabel != null) ...[
                  const SizedBox(height: 8),
                  Text(t.typeLabel!, style: TextStyle(fontSize: 12, fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          top: 122, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: cardColor,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: _kGold.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: ClipOval(child: t.photoUrl.isNotEmpty ? CachedNetworkImage(imageUrl: t.photoUrl, fit: BoxFit.cover) : _avatarFallback(t.name)),
            ),
          ),
        ),
        SizedBox(height: 170 + 55 + 130.0 + 30),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────
  Widget _buildStatsRow(TeacherModel t, bool isDark, Color cardColor, AppLocalizations l) {
    return Row(children: [
      Expanded(child: _statTile(Icons.history_edu_rounded, l.tileExperience, t.experienceYears != null ? '${t.experienceYears} ${l.yearsUnit}' : '—', const Color(0xFFF59E0B), isDark, cardColor)),
      const SizedBox(width: 10),
      Expanded(child: _statTile(Icons.location_on_rounded, l.tileProvince, t.city ?? '—', const Color(0xFF3B82F6), isDark, cardColor)),
      const SizedBox(width: 10),
      Expanded(child: _statTile(Icons.menu_book_rounded, l.tileCurriculum, t.subject ?? l.specializationFallback, const Color(0xFF10B981), isDark, cardColor)),
    ]);
  }

  Widget _statTile(IconData icon, String label, String value, Color color, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black45)),
        const SizedBox(height: 2),
        Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Rabar', color: isDark ? Colors.white : Colors.black87)),
      ]),
    );
  }

  // ── Price card ─────────────────────────────────────────────
  Widget _buildPriceCard(TeacherModel t, bool isDark, Color cardColor, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [_kGold, _kGoldLight]), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: _kGold.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))]),
          child: const Icon(Icons.payments_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.hourlyRate, style: TextStyle(fontSize: 12, fontFamily: 'Rabar', fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.black45)),
          const SizedBox(height: 4),
          Text('${t.hourlyRate} ${l.currencyIqd}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Rabar', color: _kGold)),
        ])),
      ]),
    );
  }

  // ── Contact card ───────────────────────────────────────────
  Widget _buildContactCard(TeacherModel t, bool isDark, Color cardColor, AppLocalizations l) {
    final hasPhone = t.phone != null && t.phone!.isNotEmpty;
    final hasFacebook = t.facebookUrl != null && t.facebookUrl!.isNotEmpty;
    if (!hasPhone && !hasFacebook) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.contact_phone_rounded, size: 18, color: _kGold),
          const SizedBox(width: 10),
          Text(l.contactTeacher.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1, fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black45)),
        ]),
        const SizedBox(height: 18),
        if (hasPhone) ...[
          _contactRow(color: const Color(0xFF3B82F6), icon: Icons.phone_rounded, label: l.contactPhone, sublabel: t.phone!, onTap: () => _launch('tel:${t.phone}'), isDark: isDark),
          const SizedBox(height: 10),
          _contactRow(color: const Color(0xFF25D366), icon: Icons.wechat_rounded, label: l.whatsApp, sublabel: t.phone!, onTap: () { final p = t.phone!.replaceAll(RegExp(r'[^0-9]'), ''); _launch('https://wa.me/$p'); }, isDark: isDark),
        ],
        if (hasPhone && hasFacebook) const SizedBox(height: 10),
        if (hasFacebook)
          _contactRow(color: const Color(0xFF1877F2), icon: Icons.facebook_rounded, label: 'فەیسبوک', sublabel: 'پرۆفایلی فەیسبوک', onTap: () => _launch(t.facebookUrl!), isDark: isDark),
      ]),
    );
  }

  Widget _contactRow({required Color color, required IconData icon, required String label, required String sublabel, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.15), width: 1)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]), child: Icon(icon, color: Colors.white, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Rabar', color: isDark ? Colors.white : Colors.black87)),
            Text(sublabel, style: TextStyle(fontSize: 12, fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black45)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha: 0.6)),
        ]),
      ),
    );
  }

  // ── Generic section ────────────────────────────────────────
  Widget _buildSection({required String title, required IconData icon, required bool isDark, required Color cardColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: _kGold),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1, fontFamily: 'Rabar', color: isDark ? Colors.white38 : Colors.black45)),
        ]),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.25))),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _avatarFallback(String name) {
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String init = '?';
    if (parts.length >= 2) init = '${parts[0][0]}${parts[1][0]}';
    else if (name.isNotEmpty) init = name[0];
    return Container(color: _kGold, child: Center(child: Text(init.toUpperCase(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white))));
  }

  Widget _buildVideoPlayer(TeacherModel t) {
    if (_youtubeController != null) {
      return YoutubePlayer(controller: _youtubeController!, showVideoProgressIndicator: true, progressIndicatorColor: _kGold);
    }
    return GestureDetector(
      onTap: () => _launch(t.videoUrl!),
      child: Stack(alignment: Alignment.center, children: [
        _ytVideoId != null
            ? CachedNetworkImage(imageUrl: 'https://img.youtube.com/vi/$_ytVideoId/hqdefault.jpg', height: 200, width: double.infinity, fit: BoxFit.cover)
            : Container(height: 200, color: const Color(0xFF1E293B)),
        Container(height: 200, color: Colors.black.withValues(alpha: 0.3)),
        Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]), child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFEF4444), size: 36)),
      ]),
    );
  }
}
