import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/institution_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/cv_model.dart';
import 'common_widgets.dart';

/// =====================
/// INSTITUTION CARD
/// =====================
class InstitutionCard extends StatelessWidget {
  final InstitutionModel institution;
  final String lang;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const InstitutionCard({
    super.key,
    required this.institution,
    required this.lang,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = AppColors.typeColor(institution.type);
    final institutionName = institution.name(lang);
    final typeLabel = AppConstants.institutionTypes[institution.type]?[lang] ??
        institution.type ??
        '';
    final emoji =
        AppConstants.institutionTypes[institution.type]?['emoji'] ?? '🏫';

    final hasPhone = institution.phone != null && institution.phone!.isNotEmpty;
    final hasWeb = institution.web != null && institution.web!.isNotEmpty;
    final hasSocial = [
      institution.fb,
      institution.ig,
      institution.tg,
      institution.wa
    ].any((s) => s != null && s.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : typeColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image or gradient
                    institution.imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: institution.imgUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _InstCardFallback(
                                typeColor: typeColor, emoji: emoji),
                          )
                        : _InstCardFallback(typeColor: typeColor, emoji: emoji),
                    // Dark gradient at bottom
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.3, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.72),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Type badge — top left
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: typeColor.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$emoji $typeLabel',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ),
                    ),
                    // Favorite — top right
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFFF4757).withOpacity(0.2)
                                : Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFavorite
                                  ? const Color(0xFFFF4757).withOpacity(0.5)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? const Color(0xFFFF4757)
                                : Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    // Name overlay — bottom
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: Text(
                        institutionName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'NotoSansArabic',
                          height: 1.3,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black87),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info section ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City
                    if (institution.city != null &&
                        institution.city!.isNotEmpty)
                      Row(children: [
                        Icon(Icons.location_on_rounded,
                            size: 11, color: typeColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            institution.city!,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isDark ? Colors.white60 : AppColors.textGrey,
                              fontFamily: 'NotoSansArabic',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),

                    const SizedBox(height: 6),

                    // Info badges row: phone / web / social
                    Row(children: [
                      if (hasPhone)
                        _InfoBadge(
                          icon: Icons.phone_rounded,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      if (hasWeb)
                        _InfoBadge(
                          icon: Icons.language_rounded,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                      if (hasSocial)
                        _InfoBadge(
                          icon: Icons.share_rounded,
                          color: const Color(0xFFE05C8A),
                          isDark: isDark,
                        ),
                    ]),

                    const Spacer(),

                    // CTA button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [typeColor, typeColor.withOpacity(0.78)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: typeColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'زانیاری زیاتر',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 11, color: Colors.white),
                        ],
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

// ── helpers ──────────────────────────────────────────────────────────────────

class _InstCardFallback extends StatelessWidget {
  final Color typeColor;
  final String emoji;
  const _InstCardFallback({required this.typeColor, required this.emoji});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [typeColor, typeColor.withOpacity(0.55)],
          ),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 46))),
      );
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  const _InfoBadge(
      {required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 5),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 12, color: color),
      );
}

/// =====================
/// INSTITUTION CARD - HORIZONTAL (for featured slider)
/// =====================
class FeaturedInstitutionCard extends StatelessWidget {
  final InstitutionModel institution;
  final String lang;
  final VoidCallback? onTap;

  const FeaturedInstitutionCard({
    super.key,
    required this.institution,
    required this.lang,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.typeColor(institution.type);
    final institutionName = institution.name(lang);
    final emoji =
        AppConstants.institutionTypes[institution.type]?['emoji'] ?? '🏫';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [typeColor, typeColor.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            if (institution.imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                child: CachedNetworkImage(
                  imageUrl: institution.imgUrl,
                  width: 240,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  errorWidget: (_, __, ___) => const SizedBox(),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    institutionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (institution.city != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 2),
                        Text(
                          institution.city!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'NotoSansArabic',
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
    );
  }
}

/// =====================
/// TEACHER CARD
/// =====================
class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final String lang;
  final VoidCallback? onTap;
  final VoidCallback? onContact;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.lang,
    this.onTap,
    this.onContact,
    this.isFavorite = false,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUniversity = teacher.type == 'university';
    final typeColor = isUniversity ? AppColors.primary : AppColors.success;
    final typeIcon = isUniversity ? Icons.account_balance_rounded : Icons.menu_book_rounded;
    
    final String typeLabel;
    if (teacher.subject != null && teacher.subject!.trim().isNotEmpty) {
      typeLabel = 'مامۆستای ${teacher.subject!.trim()}';
    } else if (teacher.typeLabel != null && teacher.typeLabel!.isNotEmpty) {
      typeLabel = teacher.typeLabel!;
    } else {
      typeLabel = isUniversity ? 'مامۆستای زانکۆ' : 'مامۆستای قوتابخانە';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern / Gradient Accent
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 80,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        typeColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Avatar Container
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: teacher.photoUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: teacher.photoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _avatarFallback(teacher.name, typeColor),
                                )
                              : _avatarFallback(teacher.name, typeColor),
                        ),
                        // Small verified badge or status dot
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1F2937) : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row (Name + Favorite)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                teacher.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                  fontFamily: 'NotoSansArabic',
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,                       // Header Row (Name + Favorite)
                        
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onFavorite,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isFavorite 
                                      ? const Color(0xFFFF4757).withOpacity(0.1) 
                                      : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFavorite ? const Color(0xFFFF4757) : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Type & City Tags
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(typeIcon, size: 12, color: typeColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    typeLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: typeColor,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (teacher.city != null && teacher.city!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 12, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Text(
                                      teacher.city!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                        fontFamily: 'NotoSansArabic',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Stats Row (Rating & Experience)
                        Row(
                          children: [
                            if (teacher.experienceYears != null) ...[
                              _buildStatItem(
                                icon: Icons.work_history_rounded,
                                iconColor: const Color(0xFF3B82F6),
                                text: '${teacher.experienceYears} ساڵ',
                                isDark: isDark,
                              ),
                              const SizedBox(width: 12),
                            ],
                            _buildStatItem(
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              text: '٤.٩ (١٢٠+)',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required Color iconColor, required String text, required bool isDark}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            fontFamily: 'NotoSansArabic',
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback(String name, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'NotoSansArabic',
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      final p1 = parts[0].replaceAll('.', '');
      final p2 = parts[1].replaceAll('.', '');
      return '${p1.isNotEmpty ? p1[0] : ''} ${p2.isNotEmpty ? p2[0] : ''}'.trim();
    }
    final p = name.replaceAll('.', '').trim();
    return p.isNotEmpty ? p[0] : '?';
  }
}

/// =====================
/// CV CARD
/// =====================
class CvCard extends StatelessWidget {
  final CvModel cv;
  final VoidCallback? onTap;

  const CvCard({super.key, required this.cv, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: cv.photoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: cv.photoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _initials(cv.name),
                      ),
                    )
                  : _initials(cv.name),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  if (cv.field != null)
                    Text(
                      cv.field!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (cv.city != null)
                        AppBadge(
                          text: cv.city!,
                          color: AppColors.info,
                          icon: Icons.location_on_outlined,
                        ),
                      if (cv.educationLevel != null)
                        AppBadge(
                          text: cv.educationLevel!,
                          color: AppColors.purple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.purple,
          fontFamily: 'NotoSansArabic',
        ),
      ),
    );
  }
}
