import 'dart:convert';
import 'dart:io';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/institution.dart';
import '../models/stats.dart';
import '../models/notification_model.dart';
import '../data/constants.dart';
import '../data/institutions_data.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum SortMode { defaultSort, alpha, city }

class AppProvider extends ChangeNotifier {
  List<Institution> _db = [];
  String _currentTab = 'all';
  String _currentSub = '';
  String _searchQuery = '';
  String _filterType = '';
  String _filterCountry = '';
  String _filterCity = '';
  SortMode _sortMode = SortMode.defaultSort;
  bool _isDarkMode = false;
  String _language = 'ku'; // 'ku' = کوردی, 'ar' = عربی, 'en' = English
  int _nextId = 300;
  bool _isLoading = false;
  bool _isOnline = false;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;
  Stats? _stats;
  List<Map<String, dynamic>> _institutionTypes = [];
  List<NotificationModel> _notifications = [];
  int _unreadNotificationsCount = 0;

  bool _hasSelectedLanguage = false;
  bool _hasCompletedOnboarding = false;
  bool _isInitDone = false;
  int _displayLimit = 10;
  static const int _perPage = 10;

  AppProvider() {
    _init();
    NotificationService.onNotificationReceived = () {
      fetchNotifications();
    };
  }

  Future<void> _init() async {
    try {
      // Load saved language
      final prefs = await SharedPreferences.getInstance();
      
      if (prefs.containsKey('app_language')) {
        _language = prefs.getString('app_language') ?? 'ku';
        _hasSelectedLanguage = true;
      }

      // Load onboarding state
      _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

      // Load saved token
      await ApiService.loadToken();

      _isInitDone = true;
      notifyListeners();

      // Try to fetch from API, fall back to local data
      await fetchFromApi();

      // Get user if logged in
      if (ApiService.isLoggedIn) {
        _currentUser = await ApiService.getUser();
        await loadFavorites();
        await fetchNotifications();
      } else {
        // Load local favorites for guests
        await loadFavorites();
      }
    } catch (e) {
      debugPrint('Error during AppProvider init: $e');
      _isInitDone = true; // Still mark as done to let user into the app
    }
    notifyListeners();
  }

