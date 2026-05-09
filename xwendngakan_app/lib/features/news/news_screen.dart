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
      if (diff.inMinutes < 60) return '${diff.inMinutes} خولەک پێش';
      if (diff.inHours < 24) return '${diff.inHours} کاتژمێر پێش';
      if (diff.inDays < 7) return '${diff.inDays} ڕۆژ پێش';
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
            isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FA),
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
              // Enhanced Premium App Bar Design
              title: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Brand Indicator Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.space_dashboard_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'هەواڵەکان',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'NotoSansArabic',
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Premium Notifications Button
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: isDark ? Colors.white70 : AppColors.textDark,
                            ),
                            Positioned(
                              top: 9,
                              right: 9,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
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
              width: double.infinity, height: 180, borderRadius: 16),
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
      padding: const EdgeInsets.only(top: 12, bottom: 100, left: 16, right: 16),
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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

// ── Compact Post Card (Minimalist Style) ─────────────────────────────
class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool isDark;
  final String Function(String?) timeAgo;

  const _PostCard({
    required this.post,
    required this.isDark,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/news-detail', extra: post),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _InstitutionAvatar(
                  logoUrl: post.logoUrl,
                  name: post.displayName,
                  type: post.institutionType,
                  size: 38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.displayName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic',
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 10,
                              color: isDark
                                  ? AppColors.textGrey
                                  : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo(post.createdAt),
                            style: TextStyle(
                              fontSize: 11,
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),

            // Title
            if (post.title != null && post.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  post.title!,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'NotoSansArabic',
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),

            // Content
            if (post.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                    top: (post.title != null && post.title!.isNotEmpty) ? 6 : 10),
                child: Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    fontFamily: 'NotoSansArabic',
                    color: isDark
                        ? Colors.white70
                        : AppColors.textDark.withValues(alpha: 0.8),
                  ),
                ),
              ),

            // Compact 1:1 Image with rounded corners
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFF2F3F7),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFF2F3F7),
                        child: Icon(Icons.image_outlined,
                            size: 32,
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Compact News Card (Minimalist Style) ─────────────────────────────
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.newspaper_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هەواڵی فەرمی',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic',
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 10,
                              color: isDark ? AppColors.textGrey : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo(news.createdAt),
                            style: TextStyle(
                              fontSize: 11,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'هەواڵ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ],
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                news.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                news.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  fontFamily: 'NotoSansArabic',
                  color: isDark
                      ? Colors.white70
                      : AppColors.textDark.withValues(alpha: 0.8),
                ),
              ),
            ),

            // Compact 1:1 Image with rounded corners
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: news.displayImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFF2F3F7),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFF2F3F7),
                        child: Icon(Icons.image_outlined,
                            size: 32,
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(11),
        color: _typeColor.withValues(alpha: 0.1),
        border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
      ),
      child: logoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
