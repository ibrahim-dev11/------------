import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
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
    if (await canLaunchUrl(uri))
      launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Provider.of<LocaleProvider>(context);
    final prov = Provider.of<InstitutionsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = locale.locale.languageCode;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _institution == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.institutions)),
        body: Center(child: Text(_error ?? 'Not found')),
      );
    }

    final inst = _institution!;
    final typeColor = AppColors.typeColor(inst.type);
    final isFav = prov.favorites.contains(inst.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Header Section (Blue Background) ──
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () => prov.toggleFavorite(inst.id),
                  ),
                ),
                // Center Icon Circle
                Positioned(
                  bottom: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: inst.logoUrl.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(15),
                              child: CachedNetworkImage(
                                imageUrl: inst.logoUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => Icon(Icons.school_rounded, color: typeColor, size: 40),
                                errorWidget: (_, __, ___) => Icon(Icons.school_rounded, color: typeColor, size: 40),
                              ),
                            )
                          : Icon(Icons.school_rounded, color: typeColor, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // ── Name & Location ──
            Text(
              inst.name(lang),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'NotoSansArabic',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded, color: AppColors.textGrey.withOpacity(0.5), size: 16),
                const SizedBox(width: 4),
                Text(
                  inst.city ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Action Buttons Row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCircle(
                  icon: Icons.phone_in_talk_rounded,
                  label: 'پەیوەندی',
                  color: const Color(0xFF1D9E75),
                  onTap: inst.phone != null ? () => _launch('tel:${inst.phone}') : () {},
                ),
                _buildActionCircle(
                  icon: Icons.notifications_active_rounded,
                  label: 'ئاگادارکردنەوە',
                  color: const Color(0xFF3A7DD4),
                  onTap: () {},
                ),
                _buildActionCircle(
                  icon: Icons.map_rounded,
                  label: 'نەخشە',
                  color: const Color(0xFFE05C8A),
                  onTap: () => context.push('/map'),
                ),
                _buildActionCircle(
                  icon: Icons.qr_code_2_rounded,
                  label: 'کۆدی QR',
                  color: const Color(0xFF7F77DD),
                  onTap: () => _showQrCode(inst, lang),
                ),
                _buildActionCircle(
                  icon: Icons.share_rounded,
                  label: 'ناردن',
                  color: const Color(0xFFFF6B35),
                  onTap: () => _shareInstitution(inst, lang),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Tab Switcher ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'دەربارە', isDark),
                  _buildTabItem(1, 'بەشەکان', isDark),
                  _buildTabItem(2, 'پۆستەکان', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tab Content ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTabContent(inst, isDark, lang, l),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle({
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoSansArabic',
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
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontFamily: 'NotoSansArabic',
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textDark),
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
            if (inst.desc != null && inst.desc!.isNotEmpty) ...[
              const Text(
                'دەربارە',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
              ),
              const SizedBox(height: 12),
              Text(
                inst.desc!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.8,
                  color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.7),
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 24),
            ],
            _StatsRow(isDark: isDark, inst: inst),
            const SizedBox(height: 24),
            if (inst.video != null && inst.video!.isNotEmpty) ...[
              _VideoCard(videoUrl: inst.video!, isDark: isDark, onTap: () => _launch(inst.video!)),
              const SizedBox(height: 24),
            ],
            const Text(
              'پەیوەندی',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
            ),
            const SizedBox(height: 12),
            _ContactCard(inst: inst, isDark: isDark, onLaunch: _launch),
          ],
        );
      case 1: // Colleges
        final list = _parseColleges(inst.colleges);
        if (list.isEmpty && (inst.colleges == null || inst.colleges!.isEmpty)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('هیچ زانیارییەک نییە', style: TextStyle(fontFamily: 'NotoSansArabic')),
            ),
          );
        }
        return _CollegesCard(colleges: list, isDark: isDark, l: l);
      case 2: // Posts
        if (inst.posts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('هیچ پۆستێک نییە', style: TextStyle(fontFamily: 'NotoSansArabic')),
            ),
          );
        }
        return _PostsList(posts: inst.posts, isDark: isDark);
      default:
        return const SizedBox();
    }
  }

  void _showQrCode(InstitutionModel inst, String lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'کۆدی QR ی دامەزراوە',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: QrImageView(
                data: 'https://edubook.app/institutions/${inst.id}',
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              inst.name(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'داخستن',
                style: TextStyle(color: Colors.white, fontFamily: 'NotoSansArabic'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareInstitution(InstitutionModel inst, String lang) {
    final String shareUrl = 'https://edubook.app/institutions/${inst.id}';
    final String message = '''
🎓 ${inst.name(lang)}
🏛️ ${inst.type} | 📍 ${inst.city}

بۆ بینینی زانیاری زیاتر دەربارەی ئەم دامەزراوەیە، ئەپەکەمان دابەزێنە یان ئەم لینکە بکەرەوە:
$shareUrl

لە ڕێگەی ئەپی EduBook - ڕێبەری خوێندنی کوردستان
''';

    Share.share(message);
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
}

// ─── Hero fallback ────────────────────────────────────────────────────────────

class _HeroFallback extends StatelessWidget {
  final Color typeColor;
  final InstitutionModel inst;
  final String lang;
  const _HeroFallback(
      {required this.typeColor, required this.inst, required this.lang});

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.institutionTypes[inst.type]?['emoji'] ?? '🏫';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [typeColor, typeColor.withOpacity(0.6)],
        ),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 80))),
    );
  }
}

