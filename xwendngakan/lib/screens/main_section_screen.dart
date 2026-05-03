import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/light_gradient_background.dart';

class MainSectionScreen extends StatelessWidget {
  const MainSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: LightGradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Large Selection Cards
                  Expanded(
                    child: Column(
                      children: [
                        _buildSectionCard(
                          title: "بەشی زانکۆ و قوتابخانەکان",
                          icon: Iconsax.teacher,
                          color: Colors.blue.shade400,
                          onTap: () {
                            // Navigation logic
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: "بەشی CV Bank",
                          icon: Iconsax.briefcase,
                          color: Colors.purple.shade400,
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: "بەشی مامۆستاکانم",
                          icon: Iconsax.user_octagon,
                          color: Colors.green.shade400,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        _buildBottomButton("تۆمارکردن", isPrimary: true),
                        const SizedBox(height: 12),
                        _buildBottomButton("داواکاری مامۆستا", isPrimary: false),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(20),
          color: color,
          opacity: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppFont',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(String text, {required bool isPrimary}) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 15,
      opacity: isPrimary ? 1 : 0.5,
      color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
      showShadow: isPrimary,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'AppFont',
            color: isPrimary ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }
}
