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

  void _shareTeacher(TeacherModel t, AppLocalizations l) {
    final text = 'EduBook Teacher: ${t.name}\n${t.subject ?? ""}\n\nDownloaded from EduBook App';
    Share.share(text);
  }

  void _showContactSheet(TeacherModel t, AppLocalizations l, bool isDark) {
    if (t.phone == null || t.phone!.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(l.contactTeacher, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, fontFamily: 'NotoSansArabic')),
            const SizedBox(height: 24),
            _buildContactOption(Icons.phone_rounded, l.contactPhone, const Color(0xFF3B82F6), () {
              Navigator.pop(context);
              _launch('tel:${t.phone}');
            }, isDark),
            const SizedBox(height: 12),
            _buildContactOption(Icons.wechat_rounded, l.whatsApp, const Color(0xFF10B981), () {
              Navigator.pop(context);
              final phone = t.phone!.replaceAll(RegExp(r'[^0-9]'), '');
              _launch('https://wa.me/$phone');
            }, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String label, Color color, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87, fontFamily: 'NotoSansArabic')),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _teacher == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          message: _error ?? l.noData,
          actionLabel: l.retry,
          onAction: () { setState(() { _loading = true; _error = null; }); _load(); },
        ),
      );
    }

    final t = _teacher!;
    final accentColor = AppColors.primary;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final String displaySubject = t.subject != null && t.subject!.trim().isNotEmpty
        ? '${l.specializationLabel}: ${t.subject!.trim()}'
        : (t.typeLabel ?? l.educationSpecialization);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            FadeTransition(
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
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                            child: t.videoUrl != null && t.videoUrl!.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                                    color: Colors.black,
                                    child: AspectRatio(aspectRatio: 16 / 9, child: _buildVideoPlayer(t)),
                                  )
                                : Container(
                                    height: 200, width: double.infinity,
                                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -40, right: -40,
                                          child: Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle)),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCircleAction(Icons.arrow_back_ios_new_rounded, _goBack),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(l.profile, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'NotoSansArabic')),
                                  ),
                                  _buildCircleAction(Icons.ios_share_rounded, () => _shareTeacher(t, l)),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: -45,
                            left: 0, right: 0,
                            child: Center(
                              child: Container(
                                width: 96, height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cardColor,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))],
                                ),
                                child: ClipOval(
                                  child: t.photoUrl.isNotEmpty 
                                    ? CachedNetworkImage(imageUrl: t.photoUrl, fit: BoxFit.cover)
                                    : _avatarFallback(t.name, accentColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 55)),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(t.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, fontFamily: 'NotoSansArabic')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(displaySubject, style: TextStyle(fontSize: 15, color: accentColor, fontWeight: FontWeight.w700, fontFamily: 'NotoSansArabic')),
                          ),
                          
                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(child: _buildInfoTile(Icons.history_edu_rounded, l.tileExperience, t.experienceYears != null ? '${t.experienceYears} ${l.yearsUnit}' : '—', const Color(0xFFF59E0B), isDark)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildInfoTile(Icons.location_on_rounded, l.tileProvince, t.city ?? '—', const Color(0xFF3B82F6), isDark)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildInfoTile(Icons.menu_book_rounded, l.tileCurriculum, t.subject ?? l.specializationFallback, const Color(0xFF10B981), isDark)),
                            ],
                          ),

                          const SizedBox(height: 24),
                          
                          if (t.about != null && t.about!.isNotEmpty)
                            _buildSectionCard(l.about, Icons.info_outline_rounded, 
                              Text(t.about!, style: TextStyle(fontSize: 15, height: 1.8, color: isDark ? Colors.white70 : Colors.black87, fontFamily: 'NotoSansArabic')), 
                              isDark, accentColor, cardColor),

                          if (t.hourlyRate != null && t.hourlyRate! > 0)
                            _buildSectionCard(l.hourlyRate, Icons.payments_rounded, 
                              Text(l.perHour.isEmpty ? '${t.hourlyRate} ${l.currencyIqd}' : '${t.hourlyRate} ${l.currencyIqd} / ${l.perHour}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor, fontFamily: 'NotoSansArabic')), 
                              isDark, accentColor, cardColor),

                          if (t.subjectPhotoUrl.isNotEmpty)
                            _buildSectionCard(l.curriculumSection, Icons.auto_stories_rounded, 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(imageUrl: t.subjectPhotoUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(l.curriculumCaption, style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                                ],
                              ), isDark, accentColor, cardColor),
                          
                          const SizedBox(height: 120),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildPremiumFooter(t, isDark, accentColor, l),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.black45, fontFamily: 'NotoSansArabic')),
          const SizedBox(height: 2),
          Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, fontFamily: 'NotoSansArabic')),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content, bool isDark, Color accent, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 12),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black45, fontFamily: 'NotoSansArabic')),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildPremiumFooter(TeacherModel t, bool isDark, Color accent, AppLocalizations l) {
    if (t.phone == null || t.phone!.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 24, left: 30, right: 30,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: InkWell(
          onTap: () => _showContactSheet(t, l, isDark),
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(l.contactTeacher, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'NotoSansArabic')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(TeacherModel t) {
    if (_youtubeController != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ytVideoId != null
                ? CachedNetworkImage(imageUrl: 'https://img.youtube.com/vi/$_ytVideoId/hqdefault.jpg', height: 220, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 220, color: const Color(0xFF1E293B)),
            Container(height: 220, color: Colors.black.withValues(alpha: 0.3)),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]),
              child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFEF4444), size: 38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback(String name, Color color) {
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String init = '?';
    if (parts.length >= 2) init = '${parts[0][0]}${parts[1][0]}';
    else if (name.isNotEmpty) init = name[0];
    return Container(
      color: color,
      child: Center(child: Text(init.toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white))),
    );
  }
}
