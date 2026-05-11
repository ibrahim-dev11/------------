import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
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

  String _timeAgo(String? raw, AppLocalizations l) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return l.timeNow;
      if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
      if (diff.inDays < 7) return l.timeDaysAgo(diff.inDays);
      final d = dt;
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  List<_FeedItem> _buildMixedItems(NewsProvider prov) {
    final list = <_FeedItem>[
      ...prov.posts
          .map((p) => _FeedItem(post: p, isPost: true, createdAt: p.createdAt)),
      ...prov.news.map(
          (n) => _FeedItem(news: n, isPost: false, createdAt: n.createdAt)),
    ];
    list.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final prov = Provider.of<NewsProvider>(context);
    final mixedItems = _buildMixedItems(prov);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
        body: RefreshIndicator(
          onRefresh: () => prov.fetchAll(refresh: true),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // ── BREATHTAKING GRADIENT APP BAR (Same style as Home Page Header) ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative Glowing Circles
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),

                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                          child: Row(
                            children: [
                              // Icon & Titles
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.space_dashboard_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.news,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.newsSubtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Notifications Button
                              GestureDetector(
                                onTap: () => context.push('/notifications'),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF4757),
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
                  ),
                ),
              ),

              // ── Feed Content List ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                sliver: prov.loading && mixedItems.isEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: ShimmerBox(
                                width: double.infinity,
                                height: 180,
                                borderRadius: 20),
                          ),
                          childCount: 4,
                        ),
                      )
                    : mixedItems.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 80),
                              child: EmptyState(
                                icon: Icons.feed_outlined,
                                message: l.noContent,
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) {
                                final item = mixedItems[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: item.isPost
                                      ? _PostCard(
                                          post: item.post!,
                                          isDark: isDark,
                                          timeAgo: (s) => _timeAgo(s, l),
                                        )
                                      : _NewsCard(
                                          news: item.news!,
                                          isDark: isDark,
                                          timeAgo: (s) => _timeAgo(s, l),
                                          officialNews: l.officialNews,
                                          newsTag: l.newsTag,
                                          onTap: () => context.push(
                                              '/news-detail',
                                              extra: item.news),
                                        ),
                                );
                              },
                              childCount: mixedItems.length,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
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
                    top: (post.title != null && post.title!.isNotEmpty)
                        ? 6
                        : 10),
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
  final String officialNews;
  final String newsTag;

  const _NewsCard({
    required this.news,
    required this.isDark,
    required this.timeAgo,
    required this.onTap,
    required this.officialNews,
    required this.newsTag,
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
                        officialNews,
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
                            timeAgo(news.createdAt),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    newsTag,
                    style: const TextStyle(
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
