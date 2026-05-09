import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      setState(() => _loading = false);
      return;
    }
    // Clear badge after frame is done to avoid setState-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NotificationsProvider>(context, listen: false).markAllRead();
      }
    });
    final r = await _api.getNotifications();
    if (!mounted) return;
    if (r.success && r.data != null) {
      setState(() { _notifications = r.data!; _loading = false; });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: !auth.isAuthenticated
          ? EmptyState(
              icon: Icons.notifications_none_outlined,
              message: l.loginToSeeNotifications,
              actionLabel: l.login,
              onAction: () => context.go('/login'),
            )
          : _loading
              ? _buildShimmer()
              : _notifications.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none_outlined,
                      message: l.noNotifications,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final notif = _notifications[i];
                          final data = notif['data'] as Map<String, dynamic>? ?? {};
                          final readAt = notif['read_at'];
                          final isRead = readAt != null;
                          return Container(
                            decoration: BoxDecoration(
                              color: isRead
                                  ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                                  : AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                              border: Border.all(
                                color: isRead
                                    ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                                    : AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isRead ? Icons.notifications_outlined : Icons.notifications_active_outlined,
                                  color: AppColors.primary, size: 22,
                                ),
                              ),
                              title: Text(
                                data['title'] ?? notif['type'] ?? 'Notification',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              subtitle: data['message'] != null
                                  ? Text(data['message'],
                                      style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansArabic'),
                                      maxLines: 2)
                                  : null,
                              trailing: !isRead
                                  ? Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary, shape: BoxShape.circle),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ShimmerBox(width: double.infinity, height: 72, borderRadius: AppConstants.radiusMd),
    ),
  );
}
