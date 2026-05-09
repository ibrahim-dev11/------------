import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/news_model.dart';
import '../../data/models/post_model.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel? news;
  final PostModel? post;

  const NewsDetailScreen({super.key, this.news, this.post});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _liked = false;

  String _timeAgo(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'ئێستا';
      if (diff.inMinutes < 60) return '${diff.inMinutes} خولەک لەمەوبەر';
      if (diff.inHours < 24) return '${diff.inHours} کاتژمێر لەمەوبەر';
      if (diff.inDays < 7) return '${diff.inDays} ڕۆژ لەمەوبەر';
      final d = dt;
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'university':
        return 'زانکۆ';
      case 'school':
        return 'قوتابخانە';
      case 'language_center':
        return 'سەنتەری زمان';
      case 'kindergarten':
        return 'باخچەی ساوایان';
      default:
        return 'فەرمی';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract common fields for unified rendering
    final title = widget.post?.title ?? widget.news?.title ?? '';
    final content = widget.post?.content ?? widget.news?.content ?? '';
    final imageUrl = widget.post?.imageUrl ?? widget.news?.displayImageUrl ?? '';
    final hasImage = imageUrl.isNotEmpty;
    final createdAt = widget.post?.createdAt ?? widget.news?.createdAt;
    final displayName = widget.post?.displayName ?? 'هەواڵی فەرمی';
    final logoUrl = widget.post?.logoUrl ?? '';
    final type = widget.post?.institutionType;
    final isPost = widget.post != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF151515) : const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                isPost ? 'ڕوونکردنەوە و پۆست' : 'دەقی هەواڵ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F3F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.share_outlined,
                    size: 18, color: isDark ? Colors.white70 : AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Premium Institution Card ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF202020), Color(0xFF181818)],
                            )
                          : const LinearGradient(
                              colors: [Colors.white, Color(0xFFFDFCFC)],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF),
                      ),
                    ),
                    child: Row(
                      children: [
                        _Avatar(
                          logoUrl: logoUrl,
                          name: displayName,
                          type: type,
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'NotoSansArabic',
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 12,
                                      color: isDark ? AppColors.textGrey : AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    _timeAgo(createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'NotoSansArabic',
                                      color: isDark ? AppColors.textGrey : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isPost ? AppColors.primary : AppColors.success)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getTypeLabel(type),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isPost ? AppColors.primary : AppColors.success,
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
                  ),
                  const SizedBox(height: 24),

                  // ── Title ──────────────────────────────────────────────────
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'NotoSansArabic',
                          color: isDark ? Colors.white : AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  if (title.isNotEmpty) const SizedBox(height: 16),

                  // ── Content ────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFECEFF3),
                      ),
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.9,
                        fontFamily: 'NotoSansArabic',
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.textDark.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Premium Square Image ──────────────────────────────────
                  if (hasImage)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
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
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── Premium Interaction Bottom Bar ────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF),
            ),
          ),
        ),
        child: Row(
          children: [
            // Like Button
            GestureDetector(
              onTap: () => setState(() => _liked = !_liked),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _liked
                      ? Colors.red.withValues(alpha: 0.1)
                      : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F3F7)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 20,
                      color: _liked ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _liked ? 'لایک کرا' : 'پەسندکردن',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'NotoSansArabic',
                        color: _liked ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Comment Button Placeholder
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F3F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نووسینی کۆمێنت...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSansArabic',
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        return const Color(0xFF534AB7);
      case 'school':
        return const Color(0xFF1D9E75);
      case 'language_center':
        return const Color(0xFF3A7DD4);
      case 'kindergarten':
        return const Color(0xFFD4A017);
      default:
        return AppColors.primary;
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
              borderRadius: BorderRadius.circular(15),
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
