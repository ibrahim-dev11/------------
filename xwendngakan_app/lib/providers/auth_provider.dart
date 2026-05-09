import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  String? _token;
  String _selectedRole = 'institution';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  String? get token => _token;
  String get selectedRole => _selectedRole;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void setSelectedRole(String role) {
    _selectedRole = role;
  }

  final ApiService _api = ApiService();

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);

    if (_token != null) {
      final result = await _api.getUser();
      if (result.success && result.data != null) {
        _user = result.data;
        _status = AuthStatus.authenticated;
      } else {
        await _clearToken();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _api.login(email, password);

    if (result.success && result.data != null) {
      final inner = (result.data!['data'] ?? result.data!) as Map<String, dynamic>;
      _token = inner['token'] as String?;
      _user = UserModel.fromJson(inner['user'] as Map<String, dynamic>);

      await _saveToken(_token!);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _api.register(name, email, password);

    if (result.success && result.data != null) {
      final inner = (result.data!['data'] ?? result.data!) as Map<String, dynamic>;
      _token = inner['token'] as String?;
      _user = UserModel.fromJson(inner['user'] as Map<String, dynamic>);

      await _saveToken(_token!);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _clearToken();
    _user = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
