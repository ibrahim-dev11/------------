import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final notifications = prov.notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bgColor.withValues(alpha: 0.85),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkElevated.withValues(alpha: 0.7)
                  : AppTheme.lightSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppTheme.darkBorder.withValues(alpha: 0.5)
                    : AppTheme.lightBorder,
              ),
            ),
            child: Icon(
              Iconsax.arrow_left,
              color: isDark ? Colors.white : AppTheme.darkText,
              size: 18,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.notification_bing, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              S.of(context, 'notifications'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? Colors.white : AppTheme.darkText,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                prov.markAllNotificationsAsRead();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.tick_circle,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      S.of(context, 'markAllRead'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDark)
          : RefreshIndicator(
              onRefresh: () => prov.fetchNotifications(),
              color: AppTheme.primary,
              child: AnimationLimiter(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 450),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: _NotificationCard(notification: n),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return _NotifEmptyState(isDark: isDark);
  }
}

// ═══════════════════════════════════════════════════════
// ANIMATED EMPTY STATE
// ═══════════════════════════════════════════════════════
class _NotifEmptyState extends StatefulWidget {
  final bool isDark;
  const _NotifEmptyState({required this.isDark});
  @override
  State<_NotifEmptyState> createState() => _NotifEmptyStateState();
}

class _NotifEmptyStateState extends State<_NotifEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -6 * _floatCtrl.value),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: widget.isDark ? AppTheme.darkSurface : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Iconsax.notification_bing,
                size: 56,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context, 'noNotifications'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              S.of(context, 'notificationEmptyDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? AppTheme.textSecondary
                    : AppTheme.lightTextSub,
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
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        prov.deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
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
                ? (isDark ? AppTheme.darkSurface : Colors.white)
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
                      ? (isDark ? AppTheme.darkCard : AppTheme.lightBg)
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
                              color: isDark ? Colors.white : AppTheme.darkSurface,
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
