import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xwendngakan_app/data/models/post_model.dart';
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
    String? sector,
    int page = 1,
  }) async {
    try {
      final query = {
        if (type != null && type.isNotEmpty) 'type': type,
        if (city != null && city.isNotEmpty) 'city': city,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sector != null && sector.isNotEmpty && sector != 'all') 'sector': sector,
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
        
        // Add mock for preview
        if (page == 1 && (search == null || search.isEmpty)) {
          list.insert(0, InstitutionModel(
            id: 999,
            nku: "ئەکادیمیای پایتەخت (Mock)",
            nen: "Capital Academy (Mock)",
            type: "university",
            city: "Hewlêr",
            logo: "https://images.unsplash.com/photo-1592280771190-3e2e4d571952?q=80&w=200&h=200&auto=format&fit=crop",
            approved: true,
          ));
        }
        
        return ApiResult.success(list);
      }
      return ApiResult.failure(data['message'] ?? 'Failed');
    } catch (e) {
      return ApiResult.failure('$e');
    }
  }

  Future<ApiResult<InstitutionModel>> getInstitution(int id) async {
    // Mock data for previewing design
    if (id == 999) {
      final mock = InstitutionModel(
        id: 999,
        nku: "ئەکادیمیای پایتەخت بۆ زانستەکان",
        nen: "Capital Academy for Sciences",
        nar: "أكاديمية العاصمة للعلوم",
        type: "university",
        city: "Hewlêr",
        country: "Kurdistan",
        phone: "07501234567",
        email: "info@capital-academy.edu.krd",
        web: "www.capital-academy.edu.krd",
        fb: "https://facebook.com",
        ig: "https://instagram.com",
        tg: "https://t.me",
        wa: "9647501234567",
        logo: "https://images.unsplash.com/photo-1592280771190-3e2e4d571952?q=80&w=200&h=200&auto=format&fit=crop",
        img: "https://images.unsplash.com/photo-1541339907198-e08756ebafe1?q=80&w=1200&h=800&auto=format&fit=crop",
        desc: "ئەم ئەکادیمیایە یەکێکە لە ناوەندە زانستییە پێشەنگەکان لە هەرێمی کوردستان، کە ئامانجی پێگەیاندنی نەوەیەکی کارامەیە لە بوارەکانی تەکنەلۆژیا، پزیشکی، و زانستە مرۆییەکان. بە بەکارهێنانی نوێترین پرۆگرامی خوێندن و تاقیگەی پێشکەوتوو، ئێمە داهاتوویەکی گەش بۆ خوێندکاران دابین دەکەین.",
        foundedYear: 2010,
        studentsCount: 12500,
        colleges: jsonEncode([
          {'name': 'College of Engineering', 'departments': ['Software Engineering', 'Civil Engineering', 'Mechatronics']},
          {'name': 'College of Medicine', 'departments': ['General Medicine', 'Pharmacy', 'Nursing']},
          {'name': 'College of Science', 'departments': ['Computer Science', 'Biology', 'Chemistry']},
        ]),
        posts: [
          PostModel(
            id: 1,
            institutionId: 999,
            title: "وەرگرتنی خوێندکاران بۆ ساڵی نوێ",
            content: "ئاگاداری هەموو خوێندکارانی ئازیز دەکەینەوە کە دەرگای وەرگرتن بۆ ساڵی خوێندنی ٢٠٢٤-٢٠٢٥ کراوەیە. دەتوانن لە ڕێگەی وێبسایتەکەمانەوە داواکاری پێشکەش بکەن.",
            image: "https://images.unsplash.com/photo-1523050853063-9158946122b2?q=80&w=800&h=500&auto=format&fit=crop",
            createdAt: "2024-05-10T10:00:00Z",
          ),
          PostModel(
            id: 2,
            institutionId: 999,
            title: "سیمینارێکی زانستی لەسەر ژیری دەستکرد",
            content: "ئەمڕۆ لە هۆڵی کۆنفرانسەکانی ئەکادیمیا، سیمینارێکی تایبەت بە پەرەپێدانی ژیری دەستکرد لە بواری پزیشکیدا بەڕێوەچوو بە بەشداری چەندین پسپۆڕی نێودەوڵەتی.",
            image: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=800&h=500&auto=format&fit=crop",
            createdAt: "2024-05-09T14:30:00Z",
          ),
        ],
      );
      return ApiResult.success(mock);
    }

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
    String? field,
    String? educationLevel,
    int page = 1,
  }) async {
    try {
      final query = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (city != null && city.isNotEmpty) 'city': city,
        if (field != null && field.isNotEmpty) 'field': field,
        if (educationLevel != null && educationLevel.isNotEmpty) 'education_level': educationLevel,
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

  Future<ApiResult<bool>> submitCv(Map<String, dynamic> form, {String? photoPath}) async {
    try {
      if (photoPath != null && photoPath.isNotEmpty) {
        var request = http.MultipartRequest('POST', Uri.parse('$_base/cvs'));
        
        final Map<String, String> multipartHeaders = Map.from(_headers());
        multipartHeaders.remove('Content-Type');
        request.headers.addAll(multipartHeaders);
        
        form.forEach((key, value) {
          if (value != null) request.fields[key] = value.toString();
        });
        
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
        
        var res = await request.send().timeout(AppConstants.receiveTimeout);
        var resData = await res.stream.bytesToString();
        var data = jsonDecode(resData) as Map<String, dynamic>;
        
        return data['success'] == true
            ? ApiResult.success(true)
            : ApiResult.failure(data['message'] ?? 'Failed');
      } else {
        final res = await http.post(
          Uri.parse('$_base/cvs'),
          headers: _headers(),
          body: jsonEncode(form),
        ).timeout(AppConstants.receiveTimeout);

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['success'] == true
            ? ApiResult.success(true)
            : ApiResult.failure(data['message'] ?? 'Failed');
      }
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

