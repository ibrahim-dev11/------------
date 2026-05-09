import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/institution_model.dart';
import '../data/models/institution_type_model.dart';
import '../data/services/api_service.dart';

class InstitutionsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<InstitutionModel> _institutions = [];
  List<InstitutionModel> _featured = [];
  List<int> _favorites = [];
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _selectedType = '';
  String _selectedCity = '';
  String _searchQuery = '';
  int _page = 1;
  Map<String, dynamic> _stats = {};
  List<InstitutionTypeModel> _institutionTypes = [];

  List<InstitutionModel> get institutions => _institutions;
  List<InstitutionModel> get featured => _featured;
  List<int> get favorites => _favorites;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get selectedType => _selectedType;
  String get selectedCity => _selectedCity;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get stats => _stats;
  List<InstitutionTypeModel> get institutionTypes => _institutionTypes;

  List<InstitutionModel> get favoriteInstitutions =>
      _institutions.where((i) => _favorites.contains(i.id)).toList();

  bool _initialized = false;

  InstitutionsProvider();

  /// بە پاش-فریمێک بخوێنرێت — لە initState یان addPostFrameCallback
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFavorites();
    fetchStats();
    fetchInstitutionTypes();
    fetchInstitutions(refresh: true);
  }

  Future<void> fetchInstitutions({bool refresh = false}) async {
    if (_loading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _institutions = [];
    }
    if (!_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getInstitutions(
      type: _selectedType,
      city: _selectedCity,
      search: _searchQuery,
      page: _page,
    );

    if (result.success && result.data != null) {
      final newItems = result.data!;
      if (refresh) {
        _institutions = newItems;
        _featured = newItems.take(5).toList();
      } else {
        // Prevent duplicates by checking IDs
        final existingIds = _institutions.map((i) => i.id).toSet();
        final uniqueNewItems = newItems.where((i) => !existingIds.contains(i.id)).toList();
        _institutions.addAll(uniqueNewItems);
      }
      _hasMore = newItems.length >= AppConstants.pageSize;
      _page++;
    } else {
      _error = result.error;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchStats() async {
    final result = await _api.getStats();
    if (result.success && result.data != null) {
      _stats = result.data!;
      notifyListeners();
    }
  }

  Future<void> fetchInstitutionTypes() async {
    final result = await _api.getAppData();
    if (result.success && result.data != null) {
      final List typesJson = result.data!['types'] ?? [];
      _institutionTypes = typesJson.map((e) => InstitutionTypeModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void setFilter({String? type, String? city}) {
    _selectedType = type ?? _selectedType;
    _selectedCity = city ?? _selectedCity;
    fetchInstitutions(refresh: true);
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchInstitutions(refresh: true);
  }

  void clearFilters() {
    _selectedType = '';
    _selectedCity = '';
    _searchQuery = '';
    fetchInstitutions(refresh: true);
  }

  bool isFavorite(int id) => _favorites.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.favoritesKey);
    if (raw != null) {
      _favorites = (jsonDecode(raw) as List).map((e) => e as int).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.favoritesKey, jsonEncode(_favorites));
  }
}
