import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/news_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/post_model.dart';
import '../../data/models/news_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchAll(refresh: true);
    });
  }

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

  List<_FeedItem> _buildMixedItems(NewsProvider prov) {
    final list = <_FeedItem>[
      ...prov.posts.map((p) => _FeedItem(post: p, isPost: true, createdAt: p.createdAt)),
      ...prov.news.map((n) => _FeedItem(news: n, isPost: false, createdAt: n.createdAt)),
    ];
    list.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prov = Provider.of<NewsProvider>(context);
    final mixedItems = _buildMixedItems(prov);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF151515) : const Color(0xFFF2F3F7),
        body: NestedScrollView(
          headerSliverBuilder: (ctx, innerScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor:
                  isDark ? const Color(0xFF1E1E1E) : Colors.white,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'پۆستەکان',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'NotoSansArabic',
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (mixedItems.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${mixedItems.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : const Color(0xFFF2F3F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications_none_rounded,
                            size: 22,
                            color: isDark
                                ? Colors.white70
                                : AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            onRefresh: () => prov.fetchAll(refresh: true),
            color: AppColors.primary,
            child: _buildBody(prov, mixedItems, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NewsProvider prov, List<_FeedItem> items, bool isDark) {
    if (prov.loading && items.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: ShimmerBox(
              width: double.infinity, height: 220, borderRadius: 0),
        ),
      );
    }

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.feed_outlined,
        message: 'هیچ ناوەرۆکێک نەدۆزرایەوە',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        if (item.isPost) {
          return _PostCard(
            post: item.post!,
            isDark: isDark,
            timeAgo: _timeAgo,
          );
        } else {
          return _NewsCard(
            news: item.news!,
            isDark: isDark,
            timeAgo: _timeAgo,
            onTap: () => context.push('/news-detail', extra: item.news),
          );
        }
      },
    );
  }
}

// ── Mixed Feed Item Holder ──────────────────────────────────────────
class _FeedItem {
  final PostModel? post;
  final NewsModel? news;
  final bool isPost;
  final String? createdAt;

  _FeedItem({this.post, this.news, required this.isPost, this.createdAt});
}

// ── Post Card (social style) ──────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDark;
  final String Function(String?) timeAgo;

  const _PostCard(
      {required this.post, required this.isDark, required this.timeAgo});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _expanded = false;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final isDark = widget.isDark;
    final hasImage = p.imageUrl.isNotEmpty;
    final isLong = p.content.length > 160;

    return GestureDetector(
      onTap: () => context.push('/news-detail', extra: widget.post),
      child: Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _InstitutionAvatar(
                  logoUrl: p.logoUrl,
                  name: p.displayName,
                  type: p.institutionType,
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic',
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12,
                              color: isDark
                                  ? AppColors.textGrey
                                  : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            widget.timeAgo(p.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'NotoSansArabic',
                              color: isDark
                                  ? AppColors.textGrey
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz_rounded,
                    color: isDark ? Colors.white30 : Colors.black26),
              ],
            ),
          ),

          // Title
          if (p.title != null && p.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                p.title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),

          // Content
          if (p.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, (p.title != null && p.title!.isNotEmpty) ? 8 : 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.content,
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      fontFamily: 'NotoSansArabic',
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textDark,
                    ),
                  ),
                  if (isLong && !_expanded)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = true),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'بینینی زیاتر',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Image
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: p.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF0EFFF),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF0EFFF),
                    child: Icon(Icons.image_outlined,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () => setState(() => _liked = !_liked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _liked
                          ? Colors.red.withValues(alpha: 0.1)
                          : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFF2F3F7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 17,
                          color: _liked
                              ? Colors.redAccent
                              : (isDark ? Colors.white54 : Colors.black38),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _liked ? '١' : 'لایک',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NotoSansArabic',
                            color: _liked
                                ? Colors.redAccent
                                : (isDark
                                    ? Colors.white54
                                    : Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Comment
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 17,
                          color: isDark ? Colors.white54 : Colors.black38),
                      const SizedBox(width: 5),
                      Text(
                        'کۆمێنت',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoSansArabic',
                          color:
                              isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Share
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.share_outlined,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.black38),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color:
                isDark ? AppColors.darkBorder : const Color(0xFFEEEEEE),
          ),
        ],
      ),
    ),);
  }
}

// ── News Card (social style) ──────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final bool isDark;
  final String Function(String?) timeAgo;
  final VoidCallback onTap;

  const _NewsCard({
    required this.news,
    required this.isDark,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = news.displayImageUrl.isNotEmpty;

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.newspaper_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هەواڵی فەرمی',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic',
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12,
                              color: isDark ? AppColors.textGrey : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo(news.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'NotoSansArabic',
                              color: isDark ? AppColors.textGrey : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'هەواڵ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              news.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'NotoSansArabic',
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              news.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                fontFamily: 'NotoSansArabic',
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textDark,
              ),
            ),
          ),

          // Image
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: news.displayImageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF0EFFF),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF0EFFF),
                    child: Icon(Icons.image_outlined,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                ),
              ),
            ),

          // Read more action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'خوێندنەوەی هەواڵ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.share_outlined,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.black38),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color:
                isDark ? AppColors.darkBorder : const Color(0xFFEEEEEE),
          ),
        ],
      ),
    );
  }
}

// ── Institution Avatar ────────────────────────────────────────────────
class _InstitutionAvatar extends StatelessWidget {
  final String logoUrl;
  final String name;
  final String? type;
  final double size;

  const _InstitutionAvatar({
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
        borderRadius: BorderRadius.circular(13),
        color: _typeColor.withValues(alpha: 0.1),
        border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
      ),
      child: logoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
