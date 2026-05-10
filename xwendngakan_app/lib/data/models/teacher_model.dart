import 'package:xwendngakan_app/core/constants/app_constants.dart';

class TeacherModel {
  final int id;
  final String name;
  final String? phone;
  final String? type;
  final String? city;
  final int? experienceYears;
  final int? hourlyRate;
  final String? subject;
  final String? about;
  final String? photo;
  final String? subjectPhoto;
  final bool isApproved;
  final String? typeLabel;
  final String? createdAt;
  final String? videoUrl;

  TeacherModel({
    required this.id,
    required this.name,
    this.phone,
    this.type,
    this.city,
    this.experienceYears,
    this.hourlyRate,
    this.subject,
    this.about,
    this.photo,
    this.subjectPhoto,
    this.isApproved = false,
    this.typeLabel,
    this.createdAt,
    this.videoUrl,
  });

  String get photoUrl {
    if (photo == null || photo!.isEmpty) return '';
    if (photo!.startsWith('http')) return photo!;
    
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final path = photo!.startsWith('/') ? photo! : '/$photo';
    
    if (!path.startsWith('/storage/')) {
      return '$baseDomain/storage$path';
    }
    return '$baseDomain$path';
  }

  String get subjectPhotoUrl {
    if (subjectPhoto == null || subjectPhoto!.isEmpty) return '';
    if (subjectPhoto!.startsWith('http')) return subjectPhoto!;
    
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final path = subjectPhoto!.startsWith('/') ? subjectPhoto! : '/$subjectPhoto';
    
    if (!path.startsWith('/storage/')) {
      return '$baseDomain/storage$path';
    }
    return '$baseDomain$path';
  }

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      type: json['type'],
      city: json['city'],
      experienceYears: json['experience_years'],
      hourlyRate: json['hourly_rate'],
      subject: json['subject'],
      about: json['about'],
      photo: json['photo'],
      subjectPhoto: json['subject_photo'],
      isApproved: json['is_approved'] ?? false,
      typeLabel: json['type_label'],
      createdAt: json['created_at'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'type': type,
    'city': city,
    'experience_years': experienceYears,
    'hourly_rate': hourlyRate,
    'subject': subject,
    'about': about,
    'photo': photo,
    'subject_photo': subjectPhoto,
    'is_approved': isApproved,
    'video_url': videoUrl,
  };
}
