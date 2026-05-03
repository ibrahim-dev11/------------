import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/light_gradient_background.dart';

class ModernHomeScreen extends StatelessWidget {
  const ModernHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: LightGradientBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: _buildSearchBar(),
                  ),
                ),

                // Banner / Carousel Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildFeaturedBanner(),
                  ),
                ),

                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "زانکۆ و قوتابخانەکان",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AppFont',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 2,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        // Map Card
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 3,
                          child: _buildCategoryCard(
                            title: "نەخشە",
                            image: "https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?w=400", // Placeholder for map
                            isMap: true,
                          ),
                        ),
                        // Institutes
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1.5,
                          child: _buildCategoryCard(
                            title: "پەیمانگاکان",
                            icon: Iconsax.teacher,
                            iconColor: Colors.blue,
                          ),
                        ),
                        // My Teachers
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1.5,
                          child: _buildCategoryCard(
                            title: "مامۆستاکانم",
                            icon: Iconsax.user_octagon,
                            iconColor: Colors.orange,
                          ),
                        ),
                        // Integrated Ad Slot
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1.4,
                          child: _buildAdCard(),
                        ),
                        // Search by City
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1.4,
                          child: _buildCategoryCard(
                            title: "گەڕان بەدوای شارەکان",
                            icon: Iconsax.search_normal,
                            iconColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // University List Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Text(
                      "زانکۆی سەلاحەدین",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AppFont',
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),

                // University Card Example
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildUniversityItem(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 100,
      opacity: 0.9,
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "گەڕان بەدوای زانکۆ، پەیمانگا...",
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontFamily: 'AppFont',
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.black.withOpacity(0.4), size: 20),
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return GlassmorphicCard(
      padding: EdgeInsets.zero,
      borderRadius: 30,
      opacity: 1,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Image.network(
                  "https://images.unsplash.com/photo-1541339907198-e08756ebafe3?w=800", // University campus image
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Dynamic News",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "زانکۆی سەلاحەدین",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AppFont',
                      ),
                    ),
                    Text(
                      "گەڕان بەدوای زانکۆ و قوتابخانەکان",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'AppFont',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.arrow_right_1, color: Colors.blue, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    IconData? icon,
    Color? iconColor,
    String? image,
    bool isMap = false,
  }) {
    return GlassmorphicCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(image, fit: BoxFit.cover),
              ),
            ),
          if (icon != null)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'AppFont',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.monitor_mobbile, color: Colors.indigo, size: 32),
          const SizedBox(height: 8),
          const Text(
            "ڕیکلامی یەکگرتوو",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'AppFont',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityItem() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://images.unsplash.com/photo-1562774053-701939374585?w=200",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "زانکۆی سەلاحەدین - هەولێر",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AppFont',
                  ),
                ),
                Text(
                  "کۆنترین و گەورەترین زانکۆی حکومی",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'AppFont',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_left, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: GlassmorphicCard(
        borderRadius: 35,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        opacity: 0.95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Iconsax.home5, "سەرەکی", true),
            _buildNavItem(Iconsax.search_normal, "گەڕان", false),
            _buildNavItem(Iconsax.heart, "دڵخواز", false),
            _buildNavItem(Iconsax.user, "پڕۆفایل", false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.black.withOpacity(0.4),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'AppFont',
            color: isActive ? Colors.blue : Colors.black.withOpacity(0.4),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
