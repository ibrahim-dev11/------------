import 'package:flutter/material.dart';

/// 3D-style icon widget — gradient square with layered shadows and an icon/emoji.
class App3DIcon extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final List<Color> gradientColors;
  final double size;
  final double iconSize;
  final double borderRadius;

  const App3DIcon({
    super.key,
    this.icon,
    this.emoji,
    required this.gradientColors,
    this.size = 64,
    this.iconSize = 30,
    this.borderRadius = 18,
  }) : assert(icon != null || emoji != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: gradientColors.first.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Highlight top-left
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: size * 0.4,
              height: size * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
          // Small decoration blob bottom-right
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Center icon
          Center(
            child: emoji != null
                ? Text(emoji!, style: TextStyle(fontSize: iconSize))
                : Icon(icon!, color: Colors.white, size: iconSize),
          ),
        ],
      ),
    );
  }
}

// ─── Preset icons ────────────────────────────────────────────────────────────

class InstitutionIcon extends StatelessWidget {
  final double size;
  const InstitutionIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.school_rounded,
        gradientColors: const [Color(0xFF7F77DD), Color(0xFF534AB7)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class CvIcon extends StatelessWidget {
  final double size;
  const CvIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.description_rounded,
        gradientColors: const [Color(0xFF25C28F), Color(0xFF1D9E75)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class TeacherIcon extends StatelessWidget {
  final double size;
  const TeacherIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.person_outline_rounded,
        gradientColors: const [Color(0xFFE8B84B), Color(0xFFD4A017)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class UniversityIcon extends StatelessWidget {
  final double size;
  const UniversityIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.account_balance_rounded,
        gradientColors: const [Color(0xFFF07BAE), Color(0xFFE05C8A)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class BookIcon extends StatelessWidget {
  final double size;
  const BookIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.menu_book_rounded,
        gradientColors: const [Color(0xFF6BA8F5), Color(0xFF3A7DD4)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class ContactIcon extends StatelessWidget {
  final double size;
  const ContactIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.phone_rounded,
        gradientColors: const [Color(0xFFFF8F5A), Color(0xFFE06B3A)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class StudentIcon extends StatelessWidget {
  final double size;
  const StudentIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.edit_note_rounded,
        gradientColors: const [Color(0xFF55C88A), Color(0xFF3AAD6E)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

class MessageIcon extends StatelessWidget {
  final double size;
  const MessageIcon({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => App3DIcon(
        icon: Icons.chat_bubble_rounded,
        gradientColors: const [Color(0xFF7F77DD), Color(0xFF534AB7)],
        size: size,
        iconSize: size * 0.46,
        borderRadius: size * 0.28,
      );
}

// ─── Large onboarding icons (with decorative blobs) ──────────────────────────

class OnboardingIcon extends StatelessWidget {
  final Widget icon;
  final List<Color> blobColors;
  const OnboardingIcon({
    super.key,
    required this.icon,
    required this.blobColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back blob
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0].withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors.last.withOpacity(0.2),
              ),
            ),
          ),
          // Small floating badge top-left
          Positioned(
            top: 20,
            left: 25,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: blobColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          // Small floating badge bottom-right
          Positioned(
            bottom: 22,
            right: 22,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: blobColors.last.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          // Main icon
          icon,
        ],
      ),
    );
  }
}
