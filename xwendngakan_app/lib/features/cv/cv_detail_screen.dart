import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/cv_model.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/common_widgets.dart';

class CvDetailScreen extends StatefulWidget {
  final String id;
  const CvDetailScreen({super.key, required this.id});

  @override
  State<CvDetailScreen> createState() => _CvDetailScreenState();
}

class _CvDetailScreenState extends State<CvDetailScreen> {
  final _api = ApiService();
  CvModel? _cv;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _api.getCv(int.tryParse(widget.id) ?? 0);
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() {
        _cv = result.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _loading = false;
      });
    }
  }

  void _shareCv(CvModel cv, AppLocalizations l) {
    final text =
        'EduBook CV: ${cv.name}\n${cv.field ?? ""}\n\n${cv.experience ?? ""}\n\nDownloaded from EduBook App';
    Share.share(text);
  }

  void _showContactSheet(CvModel cv, AppLocalizations l, bool isDark) {
    if (cv.phone == null) return;

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
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(l.contactTeacher,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Rabar')),
            const SizedBox(height: 24),
            _buildContactOption(
                Icons.phone_rounded, l.contactPhone, const Color(0xFF3B82F6),
                () {
              Navigator.pop(context);
              _launch('tel:${cv.phone}');
            }, isDark),
            const SizedBox(height: 12),
            _buildContactOption(
                Icons.wechat_rounded, l.whatsApp, const Color(0xFF10B981), () {
              Navigator.pop(context);
              final phone = cv.phone!.replaceAll(RegExp(r'[^0-9]'), '');
              _launch('https://wa.me/$phone');
            }, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String label, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Rabar')),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: color.withValues(alpha: 0.5)),
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
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _cv == null) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: EmptyState(
          icon: Icons.description_outlined,
          message: _error ?? l.noData,
          actionLabel: l.retry,
          onAction: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            _load();
          },
        ),
      );
    }

    final cv = _cv!;
    final accentColor = AppColors.primary;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40)),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -40,
                              right: -40,
                              child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle)),
                            ),
                          ],
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCircleAction(
                                  Icons.arrow_back_ios_new_rounded,
                                  () => context.pop()),
                              Text(l.viewDetails,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Rabar')),
                              _buildCircleAction(Icons.ios_share_rounded,
                                  () => _shareCv(cv, l)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -45,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardColor,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8))
                              ],
                            ),
                            child: ClipOval(
                              child: cv.photoUrl.isNotEmpty
                                  ? Image.network(cv.photoUrl,
                                      fit: BoxFit.cover)
                                  : Icon(Icons.person,
                                      size: 50,
                                      color:
                                          accentColor.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 55)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(cv.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                                fontFamily: 'Rabar')),
                        const SizedBox(height: 4),
                        Text(cv.field ?? '',
                            style: TextStyle(
                                fontSize: 15,
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Rabar')),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            if (cv.age != null)
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.cake_rounded,
                                      l.age,
                                      '${cv.age} ${l.yearsUnit}',
                                      const Color(0xFFF59E0B),
                                      isDark)),
                            const SizedBox(width: 10),
                            if (cv.city != null)
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.location_on_rounded,
                                      l.city,
                                      cv.city!,
                                      const Color(0xFF3B82F6),
                                      isDark)),
                            const SizedBox(width: 10),
                            if (cv.genderLabel != null || cv.gender != null)
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.person_outline_rounded,
                                      l.gender,
                                      cv.genderLabel ??
                                          (cv.gender == 'male'
                                              ? l.male
                                              : l.female),
                                      const Color(0xFF10B981),
                                      isDark)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (cv.experience != null && cv.experience!.isNotEmpty)
                          _buildSectionCard(
                              l.experience,
                              Icons.work_history_rounded,
                              _buildPremiumText(
                                  cv.experience!, isDark, accentColor),
                              isDark,
                              accentColor,
                              cardColor),
                        if (cv.educationLevel != null)
                          _buildSectionCard(
                              l.educationLevel,
                              Icons.school_rounded,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('بڕوانامەی ${cv.educationLevel!}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontFamily: 'Rabar')),
                                  if (cv.graduationYear != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                          'دەرچووی ساڵی ${cv.graduationYear}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Rabar')),
                                    ),
                                ],
                              ),
                              isDark,
                              accentColor,
                              cardColor),
                        if (cv.skills != null && cv.skills!.isNotEmpty)
                          _buildSectionCard(
                              l.skills,
                              Icons.auto_awesome_rounded,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cv.skills!
                                    .split(',')
                                    .map((s) => _buildModernChip(
                                        s.trim(), isDark, accentColor))
                                    .toList(),
                              ),
                              isDark,
                              accentColor,
                              cardColor),
                        if (cv.languages != null && cv.languages!.isNotEmpty)
                          _buildSectionCard(
                              l.languages,
                              Icons.translate_rounded,
                              Column(
                                children: cv.languages!
                                    .split(',')
                                    .map((e) => _buildLanguageRow(
                                        e, isDark, accentColor))
                                    .toList(),
                              ),
                              isDark,
                              accentColor,
                              cardColor),
                        if (cv.notes != null && cv.notes!.isNotEmpty)
                          _buildSectionCard(
                              l.notes,
                              Icons.description_rounded,
                              _buildPremiumText(cv.notes!, isDark, accentColor),
                              isDark,
                              accentColor,
                              cardColor),
                        _buildSectionCard(
                            l.contact,
                            Icons.alternate_email_rounded,
                            _buildContactList(cv, isDark, accentColor),
                            isDark,
                            accentColor,
                            cardColor),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildPremiumFooter(cv, isDark, accentColor, l),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontFamily: 'Rabar')),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Rabar')),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content,
      bool isDark, Color accent, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 12),
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isDark ? Colors.white38 : Colors.black45,
                      fontFamily: 'Rabar')),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildPremiumText(String text, bool isDark, Color accent) {
    final urlRegex = RegExp(r'(https?://[^\s]+)');
    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(text,
          style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'Rabar'));
    }
    return GestureDetector(
      onTap: () {
        final match = urlRegex.firstMatch(text);
        if (match != null) _launch(match.group(0)!);
      },
      child: Text(text,
          style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: accent,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
              fontFamily: 'Rabar')),
    );
  }

  Widget _buildModernChip(String skill, bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12)),
      child: Text(skill,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'Rabar')),
    );
  }

  Widget _buildLanguageRow(String lang, bool isDark, Color accent) {
    String name = lang;
    String? level;
    if (lang.contains('(')) {
      final parts = lang.split('(');
      name = parts[0].trim();
      level = parts[1].replaceAll(')', '').trim();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Rabar')),
          if (level != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(level,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      fontFamily: 'Rabar')),
            ),
        ],
      ),
    );
  }

  Widget _buildContactList(CvModel cv, bool isDark, Color accent) {
    return Column(
      children: [
        if (cv.phone != null)
          _buildContactItem(Icons.phone_iphone_rounded, cv.phone!,
              () => _launch('tel:${cv.phone}'), isDark, accent),
        if (cv.email != null) ...[
          const SizedBox(height: 12),
          _buildContactItem(Icons.mail_outline_rounded, cv.email!,
              () => _launch('mailto:${cv.email}'), isDark, accent)
        ],
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String value, VoidCallback onTap,
      bool isDark, Color accent) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 16),
            Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: accent,
                        fontFamily: 'Rabar'))),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: accent.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFooter(
      CvModel cv, bool isDark, Color accent, AppLocalizations l) {
    return Positioned(
      bottom: 24,
      left: 30,
      right: 30,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: InkWell(
          onTap: () => _showContactSheet(cv, l, isDark),
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(l.contactTeacher,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        fontFamily: 'Rabar')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
