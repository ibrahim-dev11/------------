import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../providers/auth_provider.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> loadUnread(AuthProvider auth) async {
    if (!auth.isAuthenticated) return;
    final result = await _api.getNotifications();
    if (result.success && result.data != null) {
      _unreadCount = result.data!
          .where((n) => n['read_at'] == null)
          .length;
      notifyListeners();
    }
  }

  void markAllRead() {
    _unreadCount = 0;
    notifyListeners();
  }
}
