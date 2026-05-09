import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/teacher_model.dart';
import '../data/models/cv_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/app_constants.dart';

class TeachersProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TeacherModel> _teachers = [];
  List<int> _favorites = [];
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _selectedType = '';
  String _selectedCity = '';
  String _searchQuery = '';
  int _page = 1;

  List<TeacherModel> get teachers => _teachers;
  List<int> get favorites => _favorites;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get selectedType => _selectedType;

  List<TeacherModel> get favoriteTeachers =>
      _teachers.where((t) => _favorites.contains(t.id)).toList();

  TeachersProvider() {
    _loadFavorites();
    fetchTeachers(refresh: true);
  }

  static const _favKey = 'teacher_favorites';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favKey);
    if (raw != null) {
      _favorites = raw.split(',').where((e) => e.isNotEmpty).map(int.parse).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favKey, _favorites.join(','));
  }

  void toggleFavorite(int id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(int id) => _favorites.contains(id);

  Future<void> fetchTeachers({bool refresh = false}) async {
    if (_loading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _teachers = [];
    }
    if (!_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getTeachers(
      type: _selectedType,
      city: _selectedCity,
      search: _searchQuery,
      page: _page,
    );

    if (result.success && result.data != null) {
      final newItems = result.data!;
      if (refresh) {
        _teachers = newItems;
      } else {
        _teachers.addAll(newItems);
      }
      _hasMore = newItems.length >= AppConstants.pageSize;
      _page++;
    } else {
      _error = result.error;
    }

    _loading = false;
    notifyListeners();
  }

  void setFilter({String? type, String? city}) {
    _selectedType = type ?? _selectedType;
    _selectedCity = city ?? _selectedCity;
    fetchTeachers(refresh: true);
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchTeachers(refresh: true);
  }

  Future<bool> registerTeacher(Map<String, dynamic> form) async {
    final result = await _api.registerTeacher(form);
    if (result.success) {
      await fetchTeachers(refresh: true);
    }
    return result.success;
  }
}

class CvProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CvModel> _cvs = [];
  List<String> _educationLevels = [];
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _searchQuery = '';
  int _page = 1;

  List<CvModel> get cvs => _cvs;
  List<String> get educationLevels => _educationLevels;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  CvProvider() {
    fetchCvs(refresh: true);
    fetchEducationLevels();
  }

  Future<void> fetchCvs({bool refresh = false}) async {
    if (_loading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _cvs = [];
    }
    if (!_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getCvs(
      search: _searchQuery,
      page: _page,
    );

    if (result.success && result.data != null) {
      final newItems = result.data!;
      if (refresh) {
        _cvs = newItems;
      } else {
        _cvs.addAll(newItems);
      }
      _hasMore = newItems.length >= AppConstants.pageSize;
      _page++;
    } else {
      _error = result.error;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchEducationLevels() async {
    final result = await _api.getEducationLevels();
    if (result.success && result.data != null) {
      _educationLevels = result.data!;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchCvs(refresh: true);
  }

  Future<bool> submitCv(Map<String, dynamic> form) async {
    final result = await _api.submitCv(form);
    if (result.success) {
      await fetchCvs(refresh: true);
    }
    return result.success;
  }
}
