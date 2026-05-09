import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    // Check current status
    final result = await Connectivity().checkConnectivity();
    _update(result);

    // Listen to changes
    _sub = Connectivity().onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline != wasOnline) notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
