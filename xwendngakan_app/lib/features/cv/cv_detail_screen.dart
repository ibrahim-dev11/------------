import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
      setState(() { _cv = result.data; _loading = false; });
    } else {
      setState(() { _error = result.error; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/cvs'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _cv == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/cvs'),
          ),
        ),
        body: EmptyState(
          icon: Icons.description_outlined,
          message: _error ?? l.noData,
          actionLabel: l.retry,
          onAction: () { setState(() { _loading = true; _error = null; }); _load(); },
        ),
      );
    }

    final cv = _cv!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────
          SliverToBoxAdapter(child: _CvHeader(cv: cv, onBack: () => context.canPop() ? context.pop() : context.go('/cvs'))),

          // ── Stats Row ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _StatsRow(cv: cv, l: l),
            ),
          ),

          // ── Skills ──────────────────────────────
          if (cv.skills != null && cv.skills!.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: l.skills,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cv.skills!
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .map((s) => _Chip(label: s))
                      .toList(),
                ),
              ),
            ),

          // ── Experience ──────────────────────────
          if (cv.experience != null && cv.experience!.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: l.experience,
                child: Text(
                  cv.experience!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.textGrey,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),

          // ── Notes ───────────────────────────────
          if (cv.notes != null && cv.notes!.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: l.notes,
                child: Text(
                  cv.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.textGrey,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),

          // ── Contact ─────────────────────────────
          if ((cv.phone != null && cv.phone!.isNotEmpty) ||
              (cv.email != null && cv.email!.isNotEmpty))
            SliverToBoxAdapter(
              child: _Section(
                title: l.contactInfo,
                child: Column(
                  children: [
                    if (cv.phone != null && cv.phone!.isNotEmpty)
                      _ContactRow(
                        icon: Icons.call_rounded,
                        label: cv.phone!,
                        color: AppColors.success,
                        onTap: () => _launch('tel:${cv.phone}'),
                      ),
                    if (cv.email != null && cv.email!.isNotEmpty) ...[
                      if (cv.phone != null && cv.phone!.isNotEmpty)
                        const SizedBox(height: 8),
                      _ContactRow(
                        icon: Icons.email_rounded,
                        label: cv.email!,
                        color: AppColors.primary,
                        onTap: () => _launch('mailto:${cv.email}'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ── Header ──────────────────────────────────────────
class _CvHeader extends StatelessWidget {
  final CvModel cv;
  final VoidCallback onBack;
  const _CvHeader({required this.cv, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C5CE7), Color(0xFF9B59B6)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Positioned(
          top: -30, right: -30,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    if (cv.isReviewed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context).cvVerified, style: const TextStyle(
                              color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.w600, fontFamily: 'NotoSansArabic',
                            )),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 74, height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                  ),
                  child: cv.photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            cv.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded,
                                size: 36, color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(cv.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'NotoSansArabic')),
                if (cv.field != null) ...[
                  const SizedBox(height: 4),
                  Text(cv.field!,
                      style: const TextStyle(fontSize: 13, color: Colors.white70,
                          fontFamily: 'NotoSansArabic')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats Row ────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final CvModel cv;
  final AppLocalizations l;
  const _StatsRow({required this.cv, required this.l});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(
            icon: Icons.cake_rounded,
            value: cv.age != null ? '${cv.age} ${l.years}' : '—',
            label: l.age,
            color: AppColors.primary,
          )),
          _Div(),
          Expanded(child: _StatItem(
            icon: Icons.school_rounded,
            value: cv.graduationYear?.toString() ?? '—',
            label: l.graduationYear,
            color: const Color(0xFF9B59B6),
          )),
          _Div(),
          Expanded(child: _StatItem(
            icon: Icons.location_on_rounded,
            value: cv.city ?? '—',
            label: l.city,
            color: const Color(0xFFD4A017),
          )),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, fontFamily: 'NotoSansArabic')),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'NotoSansArabic')),
      ],
    );
  }
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 50, color: AppColors.lightBorder);
}

// ── Section ──────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1a1a1a),
              fontFamily: 'NotoSansArabic',
            )),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Chip ─────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.primary, fontFamily: 'NotoSansArabic',
      )),
    );
  }
}

// ── Contact Row ──────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: color, fontFamily: 'NotoSansArabic',
            )),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}
