import 'dart:ui';
import 'dart:math' as math;
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';

class InstitutionCard extends StatefulWidget {
  final Institution institution;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const InstitutionCard({
    super.key,
    required this.institution,
    required this.onTap,
    this.onEdit,
  });

  @override
  State<InstitutionCard> createState() => _InstitutionCardState();
}

class _InstitutionCardState extends State<InstitutionCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  late AnimationController _enterCtrl;
  late Animation<double> _enterAnim;
  late AnimationController _shimmerCtrl;
  bool _hovering = false;

  // Deterministic pseudo-rating derived from institution id
  double get _rating {
    final seed = widget.institution.id;
    return 3.5 + (seed * 7 % 15) / 10.0; // 3.5–5.0
  }

  int get _reviewCount {
    final seed = widget.institution.id;
    return 12 + (seed * 13 % 188); // 12–199
  }

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic),
    );

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutQuart);
    _enterCtrl.forward();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _enterCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Color get _typeAccent {
    final colors = AppConstants.typeGradients[widget.institution.type];
    return colors != null && colors.length > 1 ? colors[1] : AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCover = widget.institution.img.isNotEmpty;
    final prov = context.read<AppProvider>();
    final isRtl = prov.isRtl;
    final isFav = context.watch<AppProvider>().isFavorite(widget.institution.id);

    return FadeTransition(
      opacity: _enterAnim,
      child: GestureDetector(
        onTapDown: (_) {
          _scaleCtrl.forward();
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) => _scaleCtrl.reverse(),
        onTapCancel: () => _scaleCtrl.reverse(),
        onTap: widget.onTap,
        onLongPress: widget.onEdit,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: AppTheme.animNormal,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _hovering
                      ? AppTheme.primary.withValues(alpha: 0.4)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  width: _hovering ? 1.5 : 1,
                ),
                boxShadow: _hovering
                    ? AppTheme.premiumShadow(AppTheme.primary)
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Image Section ──
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image or placeholder
                          if (hasCover)
                            Hero(
                              tag: 'inst_img_${widget.institution.id}',
                              child: CachedNetworkImage(
                                imageUrl: widget.institution.img,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _AnimatedPlaceholder(
                                  isDark: isDark,
                                  shimmerCtrl: _shimmerCtrl,
                                ),
                                errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
                              ),
                            )
                          else
                            _buildPlaceholder(isDark),

                          // Gradient overlay – cinematic bottom fade
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.06),
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                  stops: const [0.0, 0.4, 0.65, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Top accent gradient – subtle colored glow
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _typeAccent.withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ── Type badge – frosted pill ──
                          Positioned(
                            top: 8,
                            left: isRtl ? null : 8,
                            right: isRtl ? 8 : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.15),
                                        Colors.white.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    prov.typeLabel(widget.institution.type),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Favorite button – animated ──
                          Positioned(
                            top: 8,
                            right: isRtl ? null : 8,
                            left: isRtl ? 8 : null,
                            child: _FavoriteButton(
                              isFav: isFav,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                prov.toggleFavorite(widget.institution.id);
                              },
                            ),
                          ),

                          // ── Bottom info overlay on image ──
                          if (widget.institution.approved)
                            Positioned(
                              bottom: 8,
                              right: isRtl ? null : 8,
                              left: isRtl ? 8 : null,
                              child: _VerifiedBadge(language: prov.language),
                            ),

                          // ── Logo avatar (if available) ──
                          if (widget.institution.logo.isNotEmpty)
                            Positioned(
                              bottom: 8,
                              left: isRtl ? null : 8,
                              right: isRtl ? 8 : null,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.institution.logo,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Icon(
                                      Iconsax.building_35,
                                      size: 14,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Info Section ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          widget.institution.nameForLang(prov.language),
                          maxLines: 1,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Location row
                        Row(
                          children: [
                            Icon(
                              Iconsax.location5,
                              size: 11,
                              color: _typeAccent.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.institution.city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ── Rating Row ──
                        _RatingRow(
                          rating: _rating,
                          reviewCount: _reviewCount,
                          accentColor: _typeAccent,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkCard, AppTheme.darkSurface]
              : [const Color(0xFFF7F8FC), const Color(0xFFEEEDF5)],
        ),
      ),
      child: Center(
        child: Icon(
          Iconsax.teacher,
          size: 32,
          color: _typeAccent.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ANIMATED SHIMMER PLACEHOLDER (while image loads)
// ═══════════════════════════════════════════════════════
class _AnimatedPlaceholder extends StatelessWidget {
  final bool isDark;
  final AnimationController shimmerCtrl;
  const _AnimatedPlaceholder({required this.isDark, required this.shimmerCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerCtrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * shimmerCtrl.value, -0.3),
              end: Alignment(-0.5 + 2.0 * shimmerCtrl.value, 0.3),
              colors: isDark
                  ? [
                      AppTheme.darkCard,
                      AppTheme.darkElevated.withValues(alpha: 0.8),
                      AppTheme.darkCard,
                    ]
                  : [
                      const Color(0xFFF0EEF5),
                      const Color(0xFFF8F7FC),
                      const Color(0xFFF0EEF5),
                    ],
            ),
          ),
          child: Center(
            child: Icon(
              Iconsax.teacher,
              size: 28,
              color: isDark
                  ? AppTheme.textHint.withValues(alpha: 0.3)
                  : AppTheme.lightTextSub.withValues(alpha: 0.2),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
// ANIMATED FAVORITE BUTTON
// ═══════════════════════════════════════════════════════
class _FavoriteButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;
  const _FavoriteButton({required this.isFav, required this.onTap});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFav != oldWidget.isFav && widget.isFav) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (_, child) => Transform.scale(
          scale: _bounce.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: AppTheme.animFast,
              curve: Curves.easeOutCubic,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.isFav
                    ? AppTheme.danger
                    : Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isFav
                      ? AppTheme.danger.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Icon(
                widget.isFav ? Iconsax.heart5 : Iconsax.heart,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// VERIFIED BADGE — animated appearance
// ═══════════════════════════════════════════════════════
class _VerifiedBadge extends StatelessWidget {
  final String language;
  const _VerifiedBadge({required this.language});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.success.withValues(alpha: 0.85),
                AppTheme.success,
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.verify5, size: 10, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                language == 'en' ? 'Verified' : 'پەسەند',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// RATING ROW — stars + count
// ═══════════════════════════════════════════════════════
class _RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Color accentColor;
  final bool isDark;

  const _RatingRow({
    required this.rating,
    required this.reviewCount,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stars
        ...List.generate(5, (i) {
          final fill = (rating - i).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(right: 1.5),
            child: SizedBox(
              width: 13,
              height: 13,
              child: Stack(
                children: [
                  Icon(
                    Iconsax.star1,
                    size: 13,
                    color: isDark
                        ? AppTheme.textHint.withValues(alpha: 0.3)
                        : AppTheme.lightTextSub.withValues(alpha: 0.2),
                  ),
                  ClipRect(
                    clipper: _StarClipper(fill),
                    child: Icon(
                      Iconsax.star1,
                      size: 13,
                      color: AppTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightText,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '($reviewCount)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: isDark ? AppTheme.textHint : AppTheme.lightTextSub,
          ),
        ),
      ],
    );
  }
}

// Custom clipper for partial star fill
class _StarClipper extends CustomClipper<Rect> {
  final double fill;
  _StarClipper(this.fill);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fill, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) => oldClipper.fill != fill;
}
