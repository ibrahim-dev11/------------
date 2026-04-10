import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/institution.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import 'register_screen.dart';
import 'create_post_screen.dart';

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
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                  showTabs: false,
                )
              : RegisterScreen(
                  onSubmitted: widget.onInstitutionCreated,
                ),

          // Tab 2: Manage Posts (Post Management Interface)
          widget.initialInstitution != null
              ? _buildPostsManagementTab(isDark)
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
                color: AppTheme.primary.withOpacity(0.1),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildPostsManagementTab(bool isDark) {
    if (widget.initialInstitution == null) return const SizedBox();

    return FutureBuilder<List<Post>>(
      future: ApiService.getInstitutionPosts(widget.initialInstitution!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Post Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(institutionId: widget.initialInstitution!.id),
                      ),
                    );
                    if (result == true) setState(() {});
                  },
                  icon: const Icon(Iconsax.add_square),
                  label: Text(S.of(context, 'createPost')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (posts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Iconsax.document_text, size: 60, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(S.of(context, 'noPosts'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                ...posts.map((p) => _buildPostAdminCard(p, isDark)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostAdminCard(Post p, bool isDark) {
    return Dismissible(
      key: Key('post_${p.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(Alignment.centerRight, isDark),
      confirmDismiss: (direction) => _confirmDeletePost(p.id),
      onDismissed: (direction) {
        // Deletion is already handled by _confirmDeletePost if it returns true
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (p.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(p.image, width: 80, height: 80, fit: BoxFit.cover),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const Icon(Iconsax.image, color: Colors.grey),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title.isNotEmpty ? p.title : 'بێ ناونیشان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(p.formattedDate, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.edit, color: Colors.blue, size: 20),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                      institutionId: widget.initialInstitution!.id,
                      post: p,
                    ),
                  ),
                );
                if (result == true) setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Alignment alignment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
      ),
    );
  }

  Future<bool> _confirmDeletePost(int postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سڕینەوەی پۆست'),
        content: const Text('دڵنیایت دەتەوێت ئەم پۆستە بسڕیتەوە؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('نەخێر')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('بەڵێ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      final success = await ApiService.deletePost(postId);
      if (success && mounted) {
        AppSnackbar.success(context, 'پۆستەکە سڕایەوە');
        return true;
      }
    }
    return false;
  }
}
