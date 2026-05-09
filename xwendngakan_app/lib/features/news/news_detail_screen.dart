import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/news_model.dart';
import '../../data/models/post_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel? news;
  final PostModel? post;

  const NewsDetailScreen({super.key, this.news, this.post});

  String _timeAgo(String? raw, AppLocalizations l) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return l.timeNow;
      if (diff.inMinutes < 60) return l.timeMinutesAgoBefore(diff.inMinutes);
      if (diff.inHours < 24) return l.timeHoursAgoBefore(diff.inHours);
      if (diff.inDays < 7) return l.timeDaysAgoBefore(diff.inDays);
      final d = dt;
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  String _getTypeLabel(String? type, AppLocalizations l) {
    switch (type) {
      case 'university':
        return l.typeUniversity;
      case 'school':
        return l.typeSchool;
      case 'language_center':
        return l.typeLanguageCenter;
      case 'kindergarten':
        return l.typeKindergarten;
      default:
        return l.newsTag;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'university':
        return const Color(0xFF6366F1); // Indigo
      case 'school':
        return const Color(0xFF10B981); // Emerald
      case 'language_center':
        return const Color(0xFF3B82F6); // Blue
      case 'kindergarten':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFFEC4899); // Pink
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    // Extract common fields for unified rendering
    final title = post?.title ?? news?.title ?? '';
    final content = post?.content ?? news?.content ?? '';
    final imageUrl = post?.imageUrl ?? news?.displayImageUrl ?? '';
    final hasImage = imageUrl.isNotEmpty;
    final createdAt = post?.createdAt ?? news?.createdAt;
    final displayName = post?.displayName ?? l.officialNews;
    final logoUrl = post?.logoUrl ?? '';
    final type = post?.institutionType;
    final typeColor = _getTypeColor(type);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Beautiful Background Decorative Gradient Blob ──────────────────
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    typeColor.withValues(alpha: isDark ? 0.08 : 0.05),
                    Colors.transparent,
                  ],
                  radius: 1.3,
                ),
              ),
            ),
          ),

          // ── Scrollable Editorial Content ──────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Breathtaking Navigation Header Bar ────────────────────────
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 15,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Main Body Card Content ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Institution Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: typeColor.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: _Avatar(
                                logoUrl: logoUrl,
                                name: displayName,
                                type: type,
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'NotoSansArabic',
                                          color: isDark ? Colors.white : AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 15,
                                        color: typeColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 11,
                                          color: isDark ? Colors.white38 : Colors.black38),
                                      const SizedBox(width: 4),
                                      Text(
                                        _timeAgo(createdAt, l),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'NotoSansArabic',
                                          color: isDark ? Colors.white38 : Colors.black38,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: typeColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _getTypeLabel(type, l),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: typeColor,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'NotoSansArabic',
                              color: isDark ? Colors.white : AppColors.textDark,
                              height: 1.4,
                              letterSpacing: -0.2,
                            ),
                          ),
                        if (title.isNotEmpty) const SizedBox(height: 18),

                        // Content (Styled as Premium Editorial Book)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Elegant editorial quotation mark
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Opacity(
                                  opacity: 0.05,
                                  child: Icon(
                                    Icons.format_quote_rounded,
                                    size: 50,
                                    color: typeColor,
                                  ),
                                ),
                              ),
                              Text(
                                content,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 2.0,
                                  fontFamily: 'NotoSansArabic',
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.textDark.withValues(alpha: 0.95),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Breathtaking 1:1 Square Image Showcase
                        if (hasImage)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark ? const Color(0xFF262626) : Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: typeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: isDark ? const Color(0xFF252525) : const Color(0xFFF2F3F7),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: isDark ? const Color(0xFF252525) : const Color(0xFFF2F3F7),
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: typeColor.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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

// ── Avatar Helper ─────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String logoUrl;
  final String name;
  final String? type;
  final double size;

  const _Avatar({
    required this.logoUrl,
    required this.name,
    this.type,
    required this.size,
  });

  Color get _typeColor {
    switch (type) {
      case 'university':
        return const Color(0xFF6366F1);
      case 'school':
        return const Color(0xFF10B981);
      case 'language_center':
        return const Color(0xFF3B82F6);
      case 'kindergarten':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEC4899);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _typeColor.withValues(alpha: 0.1),
        border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
      ),
      child: logoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback,
              ),
            )
          : _fallback,
    );
  }

  Widget get _fallback => Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'د',
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            color: _typeColor,
            fontFamily: 'NotoSansArabic',
          ),
        ),
      );
}
