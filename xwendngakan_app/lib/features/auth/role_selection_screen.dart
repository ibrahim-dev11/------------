import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
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
  late Animation<Offset> _slide;

  static const _roles = <_Role>[
    _Role(
      id: 'institution',
      title: 'دامەزراوەکان',
      subtitle: 'گەڕان و بینینی باشترین دامەزراوەکان',
      icon: _RoleIconType.institution,
      isDefault: true,
    ),
    _Role(
      id: 'cv_owner',
      title: 'بەشی سیڤی',
      subtitle: 'نووسینی سیڤی بۆ پیشاندان بە دامەزراوەکان',
      icon: _RoleIconType.cv,
    ),
    _Role(
      id: 'teacher',
      title: 'مامۆستای تایبەتمەند',
      subtitle: 'خۆتۆمارکردن بۆ پیشاندان بە دامەزراوەکان',
      icon: _RoleIconType.teacher,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = 'institution';
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeIn));
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/onboarding');
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9),
        body: Stack(
          children: [
            // Elegant curved background header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D9E75), Color(0xFF25C28F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 150,
                      left: -40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/onboarding');
                                }
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      // Role list container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black38 : const Color(0xFF1D9E75).withOpacity(0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < _roles.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _RoleTile(
                                  role: _roles[i],
                                  isSelected: _selectedRole == _roles[i].id,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedRole = _roles[i].id),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Bottom button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: SizedBox(
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1D9E75), Color(0xFF25C28F)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1D9E75).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _selectedRole != null
                                  ? () {
                                      if (_selectedRole == 'cv_owner') {
                                        context.push('/cv-form');
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                _selectedRole == 'cv_owner' ? 'دروستکردنی سیڤی' : 'بەردەوامبە',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'NotoSansArabic',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _RoleTile extends StatelessWidget {
  final _Role role;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleTile({
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
        duration: AppConstants.fast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1D9E75).withOpacity(0.15) : const Color(0xFF1D9E75).withOpacity(0.08))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D9E75)
                : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(role.icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF1D9E75)
                          : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D9E75),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? Colors.white24 : Colors.black12,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_RoleIconType type) {
    switch (type) {
      case _RoleIconType.student:
        return const StudentIcon(size: 44);
      case _RoleIconType.cv:
        return const CvIcon(size: 44);
      case _RoleIconType.teacher:
        return const TeacherIcon(size: 44);
      case _RoleIconType.institution:
        return const UniversityIcon(size: 44);
    }
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
