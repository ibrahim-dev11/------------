import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/institution.dart';
import '../models/post.dart';

class ApiService {
  // ── Configuration ──
  // بۆ گۆڕینی سێرڤەر: تەنها ئەم دوو هێڵە بگۆڕە
  static const String _host = '127.0.0.1';
  static const int _port = 8000;
  static const bool _useHttps = false;

  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    final scheme = _useHttps ? 'https' : 'http';
    return '$scheme://$_host:$_port/api';
  }

  static String get serverBase {
    final scheme = _useHttps ? 'https' : 'http';
    return '$scheme://$_host:$_port';
  }

  static String? _token;

  // ── Token Management ──

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    ).timeout(_timeout);
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 && data['success'] == true) {
      await saveToken(data['data']['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(_timeout);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      await saveToken(data['data']['token']);
    }
    return data;
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _headers,
      );
    } catch (_) {}
    await clearToken();
  }

  static Future<Map<String, dynamic>?> getUser() async {
    if (_token == null) return null;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
      // Token expired or invalid
      if (res.statusCode == 401) {
        await clearToken();
      }
    } catch (_) {}
    return null;
  }

  // ── Institutions ──

  static Future<List<Institution>> getInstitutions({
    String? type,
    String? city,
    String? search,
    String sort = 'newest',
  }) async {
    final params = <String, String>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;
    params['sort'] = sort;

    final uri = Uri.parse('$baseUrl/institutions').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers).timeout(_timeout);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List items = data['data'];
      return items.map((j) => Institution.fromJson(j)).toList();
    }
    return [];
  }

  static Future<Institution?> getInstitution(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/institutions/$id'),
      headers: _headers,
    ).timeout(_timeout);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Institution.fromJson(data['data']);
    }
    return null;
  }

  static Future<Map<String, dynamic>> createInstitution(
    Institution inst, {
    File? logoFile,
    File? imgFile,
  }) async {
    final uri = Uri.parse('$baseUrl/institutions');
    final request = http.MultipartRequest('POST', uri);

    // If update, Laravel needs _method=PUT to handle multipart
    if (inst.id != 0) {
      request.fields['_method'] = 'PUT';
    }

    // Add auth header
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.headers['Accept'] = 'application/json';

    // Add all text fields
    final json = inst.toJson();
    json.remove('logo'); // Don't send absolute path or server url
    json.remove('img');
    json.forEach((key, value) {
      request.fields[key] = value?.toString() ?? '';
    });

    // Add logo file if provided
    if (logoFile != null && await logoFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('logo', logoFile.path),
      );
    }
    
    // Add institution image if provided
    if (imgFile != null && await imgFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('img', imgFile.path),
      );
    }

    final streamedRes = await request.send().timeout(const Duration(seconds: 30));
    final resBody = await streamedRes.stream.bytesToString();
    return jsonDecode(resBody);
  }

  static Future<Map<String, dynamic>> updateInstitution(Institution inst) async {
    final res = await http.put(
      Uri.parse('$baseUrl/institutions/${inst.id}'),
      headers: _headers,
      body: jsonEncode(inst.toJson()),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<bool> deleteInstitution(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/institutions/$id'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/stats'),
      headers: _headers,
    ).timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    // Deprecated — use getAppData() instead
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInstitutionTypes() async {
    // Deprecated — use getAppData() instead
    return [];
  }

  /// Unified endpoint: returns { types: [...] }
  static Future<Map<String, List<Map<String, dynamic>>>> getAppData() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/app-data'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final List types = data['types'] ?? [];
        return {
          'types': types.map((t) => Map<String, dynamic>.from(t)).toList(),
        };
      }
    } catch (_) {}
    return {'types': []};
  }

  // ── Pagination Support ──

  static Future<Map<String, dynamic>> getInstitutionsPaginated({
    String? type,
    String? city,
    String? search,
    String sort = 'newest',
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;
    params['sort'] = sort;

    final uri = Uri.parse('$baseUrl/institutions').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers).timeout(_timeout);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List items = data['data'];
      return {
        'institutions': items.map((j) => Institution.fromJson(j)).toList(),
        'meta': data['meta'],
      };
    }
    return {'institutions': [], 'meta': null};
  }

  // ── Favorites ──

  static Future<List<Institution>> getFavorites() async {
    if (_token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        final List items = jsonDecode(res.body)['data'];
        return items.map((j) => Institution.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<int>> getFavoriteIds() async {
    if (_token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/favorites/ids'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        final List ids = jsonDecode(res.body)['data'];
        return ids.map((id) => id as int).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> toggleFavorite(int institutionId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites/$institutionId/toggle'),
      headers: _headers,
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<bool> addFavorite(int institutionId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites/$institutionId'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 201;
  }

  static Future<bool> removeFavorite(int institutionId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/favorites/$institutionId'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }

  // ── Password Reset ──

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/verify-reset-code'),
      headers: _headers,
      body: jsonEncode({'email': email, 'code': code}),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    ).timeout(_timeout);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      await saveToken(data['data']['token']);
    }
    return data;
  }

  // ── Reports ──

  static Future<List<Map<String, dynamic>>> getReportTypes() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/report-types'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        final List types = jsonDecode(res.body)['data'];
        return types.map((t) => Map<String, dynamic>.from(t)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> reportInstitution({
    required int institutionId,
    required String type,
    String? description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/institutions/$institutionId/report'),
      headers: _headers,
      body: jsonEncode({
        'type': type,
        'description': description,
      }),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  // ── App Version / Force Update ──

  static Future<Map<String, dynamic>> checkUpdate({
    required String platform,
    required int buildNumber,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/check-update'),
        headers: _headers,
        body: jsonEncode({
          'platform': platform,
          'build': buildNumber,
        }),
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return {'update_available': false, 'force_update': false};
  }

  // ── FCM Token ──

  static Future<bool> updateFcmToken(String fcmToken) async {
    if (_token == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: _headers,
        body: jsonEncode({'fcm_token': fcmToken}),
      ).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>> toggleNotifications() async {
    final res = await http.post(
      Uri.parse('$baseUrl/toggle-notifications'),
      headers: _headers,
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  // ── Posts ──

  /// Get posts for a specific institution
  static Future<List<Post>> getInstitutionPosts(int institutionId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/institutions/$institutionId/posts'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        final List items = jsonDecode(res.body)['data'] ?? [];
        return items.map((j) => Post.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Create a post for an institution
  static Future<Map<String, dynamic>> createPost({
    required int institutionId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/institutions/$institutionId/posts');
    final request = http.MultipartRequest('POST', uri);

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = title;
    request.fields['content'] = content;

    if (imageFile != null && await imageFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedRes = await request.send().timeout(const Duration(seconds: 30));
    final resBody = await streamedRes.stream.bytesToString();
    return jsonDecode(resBody);
  }

  /// Update a post
  static Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  /// Delete a post
  static Future<bool> deletePost(int postId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }

  // ── Admin Posts ──

  /// Get all posts (admin)
  static Future<List<Post>> getAllPosts({bool? approved}) async {
    try {
      final params = <String, String>{};
      if (approved != null) params['approved'] = approved ? '1' : '0';

      final uri = Uri.parse('$baseUrl/admin/posts').replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode == 200) {
        final List items = jsonDecode(res.body)['data'] ?? [];
        return items.map((j) => Post.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Approve/reject a post (admin)
  static Future<Map<String, dynamic>> togglePostApproval(int postId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/posts/$postId/toggle-approval'),
      headers: _headers,
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  // ── CV ──

  /// Submit a CV
  static Future<Map<String, dynamic>> submitCv({
    required String name,
    required String phone,
    String? email,
    required String city,
    int? age,
    String? gender,
    String? graduationYear,
    required String field,
    String? educationLevel,
    String? experience,
    String? skills,
    String? notes,
    File? photo,
  }) async {
    final uri = Uri.parse('$baseUrl/cvs');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';

    // Map gender values from Kurdish to English
    String? mappedGender;
    if (gender != null) {
      switch (gender) {
        case 'نێر':
          mappedGender = 'male';
          break;
        case 'مێ':
          mappedGender = 'female';
          break;
        case 'تر':
          mappedGender = 'other';
          break;
      }
    }

    // Add all fields
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    request.fields['city'] = city;
    if (age != null) request.fields['age'] = age.toString();
    if (mappedGender != null) request.fields['gender'] = mappedGender;
    if (graduationYear != null && graduationYear.isNotEmpty) {
      request.fields['graduation_year'] = graduationYear;
    }
    request.fields['field'] = field;
    if (educationLevel != null && educationLevel.isNotEmpty) {
      request.fields['education_level'] = educationLevel;
    }
    if (experience != null && experience.isNotEmpty) {
      request.fields['experience'] = experience;
    }
    if (skills != null && skills.isNotEmpty) request.fields['skills'] = skills;
    if (notes != null && notes.isNotEmpty) request.fields['notes'] = notes;

    // Add photo if provided
    if (photo != null && await photo.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );
    }

    try {
      final streamedRes = await request.send().timeout(const Duration(seconds: 30));
      final resBody = await streamedRes.stream.bytesToString();
      return jsonDecode(resBody);
    } catch (e) {
      return {'success': false, 'message': 'هەڵەیەک ڕوویدا: $e'};
    }
  }

  /// Get all CVs with optional filters
  static Future<List<Map<String, dynamic>>> getCvs({
    String? city,
    String? field,
    String? educationLevel,
    String? search,
  }) async {
    try {
      final params = <String, String>{};
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (field != null && field.isNotEmpty) params['field'] = field;
      if (educationLevel != null && educationLevel.isNotEmpty) {
        params['education_level'] = educationLevel;
      }
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse('$baseUrl/cvs').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );
      final res = await http.get(uri, headers: _headers).timeout(_timeout);

      if (res.statusCode == 200) {
        final List items = jsonDecode(res.body)['data'] ?? [];
        return items.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Get CV details
  static Future<Map<String, dynamic>?> getCv(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/cvs/$id'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return null;
  }

  /// Get CV stats
  static Future<Map<String, dynamic>> getCvStats() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/cv-stats'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return {};
  }

  // ── Institution Requests ──
  static Future<Map<String, dynamic>?> getInstitutionRequestStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/my-institution-request'), headers: _headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return null;
  }

  static Future<Institution?> getMyInstitution() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/my-institution'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if (data != null) {
          return Institution.fromJson(data);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearInstitutionRequest() async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/institution-requests/clear'),
        headers: _headers,
      ).timeout(_timeout);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> submitInstitutionRequest({
    required String name,
    required String phone,
    required String message,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/institution-requests'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'message': message,
        }),
      ).timeout(_timeout);
      return jsonDecode(res.body);
    } catch (_) {}
    return {'success': false};
  }

  // ── Teachers ──

  static Future<Map<String, dynamic>?> getTeacherRequestStatus() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/my-teacher-request'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearTeacherRequest() async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/teacher-requests/clear'),
        headers: _headers,
      ).timeout(_timeout);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> submitTeacherRequest({
    required String name,
    required String phone,
    String? message,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/teacher-requests'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'message': message,
        }),
      ).timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'هەڵەیەک ڕوویدا: $e'};
    }
  }

  /// Submit a teacher registration
  static Future<Map<String, dynamic>> submitTeacher({
    required String name,
    required String phone,
    required String type,
    required String city,
    int? experienceYears,
    int? hourlyRate,
    String? about,
    File? photo,
    File? subjectPhoto,
  }) async {
    final uri = Uri.parse('$baseUrl/teachers');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['type'] = type;
    request.fields['city'] = city;
    if (experienceYears != null) {
      request.fields['experience_years'] = experienceYears.toString();
    }
    if (hourlyRate != null) {
      request.fields['hourly_rate'] = hourlyRate.toString();
    }
    if (about != null && about.isNotEmpty) request.fields['about'] = about;

    if (photo != null && await photo.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );
    }

    if (subjectPhoto != null && await subjectPhoto.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('subject_photo', subjectPhoto.path),
      );
    }

    try {
      final streamedRes = await request.send().timeout(const Duration(seconds: 30));
      final resBody = await streamedRes.stream.bytesToString();
      return jsonDecode(resBody);
    } catch (e) {
      return {'success': false, 'message': 'هەڵەیەک ڕوویدا: $e'};
    }
  }

  /// Get all teachers with optional filters
  static Future<List<Map<String, dynamic>>> getTeachers({
    String? type,
    String? city,
    String? search,
  }) async {
    try {
      final params = <String, String>{};
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse('$baseUrl/teachers').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );
      final res = await http.get(uri, headers: _headers).timeout(_timeout);

      if (res.statusCode == 200) {
        final List items = jsonDecode(res.body)['data'] ?? [];
        return items.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Get teacher stats
  static Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/teacher-stats'),
        headers: _headers,
      ).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (_) {}
    return {};
  }

  // ── Admin: Institutions ──

  static Future<Map<String, dynamic>> getAdminInstitutions({String status = 'pending'}) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/institutions')
          .replace(queryParameters: {'status': status});
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List items = body['data'] ?? [];
        return {
          'institutions': items.map((j) => Institution.fromJson(j)).toList(),
          'meta': body['meta'] ?? {},
        };
      }
    } catch (_) {}
    return {'institutions': [], 'meta': {}};
  }

  static Future<Map<String, dynamic>> toggleInstitutionApproval(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/institutions/$id/toggle-approval'),
      headers: _headers,
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<bool> adminDeleteInstitution(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/institutions/$id'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }

  // ── Admin: Reports ──

  static Future<Map<String, dynamic>> getAdminReports({String status = 'pending'}) async {
    try {
      final params = status == 'all' ? <String, String>{} : {'status': status};
      final uri = Uri.parse('$baseUrl/admin/reports')
          .replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {
          'reports': List<Map<String, dynamic>>.from(
              (body['data'] as List).map((e) => Map<String, dynamic>.from(e))),
          'meta': body['meta'] ?? {},
        };
      }
    } catch (_) {}
    return {'reports': [], 'meta': {}};
  }

  static Future<Map<String, dynamic>> updateReportStatus(int id, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/reports/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<bool> deleteReport(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/reports/$id'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }

  // ── Admin: CVs ──

  static Future<Map<String, dynamic>> getAdminCvs({String? reviewed}) async {
    try {
      final params = <String, String>{};
      if (reviewed != null) params['reviewed'] = reviewed;
      final uri = Uri.parse('$baseUrl/admin/cvs')
          .replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {
          'cvs': List<Map<String, dynamic>>.from(
              (body['data'] as List).map((e) => Map<String, dynamic>.from(e))),
          'meta': body['meta'] ?? {},
        };
      }
    } catch (_) {}
    return {'cvs': [], 'meta': {}};
  }

  static Future<Map<String, dynamic>> toggleCvReview(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/cvs/$id/toggle-review'),
      headers: _headers,
    ).timeout(_timeout);
    return jsonDecode(res.body);
  }

  static Future<bool> adminDeleteCv(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/cvs/$id'),
      headers: _headers,
    ).timeout(_timeout);
    return res.statusCode == 200;
  }
}

