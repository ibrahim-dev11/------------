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
    this.notes,
    this.photo,
    this.isReviewed = false,
    this.genderLabel,
    this.createdAt,
  });

  static const _baseUrl = 'http://localhost:8000';

  String get photoUrl {
    if (photo == null || photo!.isEmpty) return '';
    if (photo!.startsWith('http')) return photo!;
    return '$_baseUrl$photo';
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      age: json['age'],
      gender: json['gender'],
      graduationYear: json['graduation_year'],
      field: json['field'],
      educationLevel: json['education_level'],
      experience: json['experience'],
      skills: json['skills'],
      notes: json['notes'],
      photo: json['photo'],
      isReviewed: json['is_reviewed'] ?? false,
      genderLabel: json['gender_label'],
      createdAt: json['created_at'],
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
