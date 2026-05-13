import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xwendngakan_app/core/localization/app_localizations.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_3d_icons.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedRole;
  late AnimationController _anim;
  late Animation<double> _fade;
  late List<Animation<Offset>> _staggeredSlides;

  List<_Role> _getLocalizedRoles(AppLocalizations l) {
    return [
      _Role(
        id: 'institution',
        title: l.institutions,
        subtitle: l.onboardingDesc1,
        icon: _RoleIconType.institution,
        isDefault: true,
      ),
      _Role(
        id: 'teacher',
        title: l.teachers,
        subtitle: l.registerAsTeacher,
        icon: _RoleIconType.teacher,
      ),
      _Role(
        id: 'cv_owner',
        title: l.cvBank,
        subtitle: l.onboardingDesc3,
        icon: _RoleIconType.cv,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedRole = 'institution';
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _staggeredSlides = List.generate(3, (index) {
      final start = 0.2 + (index * 0.1);
      final end = start + 0.4;
      return Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _anim,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutBack),
        ),
      );
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/onboarding');
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // ── Background Blobs with RepaintBoundary ──
            RepaintBoundary(
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -50,
                    child: _CircularBlob(
                      size: 300,
                      color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: _CircularBlob(
                      size: 250,
                      color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.12 : 0.05),
                    ),
                  ),
                ],
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => context.go('/onboarding'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l.help,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Rabar',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // ── Title Section ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _fade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.welcome,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontFamily: 'Rabar',
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l.onboardingDesc1, // Fallback to a descriptive string from l
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontFamily: 'Rabar',
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // ── Role Cards List ──
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final roles = _getLocalizedRoles(l);
                          final role = roles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: FadeTransition(
                              opacity: _fade,
                              child: SlideTransition(
                                position: _staggeredSlides[index],
                                child: _RoleCard(
                                  role: role,
                                  isSelected: _selectedRole == role.id,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedRole = role.id),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: 3,
                      ),
                    ),
                  ),

                  // ── Bottom Button ──
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FadeTransition(
                            opacity: _fade,
                            child: Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _selectedRole != null
                                    ? () {
                                        if (_selectedRole == 'cv_owner') {
                                          context.push('/cv-form');
                                        } else if (_selectedRole == 'teacher') {
                                          context.push('/teacher-register');
                                        } else {
                                          Provider.of<AuthProvider>(context, listen: false)
                                              .setSelectedRole(_selectedRole!);
                                          context.go('/login');
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l.next,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontFamily: 'Rabar',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                  ],
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
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _Role role;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
              : (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            _buildIcon(role.icon),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontFamily: 'Rabar',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontFamily: 'Rabar',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_RoleIconType type) {
    switch (type) {
      case _RoleIconType.student:
        return const StudentIcon(size: 56);
      case _RoleIconType.cv:
        return const CvIcon(size: 56);
      case _RoleIconType.teacher:
        return const TeacherIcon(size: 56);
      case _RoleIconType.institution:
        return const UniversityIcon(size: 56);
    }
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _GlassIconButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20),
          ),
        ),
      ),
    );
  }
}

class _CircularBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _CircularBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

enum _RoleIconType { student, cv, teacher, institution }

class _Role {
  final String id;
  final String title;
  final String subtitle;
  final _RoleIconType icon;
  final bool isDefault;

  const _Role({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDefault = false,
  });
}
