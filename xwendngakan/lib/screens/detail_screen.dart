import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final Institution institution;

  const DetailScreen({super.key, required this.institution});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _activeTab = 0;
  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  late final bool _isUniversity;

  @override
  void initState() {
    super.initState();
    final type = widget.institution.type;
    _isUniversity = ['gov', 'priv', 'eve_uni'].contains(type);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await ApiService.getInstitutionPosts(widget.institution.id);
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      debugPrint("Error loading posts: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.institution;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        AppConstants.typeGradients[d.type]?[0] ?? const Color(0xFF6366F1);
    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildHeaderBtn(
          Iconsax.arrow_right_3,
          () => Navigator.pop(context),
          isDark,
        ),
        actions: [
          _buildHeaderBtn(
            context.watch<AppProvider>().isFavorite(d.id)
                ? Iconsax.heart5
                : Iconsax.heart,
            () => context.read<AppProvider>().toggleFavorite(d.id),
            isDark,
            iconColor: context.watch<AppProvider>().isFavorite(d.id)
                ? Colors.red
                : Colors.white,
          ),
          _buildHeaderBtn(Iconsax.share, () => _shareInstitution(d), isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- TOP COMPACT BANNER ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Banner background
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // If there is an institution image, show it
                        if (d.img.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: d.img,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: primaryColor.withOpacity(0.3)),
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                          ),
                        // Dark overlay for readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                        // Pattern overlay
                        Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Iconsax.building_3,
                            size: 200,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  child: Hero(
                    tag: 'inst_logo_${d.id}',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: surfaceColor,
                        backgroundImage: d.logo.isNotEmpty
                            ? CachedNetworkImageProvider(d.logo)
                            : null,
                        child: d.logo.isEmpty
                            ? Icon(
                                Iconsax.teacher,
                                color: primaryColor,
                                size: 35,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 55),

            // --- TITLE & BADGES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          d.nameForLang(context.read<AppProvider>().language),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 20, color: primaryColor),
                    ],
                  ),
                  if (d.nen.isNotEmpty &&
                      context.read<AppProvider>().language != 'en')
                    Text(
                      d.nen,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (d.nar.isNotEmpty &&
                      context.read<AppProvider>().language != 'ar')
                    Text(
                      d.nar,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      _badgeChip(
                        d.city,
                        Iconsax.location,
                        Colors.grey[600]!,
                        isDark,
                      ),
                      _badgeChip(
                        context.read<AppProvider>().typeLabel(d.type),
                        Iconsax.category,
                        primaryColor,
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- INTERACTIVE ACTION GRID ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildActionTile(
                    Iconsax.call,
                    S.of(context, 'call'),
                    const Color(0xFF10B981),
                    () => _launchUrl('tel:${d.phone}'),
                    surfaceColor,
                  ),
                  const SizedBox(width: 12),
                  _buildActionTile(
                    Iconsax.global,
                    S.of(context, 'website'),
                    const Color(0xFF3B82F6),
                    () => _launchUrl(d.web),
                    surfaceColor,
                  ),
                  const SizedBox(width: 12),
                  _buildActionTile(
                    Iconsax.map_1,
                    S.of(context, 'locationTab'),
                    const Color(0xFFF59E0B),
                    () => _openMap(d),
                    surfaceColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- PREMIUM SEGMENTED TAB BAR ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    _buildTab(0, S.of(context, 'aboutTab'), primaryColor),
                    _buildTab(1, S.of(context, 'postsTab'), primaryColor),
                    _buildTab(
                      2,
                      _isUniversity
                          ? S.of(context, 'college')
                          : S.of(context, 'department'),
                      primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- DYNAMIC CONTENT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _renderActiveTab(d, isDark, primaryColor, surfaceColor),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBtn(
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _badgeChip(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
    Color surfaceColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Color primaryColor) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primaryColor : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderActiveTab(
    Institution d,
    bool isDark,
    Color primaryColor,
    Color surfaceColor,
  ) {
    switch (_activeTab) {
      case 0:
        return Column(
          children: [
            _contentContainer(surfaceColor, [
              Text(
                S.of(context, 'aboutTab'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                d.desc.isEmpty ? S.of(context, 'noAboutInfo') : d.desc,
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
              if (d.kgAge.isNotEmpty || d.kgHours.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                if (d.kgAge.isNotEmpty)
                  _infoRow(
                    Iconsax.user,
                    S.of(context, 'admissionAge'),
                    d.kgAge,
                    primaryColor,
                  ),
                if (d.kgHours.isNotEmpty)
                  _infoRow(
                    Iconsax.clock,
                    S.of(context, 'workHours'),
                    d.kgHours,
                    primaryColor,
                  ),
              ],
            ]),
            const SizedBox(height: 16),
            _contentContainer(surfaceColor, [
              Text(
                S.of(context, 'contactTab'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              if (d.phone.isNotEmpty)
                _infoRow(
                  Iconsax.call,
                  S.of(context, 'phone'),
                  d.phone,
                  primaryColor,
                  onTap: () => _launchUrl('tel:${d.phone}'),
                ),
              if (d.email.isNotEmpty)
                _infoRow(
                  Iconsax.sms,
                  S.of(context, 'email'),
                  d.email,
                  primaryColor,
                  onTap: () => _launchUrl('mailto:${d.email}'),
                ),
              if (d.web.isNotEmpty)
                _infoRow(
                  Iconsax.global,
                  S.of(context, 'website'),
                  d.web,
                  primaryColor,
                  onTap: () => _launchUrl(d.web),
                ),
              if (d.addr.isNotEmpty)
                _infoRow(
                  Iconsax.map,
                  S.of(context, 'address'),
                  d.addr,
                  primaryColor,
                  onTap: () => _openMap(d),
                ),

              // Social Media Grid
              if (d.fb.isNotEmpty ||
                  d.wa.isNotEmpty ||
                  d.ig.isNotEmpty ||
                  d.yt.isNotEmpty ||
                  d.tk.isNotEmpty ||
                  d.tg.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (d.fb.isNotEmpty)
                      _socialIcon(
                        Icons.facebook,
                        const Color(0xFF1877F2),
                        () => _launchUrl(d.fb),
                      ),
                    if (d.wa.isNotEmpty)
                      _socialIcon(
                        Iconsax.message,
                        const Color(0xFF25D366),
                        () => _launchUrl('https://wa.me/${d.wa}'),
                      ),
                    if (d.ig.isNotEmpty)
                      _socialIcon(
                        Icons.camera_alt,
                        const Color(0xFFE4405F),
                        () => _launchUrl(d.ig),
                      ),
                    if (d.yt.isNotEmpty)
                      _socialIcon(
                        Iconsax.video_circle,
                        const Color(0xFFFF0000),
                        () => _launchUrl(d.yt),
                      ),
                    if (d.tg.isNotEmpty)
                      _socialIcon(
                        Iconsax.send_1,
                        const Color(0xFF0088CC),
                        () => _launchUrl(d.tg),
                      ),
                  ],
                ),
              ],
            ]),
          ],
        );
      case 1:
        if (_isLoadingPosts)
          return const Center(child: CircularProgressIndicator());

        return Column(
          children: [

            if (_posts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(S.of(context, 'noPosts')),
                ),
              )
            else
              ..._posts
                  .map(
                    (p) => _buildSocialCard(
                      p,
                      widget.institution,
                      primaryColor,
                      surfaceColor,
                    ),
                  )
                  .toList(),
          ],
        );
      case 2:
        final items = (d.colleges.isNotEmpty ? d.colleges : d.depts)
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        return _contentContainer(surfaceColor, [
          Text(
            _isUniversity
                ? S.of(context, 'colleges')
                : S.of(context, 'departments'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (it) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      it.trim(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ]);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSocialCard(
    Post p,
    Institution d,
    Color primaryColor,
    Color surfaceColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    d.nameForLang('en')[0].toUpperCase(),
                    style: TextStyle(color: primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.nameForLang(context.read<AppProvider>().language),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(p.formattedDate, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ]),
              ],
            ),
          ),
          if (p.image.isNotEmpty)
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: p.image,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.title.isNotEmpty)
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                if (p.title.isNotEmpty) const SizedBox(height: 8),
                Text(
                  p.content,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentContainer(Color surfaceColor, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color primaryColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Iconsax.arrow_left_2, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _shareInstitution(Institution d) {
    final name = d.nameForLang(context.read<AppProvider>().language);
    Share.share('$name\n${d.web}\n${d.phone}');
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openMap(Institution d) {
    if (d.lat != null && d.lng != null) {
      _launchUrl(
        'https://www.google.com/maps/search/?api=1&query=${d.lat},${d.lng}',
      );
    } else {
      final name = d.nameForLang('en');
      _launchUrl(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}',
      );
    }
  }
}
