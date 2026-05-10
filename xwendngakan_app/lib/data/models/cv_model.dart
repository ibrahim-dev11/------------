import 'package:xwendngakan_app/core/constants/app_constants.dart';

class CvModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? city;
  final int? age;
  final String? gender;
  final int? graduationYear;
  final String? field;
  final String? educationLevel;
  final String? experience;
  final String? skills;
  final String? languages;
  final String? notes;
  final String? photo;
  final bool isReviewed;
  final String? genderLabel;
  final String? createdAt;

  CvModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.city,
    this.age,
    this.gender,
    this.graduationYear,
    this.field,
    this.educationLevel,
    this.experience,
    this.skills,
    this.languages,
    this.notes,
    this.photo,
    this.isReviewed = false,
    this.genderLabel,
    this.createdAt,
  });

  String get photoUrl {
    if (photo == null || photo!.isEmpty) return '';
    if (photo!.startsWith('http')) return photo!;
    
    // Extract base domain from AppConstants.baseUrl (remove '/api' suffix)
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    
    // Ensure the path has a leading slash
    final path = photo!.startsWith('/') ? photo! : '/$photo';
    
    // Add /storage prefix if the backend didn't add it
    if (!path.startsWith('/storage/')) {
      return '$baseDomain/storage$path';
    }
    
    return '$baseDomain$path';
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender']?.toString(),
      graduationYear: json['graduation_year'] != null ? int.tryParse(json['graduation_year'].toString()) : null,
      field: json['field']?.toString(),
      educationLevel: json['education_level']?.toString(),
      experience: json['experience']?.toString(),
      skills: json['skills']?.toString(),
      languages: json['languages']?.toString(),
      notes: json['notes']?.toString(),
      photo: json['photo']?.toString(),
      isReviewed: json['is_reviewed'] == true || json['is_reviewed'] == 1 || json['is_reviewed'] == '1',
      genderLabel: json['gender_label']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'city': city,
    'age': age,
    'gender': gender,
    'graduation_year': graduationYear,
    'field': field,
    'education_level': educationLevel,
    'experience': experience,
    'skills': skills,
    'languages': languages,
    'notes': notes,
  };
}

class AppStatsModel {
  final int institutions;
  final int teachers;
  final int cvs;
  final int cities;

  AppStatsModel({
    required this.institutions,
    required this.teachers,
    required this.cvs,
    required this.cities,
  });

  factory AppStatsModel.fromJson(Map<String, dynamic> json) {
    return AppStatsModel(
      institutions: json['institutions'] ?? 0,
      teachers: json['teachers'] ?? 0,
      cvs: json['cvs'] ?? 0,
      cities: json['cities'] ?? 0,
    );
  }
}
