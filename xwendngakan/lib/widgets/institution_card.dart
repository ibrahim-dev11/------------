import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xwendngakan/data/constants.dart';
import 'package:xwendngakan/theme/app_theme.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';
import 'glass_container.dart';

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

class _InstitutionCardState extends State<InstitutionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppConstants.typeGradients[widget.institution.type] ??
        [AppTheme.primary, AppTheme.accent];
    final emoji = AppConstants.typeEmojis[widget.institution.type] ?? '🏫';

    final hasCover = widget.institution.img.isNotEmpty;
    final hasLogo = widget.institution.logo.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Main Content Container ──
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Section
                      Expanded(
                        flex: 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasCover)
                              CachedNetworkImage(
                                imageUrl: widget.institution.img,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                errorWidget: (context, url, error) => Container(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.first.withOpacity(0.9),
                                      colors.last,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -20,
                                      right: -20,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Opacity(
                                        opacity: 0.15,
                                        child: Icon(Icons.school_rounded, size: 70, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Inner Shadow
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Info Section
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.institution.nameForLang(context.read<AppProvider>().language),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        height: 1.2,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded, size: 14, color: AppTheme.primary.withOpacity(0.8)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 11,
                                    color: AppTheme.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.institution.city,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                      ),
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

              // ── Floating Logo Pebble ──
              Positioned(
                top: 95, 
                left: 16,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: hasLogo
                        ? Container(
                            color: Colors.white,
                            child: CachedNetworkImage(
                              imageUrl: widget.institution.logo,
                              fit: BoxFit.contain,
                            )
                          )
                        : Container(
                            color: colors.first.withOpacity(0.1),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                  ),
                ),
              ),

              // ── Type Badge Top Right ──
              Positioned(
                top: 16,
                right: 16,
                child: GlassContainer(
                  blur: 12,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  glassColor: Colors.black.withOpacity(0.25),
                  borderColor: Colors.white.withOpacity(0.15),
                  child: Text(
                    context.read<AppProvider>().typeLabel(widget.institution.type),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              // ── Admin Edit Trigger ──
              if (widget.onEdit != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: widget.onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
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
