import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/institution_model.dart';
import '../models/teacher_model.dart';
import '../models/cv_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResult.success(this.data)
      : success = true,
        error = null;

  ApiResult.failure(this.error)
      : success = false,
        data = null;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _base = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return _headers(token: token);
  }

  // ==================
  // AUTH
  // ==================

  Future<ApiResult<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data);
      }
      return ApiResult.failure(data['message'] ?? 'Login failed');
    } catch (e) {
      return ApiResult.failure('Connection error: $e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> register(
      String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/register'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 && data['success'] == true) {
        return ApiResult.success(data);
      }
      return ApiResult.failure(data['message'] ?? 'Registration failed');
    } catch (e) {
      return ApiResult.failure('Connection error: $e');
    }
  }

  Future<ApiResult<bool>> logout() async {
    try {
      final headers = await _authHeaders();
      await http.post(
        Uri.parse('$_base/logout'),
        headers: headers,
      ).timeout(AppConstants.connectTimeout);
      return ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<UserModel>> getUser() async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(
        Uri.parse('$_base/user'),
        headers: headers,
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return ApiResult.success(UserModel.fromJson(data['data'] ?? data));
      }
      return ApiResult.failure(data['message'] ?? 'Failed to get user');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/forgot-password'),
        headers: _headers(),
        body: jsonEncode({'email': email}),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['success'] == true
          ? ApiResult.success(true)
          : ApiResult.failure(data['message']);
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> verifyResetCode(String email, String code) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/verify-reset-code'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'code': code}),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['success'] == true
          ? ApiResult.success(true)
          : ApiResult.failure(data['message']);
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> resetPassword(
      String email, String code, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/reset-password'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['success'] == true
          ? ApiResult.success(true)
          : ApiResult.failure(data['message']);
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // INSTITUTIONS
  // ==================

  Future<ApiResult<List<InstitutionModel>>> getInstitutions({
    String? type,
    String? city,
    String? search,
    int page = 1,
  }) async {
    try {
      final query = {
        if (type != null && type.isNotEmpty) 'type': type,
        if (city != null && city.isNotEmpty) 'city': city,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': '$page',
        'per_page': '${AppConstants.pageSize}',
      };

      final uri = Uri.parse('$_base/institutions').replace(queryParameters: query);
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => InstitutionModel.fromJson(e))
            .toList();
        return ApiResult.success(list);
      }
      return ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<InstitutionModel>> getInstitution(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/institutions/$id'),
        headers: _headers(),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(InstitutionModel.fromJson(data['data']));
      }
      return ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getStats() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/stats'),
        headers: _headers(),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as Map<String, dynamic>);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getAppData() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/app-data'),
        headers: _headers(),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as Map<String, dynamic>);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // TEACHERS
  // ==================

  Future<ApiResult<List<TeacherModel>>> getTeachers({
    String? type,
    String? city,
    String? search,
    int page = 1,
  }) async {
    try {
      final query = {
        if (type != null && type.isNotEmpty) 'type': type,
        if (city != null && city.isNotEmpty) 'city': city,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': '$page',
      };

      final uri = Uri.parse('$_base/teachers').replace(queryParameters: query);
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => TeacherModel.fromJson(e))
            .toList();
        return ApiResult.success(list);
      }
      return ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<TeacherModel>> getTeacher(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/teachers/$id'),
        headers: _headers(),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final raw = data['data'] as Map<String, dynamic>;
        return ApiResult.success(TeacherModel.fromJson(raw));
      }
      return ApiResult.failure(data['message'] ?? 'Not found');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> registerTeacher(Map<String, dynamic> form) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/teachers'),
        headers: _headers(),
        body: jsonEncode(form),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['success'] == true
          ? ApiResult.success(true)
          : ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // CV BANK
  // ==================

  Future<ApiResult<List<CvModel>>> getCvs({
    String? search,
    String? city,
    int page = 1,
  }) async {
    try {
      final query = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (city != null && city.isNotEmpty) 'city': city,
        'page': '$page',
      };

      final uri = Uri.parse('$_base/cvs').replace(queryParameters: query);
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => CvModel.fromJson(e))
            .toList();
        return ApiResult.success(list);
      }
      return ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> submitCv(Map<String, dynamic> form) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/cvs'),
        headers: _headers(),
        body: jsonEncode(form),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['success'] == true
          ? ApiResult.success(true)
          : ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<List<String>>> getEducationLevels() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/education-levels'),
        headers: _headers(),
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List).map((e) => e.toString()).toList();
        return ApiResult.success(list);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<CvModel>> getCv(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/cvs/$id'),
        headers: _headers(),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final raw = data['data'] as Map<String, dynamic>;
        return ApiResult.success(CvModel.fromJson(raw));
      }
      return ApiResult.failure(data['message'] ?? 'Not found');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // NOTIFICATIONS
  // ==================

  Future<ApiResult<List<Map<String, dynamic>>>> getNotifications() async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(
        Uri.parse('$_base/notifications'),
        headers: headers,
      ).timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return ApiResult.success(list);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<bool>> updateFcmToken(String token) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse('$_base/fcm-token'),
        headers: headers,
        body: jsonEncode({'fcm_token': token}),
      ).timeout(AppConstants.connectTimeout);

      return res.statusCode == 200
          ? ApiResult.success(true)
          : ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // NEWS
  // ==================

  Future<ApiResult<List<dynamic>>> getNews({int page = 1}) async {
    try {
      final uri = Uri.parse('$_base/news').replace(queryParameters: {'page': '$page'});
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as List);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<List<dynamic>>> getPosts({int page = 1, int perPage = 20}) async {
    try {
      final uri = Uri.parse('$_base/posts').replace(queryParameters: {
        'page': '$page',
        'per_page': '$perPage',
      });
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as List);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }



  // ==================
  // EVENTS
  // ==================

  Future<ApiResult<List<dynamic>>> getEvents({int page = 1}) async {
    try {
      final uri = Uri.parse('$_base/events').replace(queryParameters: {'page': '$page'});
      final res = await http.get(uri, headers: _headers())
          .timeout(AppConstants.receiveTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as List);
      }
      return ApiResult.failure('Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  // ==================
  // APP VERSION
  // ==================

  Future<ApiResult<Map<String, dynamic>>> checkUpdate(String platform, int build) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/check-update'),
        headers: _headers(),
        body: jsonEncode({
          'platform': platform,
          'build': build,
        }),
      ).timeout(AppConstants.connectTimeout);

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResult.success(data['data'] as Map<String, dynamic>);
      }
      return ApiResult.failure('Failed to check for updates');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }
}

