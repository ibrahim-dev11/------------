import 'dart:convert';
import 'post_model.dart';
import 'package:xwendngakan_app/core/constants/app_constants.dart';

class InstitutionModel {
  final int id;
  final String? nku; // Kurdish name
  final String? nen; // English name
  final String? nar; // Arabic name
  final String? type;
  final String? country;
  final String? city;
  final String? web;
  final String? phone;
  final String? email;
  final String? addr;
  final String? desc;
  final double? lat;
  final double? lng;
  final String? colleges;
  final String? depts;
  final String? fb;
  final String? ig;
  final String? tg;
  final String? wa;
  final String? logo;
  final String? img;
  final String? video;
  final int? foundedYear;
  final int? studentsCount;
  final bool approved;
  final List<PostModel> posts;
  final String? createdAt;

  InstitutionModel({
    required this.id,
    this.nku,
    this.nen,
    this.nar,
    this.type,
    this.country,
    this.city,
    this.web,
    this.phone,
    this.email,
    this.addr,
    this.desc,
    this.lat,
    this.lng,
    this.colleges,
    this.depts,
    this.fb,
    this.ig,
    this.tg,
    this.wa,
    this.logo,
    this.img,
    this.video,
    this.foundedYear,
    this.studentsCount,
    this.approved = false,
    this.createdAt,
    this.posts = const [],
  });

  String name(String lang) {
    switch (lang) {
      case 'en':
        return nen ?? nku ?? nar ?? '';
      case 'ar':
        return nar ?? nku ?? nen ?? '';
      default:
        return nku ?? nen ?? nar ?? '';
    }
  }

  String get logoUrl {
    if (logo == null || logo!.isEmpty) return '';
    if (logo!.startsWith('http')) return logo!;
    
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final path = logo!.startsWith('/') ? logo! : '/$logo';
    
    if (!path.startsWith('/storage/')) {
      return '$baseDomain/storage$path';
    }
    return '$baseDomain$path';
  }

  String get imgUrl {
    if (img == null || img!.isEmpty) return '';
    if (img!.startsWith('http')) return img!;
    
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final path = img!.startsWith('/') ? img! : '/$img';
    
    if (!path.startsWith('/storage/')) {
      return '$baseDomain/storage$path';
    }
    return '$baseDomain$path';
  }

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] ?? 0,
      nku: json['nku'],
      nen: json['nen'],
      nar: json['nar'],
      type: json['type'],
      country: json['country'],
      city: json['city'],
      web: json['web'],
      phone: json['phone'],
      email: json['email'],
      addr: json['addr'],
      desc: json['desc'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      colleges: json['colleges'] is String ? json['colleges'] : jsonEncode(json['colleges']),
      depts: json['depts'] is String ? json['depts'] : jsonEncode(json['depts']),
      fb: json['fb'],
      ig: json['ig'],
      tg: json['tg'],
      wa: json['wa'],
      logo: json['logo'],
      img: json['img'],
      video: json['video'],
      foundedYear: json['founded_year'] != null
          ? (json['founded_year'] as num).toInt()
          : null,
      studentsCount: json['students_count'] != null
          ? (json['students_count'] as num).toInt()
          : null,
      approved: json['approved'] ?? false,
      createdAt: json['created_at'],
      posts: json['posts'] != null
          ? (json['posts'] as List).map((i) => PostModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nku': nku,
        'nen': nen,
        'nar': nar,
        'type': type,
        'country': country,
        'city': city,
        'web': web,
        'phone': phone,
        'email': email,
        'addr': addr,
        'desc': desc,
        'lat': lat,
        'lng': lng,
        'colleges': colleges,
        'depts': depts,
        'fb': fb,
        'ig': ig,
        'tg': tg,
        'wa': wa,
        'logo': logo,
        'img': img,
        'founded_year': foundedYear,
        'students_count': studentsCount,
        'approved': approved,
        'posts': posts.map((v) => v.toJson()).toList(),
      };
}
