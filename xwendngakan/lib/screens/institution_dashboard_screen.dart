import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/institution.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'detail_screen.dart';

class InstitutionDashboardScreen extends StatefulWidget {
  final Institution? initialInstitution;
  final VoidCallback onInstitutionCreated;

  const InstitutionDashboardScreen({
    super.key,
    this.initialInstitution,
    required this.onInstitutionCreated,
  });

  @override
  State<InstitutionDashboardScreen> createState() => _InstitutionDashboardScreenState();
}

class _InstitutionDashboardScreenState extends State<InstitutionDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پڕۆفایلی دامەزراوەکەم'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Iconsax.building),
              text: 'دامەزراوە',
            ),
            Tab(
              icon: Icon(Iconsax.document_text),
              text: 'پۆستەکان',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Edit or Register
          widget.initialInstitution != null
              ? RegisterScreen(
                  institution: widget.initialInstitution!,
                  hideAppBar: true,
                )
              : RegisterScreen(
                  onSubmitted: widget.onInstitutionCreated,
                ),

          // Tab 2: Manage Posts (Show inside detail screen view)
          widget.initialInstitution != null
              ? DetailScreen(
                  institution: widget.initialInstitution!,
                )
              : _buildEmptyPostsState(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyPostsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.info_circle,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'سەرەتا دامەزراوەکەت زیاد بکە',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'دەبێت لە تابی (دامەزراوە) فۆڕمەکە پڕبکەیتەوە و دامەزراوەکەت تۆمار بکەیت پێش ئەوەی بتوانیت پۆست بکەیت.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('بڕۆ بۆ تۆمارکردن'),
            ),
          ],
        ),
      ),
    );
  }
}
