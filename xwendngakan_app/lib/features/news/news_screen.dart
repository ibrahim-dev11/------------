import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/news_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/news_model.dart';
import '../../data/models/post_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false)
          .fetchAll(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prov = Provider.of<NewsProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, innerIsScrolled) => [
            _buildAppBar(isDark, prov, innerIsScrolled),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _NewsTab(
                prov: prov,
                isDark: isDark,
                formatDate: _formatDate,
                onTap: (news) => context.push('/news-detail', extra: news),
              ),
              _PostsTab(
                prov: prov,
                isDark: isDark,
                formatDate: _formatDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, NewsProvider prov, bool scrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      collapsedHeight: 70,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // gradient bg
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3E389A), Color(0xFF534AB7), Color(0xFF7F77DD)],
                ),
              ),
            ),
            // decorative circles
            Positioned(
              top: -40, right: -20,
              child: _Circle(size: 170, opacity: 0.07),
            ),
            Positioned(
              bottom: 30, left: -50,
              child: _Circle(size: 200, opacity: 0.05),
            ),
            // header content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(Icons.article_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('هەواڵ و پۆستەکان',
                              style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900,
                                color: Colors.white, fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${prov.news.length} هەواڵ · ${prov.posts.length} پۆست',
                                style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: Colors.white, fontFamily: 'NotoSansArabic',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Collapsed title
      title: AnimatedOpacity(
        opacity: scrolled ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Text('هەواڵ و پۆستەکان',
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: Colors.white, fontFamily: 'NotoSansArabic',
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabCtrl,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansArabic',
        ),
        tabs: [
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.newspaper_rounded, size: 18),
              const SizedBox(width: 6),
              Text('هەواڵ (${prov.news.length})'),
            ]),
          ),
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.dashboard_rounded, size: 18),
              const SizedBox(width: 6),
              Text('پۆستەکان (${prov.posts.length})'),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── News Tab ─────────────────────────────────────────────────────────
class _NewsTab extends StatelessWidget {
  final NewsProvider prov;
  final bool isDark;
  final String Function(String?) formatDate;
  final void Function(NewsModel) onTap;

  const _NewsTab({
    required this.prov,
    required this.isDark,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (prov.loadingNews && prov.news.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(width: double.infinity, height: 260, borderRadius: 20),
        ),
      );
    }

    if (prov.news.isEmpty) {
      return EmptyState(icon: Icons.newspaper_outlined, message: 'هیچ هەواڵێک نەدۆزرایەوە');
    }

    return RefreshIndicator(
      onRefresh: () async => prov.fetchNews(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: prov.news.length,
        itemBuilder: (_, i) {
          final news = prov.news[i];
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _FeaturedNewsCard(
                news: news, isDark: isDark,
                formatDate: formatDate, onTap: () => onTap(news),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _NewsCard(news: news, isDark: isDark, formatDate: formatDate, onTap: () => onTap(news)),
          );
        },
      ),
    );
  }
}

// ── Posts Tab ─────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final NewsProvider prov;
  final bool isDark;
  final String Function(String?) formatDate;

  const _PostsTab({required this.prov, required this.isDark, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    if (prov.loadingPosts && prov.posts.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(width: double.infinity, height: 180, borderRadius: 20),
        ),
      );
    }

    if (prov.posts.isEmpty) {
      return EmptyState(icon: Icons.dashboard_outlined, message: 'هیچ پۆستێک نەدۆزرایەوە');
    }

    return RefreshIndicator(
      onRefresh: () async => prov.fetchPosts(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: prov.posts.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PostCard(post: prov.posts[i], isDark: isDark, formatDate: formatDate),
        ),
      ),
    );
  }
}

// ── Featured News Card ────────────────────────────────────────────────
class _FeaturedNewsCard extends StatelessWidget {
  final NewsModel news;
  final bool isDark;
  final VoidCallback onTap;
  final String Function(String?) formatDate;

  const _FeaturedNewsCard({
    required this.news, required this.isDark,
    required this.onTap, required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20, offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (news.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: news.imageUrl!, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _NoImage(isDark: isDark),
                )
              else
                _NoImage(isDark: isDark),

              // gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xAA000000), Color(0xDD000000)],
                    stops: [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // tag
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('تازەترین',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'NotoSansArabic'),
                      ),
                    ],
                  ),
                ),
              ),

              // bottom content
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900,
                            color: Colors.white, fontFamily: 'NotoSansArabic', height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(formatDate(news.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('خوێندنەوە',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                      color: Colors.white, fontFamily: 'NotoSansArabic'),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ── Regular News Card ─────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final bool isDark;
  final VoidCallback onTap;
  final String Function(String?) formatDate;

  const _NewsCard({required this.news, required this.isDark, required this.onTap, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 14, offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), bottomLeft: Radius.circular(20),
              ),
              child: SizedBox(
                width: 110, height: 110,
                child: news.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: news.imageUrl!, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _ThumbPlaceholder(isDark: isDark),
                      )
                    : _ThumbPlaceholder(isDark: isDark),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          fontFamily: 'NotoSansArabic', height: 1.4,
                          color: isDark ? Colors.white : AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(news.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.5, fontFamily: 'NotoSansArabic',
                          color: isDark ? AppColors.textGrey : AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(formatDate(news.createdAt),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
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

// ── Post Card ─────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool isDark;
  final String Function(String?) formatDate;

  const _PostCard({required this.post, required this.isDark, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14, offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — institution info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? 'دامەزراوە',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                            fontFamily: 'NotoSansArabic',
                            color: isDark ? Colors.white : AppColors.textDark),
                      ),
                      Text(formatDate(post.createdAt),
                        style: TextStyle(fontSize: 11, fontFamily: 'NotoSansArabic',
                            color: isDark ? AppColors.textGrey : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('پۆست',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.primary, fontFamily: 'NotoSansArabic'),
                  ),
                ),
              ],
            ),
          ),

          // Title (if exists)
          if (post.title != null && post.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(post.title!,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    fontFamily: 'NotoSansArabic',
                    color: isDark ? Colors.white : AppColors.textDark),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.6, fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white70 : AppColors.textMuted),
            ),
          ),

          // Image (if exists)
          if (hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  height: 180, width: double.infinity, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _NoImage(isDark: isDark, height: 180),
                ),
              ),
            ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  final bool isDark;
  final double height;
  const _NoImage({required this.isDark, this.height = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECEAFF),
      child: Center(
        child: Icon(Icons.newspaper_rounded, size: 56,
            color: AppColors.primary.withValues(alpha: 0.35)),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  final bool isDark;
  const _ThumbPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECEAFF),
      child: Icon(Icons.newspaper_rounded, size: 32,
          color: AppColors.primary.withValues(alpha: 0.35)),
    );
  }
}