  Future<void> fetchFromApi() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final institutions = await ApiService.getInstitutions();
      if (institutions.isNotEmpty) {
        _db = institutions;
        _isOnline = true;
        // Cache to SQLite for offline use
        DatabaseService.cacheInstitutions(institutions).catchError((_) {});
        await fetchStats();
        await fetchAppData();
      } else {
        throw Exception('empty response');
      }
    } catch (e) {
      _isOnline = false;
      // Try SQLite cache first
      try {
        final cached = await DatabaseService.getCachedInstitutions();
        if (cached.isNotEmpty) {
          _db = cached;
        } else {
          // Last fallback: bundled static data
          _db = InstitutionsData.getAll();
          if (_db.isEmpty) {
            _hasError = true;
            _errorMessage = e.toString();
          }
        }
      } catch (_) {
        _db = InstitutionsData.getAll();
        if (_db.isEmpty) {
          _hasError = true;
          _errorMessage = e.toString();
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStats() async {
    try {
      final statsData = await ApiService.getStats();
      if (statsData.isNotEmpty) {
        _stats = Stats.fromJson(statsData);
        notifyListeners();
      }
    } catch (_) {
      // Ignore errors, will use fallback local counts
    }
  }

  Future<void> fetchAppData() async {
    try {
      final data = await ApiService.getAppData();
      final types = data['types'] ?? [];
      if (types.isNotEmpty) {
        _institutionTypes = types;
        notifyListeners();
      }
    } catch (_) {
      // Ignore errors, will use fallback constants
    }
  }

  // Getters
  List<Institution> get allInstitutions => _db;
  String get currentTab => _currentTab;
  String get currentSub => _currentSub;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterCountry => _filterCountry;
  String get filterCity => _filterCity;
  SortMode get sortMode => _sortMode;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get isRtl => _language == 'ku' || _language == 'ar';
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitDone => _isInitDone;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => ApiService.isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?['is_admin'] == true || _currentUser?['is_admin'] == 1;
  Stats? get stats => _stats;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  bool get hasUnreadNotifications => _unreadNotificationsCount > 0;

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ى', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ڕ', 'ر') // Optional: some users might search with or without overdots
        .replaceAll('ڵ', 'ل')
        .replaceAll('ۆ', 'و')
        .replaceAll('ێ', 'ی')
        .trim();
  }

  /// Pick the right localized value from a map based on current language.
  /// Looks for field_en, field_ar, or falls back to field (Kurdish).
  String localizedField(Map<String, dynamic> map, String field) {
    if (_language == 'en' || _language == 'tr' || _language == 'fr') {
      final v = map['${field}_en'] as String?;
      if (v != null && v.isNotEmpty) return v;
    } else if (_language == 'ar') {
      final v = map['${field}_ar'] as String?;
      if (v != null && v.isNotEmpty) return v;
    }
    return (map[field] as String?) ?? '';
  }
  List<Map<String, dynamic>> get institutionTypes => _institutionTypes;
  bool get hasInstitutionTypes => _institutionTypes.isNotEmpty;

  /// Build tab list from institution types for home screen.
  /// Simplified to 3 main groups as per user request.
  List<Map<String, dynamic>> get tabs {
    return [
      {'id': 'all', 'label': '📋 هەمووی', 'label_en': '📋 All', 'label_ar': '📋 الكل'},
      {'id': 'edu_min', 'label': '🏫 وەزارەتی پەروەردە', 'label_en': '🏫 Education', 'label_ar': '🏫 وزاره التربیه'},
      {'id': 'higher_ed', 'label': '🎓 خوێندنی باڵا', 'label_en': '🎓 Higher Ed', 'label_ar': '🎓 التعليم العالي'},
    ];
  }

  /// Get sub-tabs (category inside category) based on main tab selection.
  List<Map<String, dynamic>> get subTabs {
    if (_currentTab == 'edu_min') {
      return [
        {'id': 'all', 'label': '✨ هەمووی', 'label_en': 'All'},
        {'id': 'school', 'label': '🏫 قوتابخانە', 'label_en': 'Schools'},
        {'id': 'kg', 'label': '🧒 باخچەی منداڵان', 'label_en': 'KGs'},
        {'id': 'dc', 'label': '👶 دایەنگە', 'label_en': 'Daycare'},
        {'id': 'lang', 'label': '📖 سەنتەری زمان', 'label_en': 'Centers'},
        {'id': 'edu', 'label': '🏢 دامەزراوەی تر', 'label_en': 'Others'},
      ];
    } else if (_currentTab == 'higher_ed') {
      return [
        {'id': 'all', 'label': '✨ هەمووی', 'label_en': 'All'},
        {'id': 'gov', 'label': '🎓 زانکۆی حکومی', 'label_en': 'Gov Universities'},
        {'id': 'priv', 'label': '🏛️ زانکۆی تایبەت', 'label_en': 'Private Universities'},
        {'id': 'inst5', 'label': '📘 پەیمانگەی ٥ ساڵی', 'label_en': '5-Year Institutes'},
        {'id': 'inst2', 'label': '📗 پەیمانگەی ٢ ساڵی', 'label_en': '2-Year Institutes'},
      ];
    }
    return [];
  }

  /// Get localized type label for a given type key
  String typeLabel(String key) {
    if (_institutionTypes.isNotEmpty) {
      final t = _institutionTypes.where((t) => t['key'] == key).firstOrNull;
      if (t != null) return localizedField(t, 'name');
    }
    return AppConstants.typeLabels[key] ?? key;
  }

  /// Get localized type labels map
  Map<String, String> get localizedTypeLabels {
    if (_institutionTypes.isNotEmpty) {
      return {
        for (final t in _institutionTypes)
          t['key'] as String: localizedField(t, 'name'),
      };
    }
    return AppConstants.typeLabels;
  }

  // Filtered list
  List<Institution> get filteredInstitutions {
    var list = _db.where((d) => d.approved).where((d) {
      // Sub-category filter (Category inside Category)
      if (_currentSub.isNotEmpty) {
        if (d.type != _currentSub) return false;
      }
      
      // Main Tab filter (Groups)
      if (_currentTab != 'all') {
        if (_currentTab == 'edu_min') {
          // Ministry of Education types (only if no sub-tab selected)
          if (_currentSub.isEmpty) {
            final eduMinTypes = ['school', 'kg', 'dc', 'edu', 'lang'];
            if (!eduMinTypes.contains(d.type)) return false;
          }
        } else if (_currentTab == 'higher_ed') {
          // Higher Education types (only if no sub-tab selected)
          if (_currentSub.isEmpty) {
            final higherEdTypes = ['gov', 'priv', 'inst5', 'inst2', 'eve_uni', 'eve_inst'];
            if (!higherEdTypes.contains(d.type)) return false;
          }
        } else {
          // Direct type match fallback
          if (d.type != _currentTab) return false;
        }
      }
      // Type filter
      if (_filterType.isNotEmpty && d.type != _filterType) return false;
      // Country filter
      if (_filterCountry.isNotEmpty && d.country != _filterCountry) return false;
      // City filter
      if (_filterCity.isNotEmpty && d.city != _filterCity) return false;
      // Search
      if (_searchQuery.isNotEmpty) {
        final query = _normalize(_searchQuery);
        final haystack = _normalize('${d.nku} ${d.nen} ${d.nar} ${d.city} ${d.colleges} ${d.depts}');
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();

    // Sort
    switch (_sortMode) {
      case SortMode.alpha:
        list.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case SortMode.city:
        list.sort((a, b) => a.city.compareTo(b.city));
        break;
      case SortMode.defaultSort:
        break;
    }
    return list;
  }

  // Pagination
  List<Institution> get displayedInstitutions {
    final all = filteredInstitutions;
    if (_displayLimit >= all.length) return all;
    return all.sublist(0, _displayLimit);
  }

  bool get hasMoreToShow => filteredInstitutions.length > _displayLimit;

  int get displayedCount => displayedInstitutions.length;

  int get totalFilteredCount => filteredInstitutions.length;

  void loadMore() {
    _displayLimit += _perPage;
    notifyListeners();
  }

  void _resetDisplayLimit() {
    _displayLimit = _perPage;
  }

  // Stats
  int get totalApproved => _db.where((d) => d.approved).length;

  int countByType(String type) =>
      _db.where((d) => d.approved && d.type == type).length;

  int get totalCities =>
      _db.where((d) => d.approved).map((d) => d.city).toSet().length;

  int tabCount(String tabId) {
    // Use backend stats if available
    if (_stats != null && _isOnline) {
      switch (tabId) {
        case 'all':
          return _stats!.total;
        case 'universities':
          return _stats!.universities;
        case 'colleges':
          return _stats!.colleges;
        case 'institutes':
          return _stats!.institutes;
        case 'schools':
          return _stats!.schools;
        case 'gov':
          return _stats!.gov + _stats!.priv;
        case 'inst5':
          return _stats!.inst5;
        case 'inst2':
          return _stats!.inst2;
        case 'school':
          return _stats!.school;
        case 'kg':
          return _stats!.kg;
        case 'dc':
          return _stats!.dc;
      }
    }
    // Fallback to local counting
    if (tabId == 'all') return totalApproved;
    if (tabId == 'gov') {
      return _db
          .where(
              (d) => d.approved && (d.type == 'gov' || d.type == 'priv'))
          .length;
    }
    return countByType(tabId);
  }

  int subTabCount(String subId) {
    if (subId == 'gov_all') {
      return _db
          .where(
              (d) => d.approved && (d.type == 'gov' || d.type == 'priv'))
          .length;
    }
    if (subId == 'gov_gov') return countByType('gov');
    if (subId == 'gov_priv') return countByType('priv');
    if (subId == 'sch_all') return countByType('school');
    if (subId == 'sch_base') {
      return _db
          .where((d) =>
              d.approved &&
              d.type == 'school' &&
              d.nku.contains('بنەڕەتی'))
          .length;
    }
    if (subId == 'sch_prep') {
      return _db
          .where((d) =>
              d.approved &&
              d.type == 'school' &&
              d.nku.contains('ئامادەیی'))
          .length;
    }
    return 0;
  }

  // Actions
  void setTab(String tab) {
    _currentTab = tab;
    _currentSub = '';
    _resetDisplayLimit();
    notifyListeners();
  }

  void setSub(String sub) {
    _currentSub = sub;
    _resetDisplayLimit();
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    _resetDisplayLimit();
    notifyListeners();
  }

  void setFilterType(String t) {
    _filterType = t;
    _resetDisplayLimit();
    notifyListeners();
  }

  void setFilterCountry(String c) {
    _filterCountry = c;
    _filterCity = '';
    _resetDisplayLimit();
    notifyListeners();
  }

  void setFilterCity(String c) {
    _filterCity = c;
    _resetDisplayLimit();
    notifyListeners();
  }

  void setSort(SortMode m) {
    _sortMode = m;
    _resetDisplayLimit();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<void> setLanguageAndSave(String lang) async {
    _language = lang;
    _hasSelectedLanguage = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = '';
    _filterCountry = '';
    _filterCity = '';
    _currentTab = 'all';
    _currentSub = '';
    _sortMode = SortMode.defaultSort;
    _resetDisplayLimit();
    notifyListeners();
  }

  void addInstitution(Institution inst, {File? logoFile}) {
    inst.id = _nextId++;
    _db.add(inst);
    notifyListeners();

    // Sync with API (always try if logged in)
    if (ApiService.isLoggedIn) {
      ApiService.createInstitution(inst, logoFile: logoFile)
          .then((res) {
        debugPrint('Institution API response: $res');
        fetchFromApi();
      }).catchError((e) {
        debugPrint('Institution API error: $e');
      });
    }
  }

  void updateInstitution(Institution inst) {
    final idx = _db.indexWhere((d) => d.id == inst.id);
    if (idx >= 0) {
      _db[idx] = inst;
      notifyListeners();

      // Sync with API if online
      if (_isOnline && ApiService.isLoggedIn) {
        ApiService.updateInstitution(inst).then((_) => fetchFromApi());
      }
    }
  }

  void deleteInstitution(int id) {
    _db.removeWhere((d) => d.id == id);
    notifyListeners();

    // Sync with API if online
    if (_isOnline && ApiService.isLoggedIn) {
      ApiService.deleteInstitution(id);
    }
  }

  // ── Auth Methods ──

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await ApiService.login(email: email, password: password);
    if (result['success'] == true) {
      _currentUser = result['data']['user'];
      await fetchFromApi();
      await fetchNotifications();
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    if (result['success'] == true) {
      _currentUser = result['data']['user'];
      await fetchFromApi();
      await fetchNotifications();
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _currentUser = null;
    _favoriteIds.clear();
    _notifications = [];
    _unreadNotificationsCount = 0;
    notifyListeners();
  }

  Future<void> logoutUser() => logout();

  // ── Notifications ──

  Future<void> fetchNotifications() async {
    if (!ApiService.isLoggedIn) return;
    try {
      final list = await ApiService.getNotifications();
      _notifications = list.map((j) => NotificationModel.fromJson(j)).toList();
      _unreadNotificationsCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllNotificationsAsRead() async {
    if (!ApiService.isLoggedIn) return;
    final success = await ApiService.markAllNotificationsAsRead();
    if (success) {
      await fetchNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (!ApiService.isLoggedIn) return;
    final success = await ApiService.markNotificationAsRead(notificationId);
    if (success) {
      await fetchNotifications();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (!ApiService.isLoggedIn) return;
    try {
      final success = await ApiService.deleteNotification(notificationId);
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotificationsCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Nearby ──

  double? _userLat;
  double? _userLng;
  bool _isLoadingLocation = false;
  bool _locationDenied = false;

  double? get userLat => _userLat;
  double? get userLng => _userLng;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get locationDenied => _locationDenied;
  bool get hasLocation => _userLat != null && _userLng != null;

  /// Haversine formula – distance in km between two coordinates
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Get distance from user to institution (null if no coords)
  double? distanceTo(Institution inst) {
    if (_userLat == null || _userLng == null) return null;
    if (inst.lat == null || inst.lng == null || inst.lat == 0 || inst.lng == 0) return null;
    return _distanceKm(_userLat!, _userLng!, inst.lat!, inst.lng!);
  }

  /// Get nearby institutions sorted by distance (max 10)
  List<Institution> get nearbyInstitutions {
    if (!hasLocation) return [];
    final withDist = _db
        .where((d) => d.approved && d.lat != null && d.lng != null && d.lat != 0 && d.lng != 0)
        .map((d) => MapEntry(d, distanceTo(d)!))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return withDist.take(10).map((e) => e.key).toList();
  }

  /// Fetch user location via GPS
  Future<void> fetchUserLocation() async {
    if (_isLoadingLocation) return;
    _isLoadingLocation = true;
    _locationDenied = false;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationDenied = true;
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _locationDenied = true;
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _locationDenied = true;
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userLat = pos.latitude;
      _userLng = pos.longitude;
    } catch (_) {
      _locationDenied = true;
    }

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Set user location manually (from map picker)
  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
    _locationDenied = false;
    notifyListeners();
  }

  // ── Favorites ──

  Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;
  
  int get favoritesCount => _favoriteIds.length;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  List<Institution> get favoriteInstitutions =>
      _db.where((d) => _favoriteIds.contains(d.id)).toList();

  Future<void> loadFavorites() async {
    if (!ApiService.isLoggedIn) {
      // Load from local storage for guests
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('local_favorites') ?? [];
      _favoriteIds = ids.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0).toSet();
      notifyListeners();
      return;
    }

    try {
      final ids = await ApiService.getFavoriteIds();
      _favoriteIds = ids.toSet();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorite(int institutionId) async {
    final wasFavorite = _favoriteIds.contains(institutionId);

    // Optimistic update
    if (wasFavorite) {
      _favoriteIds.remove(institutionId);
    } else {
      _favoriteIds.add(institutionId);
    }
    notifyListeners();

    if (!ApiService.isLoggedIn) {
      // Save locally for guests
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'local_favorites',
        _favoriteIds.map((id) => id.toString()).toList(),
      );
      return;
    }

    try {
      final result = await ApiService.toggleFavorite(institutionId);
      if (result['success'] != true) {
        // Revert on failure
        if (wasFavorite) {
          _favoriteIds.add(institutionId);
        } else {
          _favoriteIds.remove(institutionId);
        }
        notifyListeners();
      }
    } catch (_) {
      // Revert on error
      if (wasFavorite) {
        _favoriteIds.add(institutionId);
      } else {
        _favoriteIds.remove(institutionId);
      }
      notifyListeners();
    }
  }

  Institution? getById(int id) {
    try {
      return _db.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  String exportToJson() {
    final approved = _db.where((d) => d.approved).toList();
    return jsonEncode(approved.map((d) => d.toJson()).toList());
  }

  int importFromJson(String jsonStr) {
    try {
      final List items = jsonDecode(jsonStr);
      int count = 0;
      for (var item in items) {
        final inst = Institution.fromJson(item);
        final exists =
            _db.any((d) => d.nku == inst.nku && d.city == inst.city);
        if (!exists) {
          inst.id = _nextId++;
          inst.approved = true;
          _db.add(inst);
          count++;
        }
      }
      notifyListeners();
      return count;
    } catch (_) {
      return -1;
    }
  }
}