// ─── Type badge ───────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String? type;
  final Color typeColor;
  final String lang;
  const _TypeBadge({this.type, required this.typeColor, required this.lang});

  @override
  Widget build(BuildContext context) {
    final info = AppConstants.institutionTypes[type];
    final label = info?[lang] ?? info?['en'] ?? type ?? '';
    final emoji = info?['emoji'] ?? '🏫';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$emoji $label',
          style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w600)),
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        children: [
          _StatItem(
              value: inst.foundedYear?.toString() ?? '—',
              label: 'ساڵی دامەزران',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFFD4A017)),
          _VDivider(),
          _StatItem(
              value: yearsExp,
              label: 'ساڵ تەجربە',
              icon: Icons.history_edu_rounded,
              color: AppColors.primary),
          _VDivider(),
          _StatItem(
              value: studentsStr,
              label: 'قوتابی',
              icon: Icons.groups_rounded,
              color: AppColors.success),
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFamily: 'NotoSansArabic')),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontFamily: 'NotoSansArabic')),
        ]),
      );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: Colors.grey.withOpacity(0.15));
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;
  const _SectionCard(
      {required this.isDark,
      required this.icon,
      required this.title,
      required this.iconColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

// ─── Video card ───────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final String videoUrl;
  final bool isDark;
  final VoidCallback onTap;
  const _VideoCard(
      {required this.videoUrl, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
          ),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFF0000).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
                top: -20,
                right: -20,
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08)))),
            Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06)))),
            // Content
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 2)),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 10),
                    const Text('ڤیدیۆی دامەزراوەکە ببینە',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: 'NotoSansArabic')),
                    const SizedBox(height: 2),
                    Text(
                        videoUrl.length > 40
                            ? '${videoUrl.substring(0, 40)}...'
                            : videoUrl,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Colleges expandable ──────────────────────────────────────────────────────

class _CollegesCard extends StatefulWidget {
  final List<Map<String, dynamic>> colleges;
  final bool isDark;
  final AppLocalizations l;
  const _CollegesCard(
      {required this.colleges, required this.isDark, required this.l});

  @override
  State<_CollegesCard> createState() => _CollegesCardState();
}

class _CollegesCardState extends State<_CollegesCard> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: const Color(0xFF3A7DD4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance_rounded,
                  color: Color(0xFF3A7DD4), size: 18),
            ),
            const SizedBox(width: 10),
            Text(widget.l.colleges,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1A1A2E))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFF3A7DD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${widget.colleges.length}',
                  style: const TextStyle(
                      color: Color(0xFF3A7DD4),
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ]),
        ),
        ...widget.colleges.asMap().entries.map((entry) {
          final i = entry.key;
          final college = entry.value;
          final name = college['name']?.toString() ?? '';
          final depts = (college['departments'] as List?)?.cast<String>() ?? [];
          final isLast = i == widget.colleges.length - 1;
          final isExpanded = _expanded.contains(i);

          return Column(children: [
            if (i > 0)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: widget.isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.07))),
            InkWell(
              onTap: depts.isNotEmpty
                  ? () => setState(() {
                        if (isExpanded) {
                          _expanded.remove(i);
                        } else {
                          _expanded.add(i);
                        }
                      })
                  : null,
              borderRadius: BorderRadius.vertical(
                  bottom: isLast && !isExpanded
                      ? const Radius.circular(20)
                      : Radius.zero),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF3A7DD4), shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'NotoSansArabic',
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E)))),
                  if (depts.isNotEmpty) ...[
                    Text('${depts.length}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(width: 4),
                    Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textGrey),
                  ],
                ]),
              ),
            ),
            if (isExpanded && depts.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A7DD4).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: depts
                        .map((d) =>
                            _Chip(label: d, color: const Color(0xFF3A7DD4)))
                        .toList()),
              ),
          ]);
        }),
      ]),
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Contact row ──────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ContactRow(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'NotoSansArabic',
                      color: onTap != null
                          ? color
                          : (isDark
                              ? Colors.white70
                              : const Color(0xFF4A4A6A))),
                  maxLines: 2)),
          if (onTap != null)
            Icon(Icons.open_in_new_rounded,
                size: 14, color: color.withOpacity(0.6)),
        ]),
      ),
    );
  }
}

// ─── Social button ────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _SocialBtn(
      {required this.emoji,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final List<PostModel> posts;
  final bool isDark;
  const _PostsList({required this.posts, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.title != null) ...[
                      Text(
                        post.title!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontFamily: 'NotoSansArabic',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          post.createdAt ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                        ),
                        const Spacer(),
                        if (post.authorName != null)
                          Text(
                            post.authorName!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final InstitutionModel inst;
  final bool isDark;
  final Function(String) onLaunch;
  const _ContactCard({required this.inst, required this.isDark, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (inst.phone != null && inst.phone!.isNotEmpty)
            _ContactRow(
              icon: Icons.phone_rounded,
              label: inst.phone!,
              color: const Color(0xFF1D9E75),
              onTap: () => onLaunch('tel:${inst.phone!}'),
            ),
          if (inst.email != null && inst.email!.isNotEmpty)
            _ContactRow(
              icon: Icons.email_rounded,
              label: inst.email!,
              color: const Color(0xFF3A7DD4),
              onTap: () => onLaunch('mailto:${inst.email!}'),
            ),
          if (inst.web != null && inst.web!.isNotEmpty)
            _ContactRow(
              icon: Icons.language_rounded,
              label: inst.web!,
              color: const Color(0xFFE05C8A),
              onTap: () => onLaunch(inst.web!.startsWith('http') ? inst.web! : 'https://${inst.web!}'),
            ),
          if (inst.addr != null && inst.addr!.isNotEmpty)
            _ContactRow(
              icon: Icons.location_on_rounded,
              label: inst.addr!,
              color: Colors.orangeAccent,
              onTap: null,
            ),
        ],
      ),
    );
  }
}
