import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = prov.notifications;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          S.of(context, 'notifications'),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: isDark ? Colors.white : AppTheme.navy,
          ),
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            IconButton(
              onPressed: () => prov.markAllNotificationsAsRead(),
              icon: const Icon(Iconsax.tick_circle),
              tooltip: S.of(context, 'markAllRead'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDark)
          : RefreshIndicator(
              onRefresh: () => prov.fetchNotifications(),
              color: AppTheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return _NotificationCard(notification: n);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Iconsax.notification_bing,
              size: 70,
              color: AppTheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context, 'noNotifications'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.navy,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              S.of(context, 'notificationEmptyDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = notification.isRead;
    final prov = context.read<AppProvider>();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(Alignment.centerRight, isDark),
      secondaryBackground: _buildSwipeBackground(Alignment.centerLeft, isDark),
      onDismissed: (direction) => prov.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            prov.markAsRead(notification.id);
          }
          // Navigate to the post/institution
          NotificationService.handleNotificationData(notification.data);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isRead 
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : (isDark ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.primary.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isRead
                  ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                  : AppTheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isRead 
                      ? (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))
                      : AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  notification.isPost 
                      ? Iconsax.document_text 
                      : (isRead ? Iconsax.notification : Iconsax.notification_bing),
                  size: 24,
                  color: isRead ? Colors.grey[500] : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
                              color: isDark ? Colors.white : AppTheme.navy,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy/MM/dd HH:mm').format(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        Row(
                          children: [
                            if (notification.isPost)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Iconsax.arrow_left_1,
                                  size: 16,
                                  color: AppTheme.primary.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSwipeBackground(Alignment alignment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 24),
          ),
        ],
      ),
    );
  }
}
