import '../services/api_service.dart';

class Institution {
  int id;
  String nku; // Kurdish name
  String nen; // English name
  String nar; // Arabic name
  String type;
  String country;
  String city;
  String web;
  String phone;
  String email;
  String addr;
  String desc;
  String colleges;
  String depts;
  // KG/DC fields
  String kgAge;
  String kgHours;
  // Social
  String fb;
  String ig;
  String tg;
  String wa;
  String tk;
  String yt;
  // Location
  double? lat;
  double? lng;
  // User mapping
  int? userId;
  // Images
  String logo;
  String img;
  bool approved;

  Institution({
    required this.id,
    this.nku = '',
    this.nen = '',
    this.nar = '',
    required this.type,
    this.country = '',
    this.city = '',
    this.web = '',
    this.phone = '',
    this.email = '',
    this.addr = '',
    this.desc = '',
    this.colleges = '',
    this.depts = '',
    this.kgAge = '',
    this.kgHours = '',
    this.fb = '',
    this.ig = '',
    this.tg = '',
    this.wa = '',
    this.tk = '',
    this.yt = '',
    this.lat,
    this.lng,
    this.logo = '',
    this.img = '',
    this.approved = false,
    this.userId,
  });

  factory Institution.empty() => Institution(id: 0, type: '');

  String get displayName => nku.isNotEmpty ? nku : nen;

  String nameForLang(String lang) {
    switch (lang) {
      case 'en':
        return nen.isNotEmpty ? nen : nku;
      case 'ar':
        return nar.isNotEmpty ? nar : nku;
      default:
        return nku.isNotEmpty ? nku : nen;
    }
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
        'colleges': colleges,
        'depts': depts,
        'kgAge': kgAge,
        'kgHours': kgHours,
        'fb': fb,
        'ig': ig,
        'tg': tg,
        'wa': wa,
        'tk': tk,
        'yt': yt,
        'lat': lat,
        'lng': lng,
        'logo': logo,
        'img': img,
        'approved': approved,
        'user_id': userId,
      };

  /// Build the server base URL (without /api)
  static String get _serverBase => ApiService.serverBase;

  /// Convert a relative storage path (e.g. /storage/logos/x.jpg) to full URL
  static String _resolveUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) {
      // For Android emulator, replace 127.0.0.1 with 10.0.2.2
      return path.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
    }
    return '$_serverBase${path.startsWith('/') ? '' : '/'}$path';
  }

  factory Institution.fromJson(Map<String, dynamic> j) => Institution(
        id: j['id'] ?? 0,
        nku: j['nku'] ?? '',
        nen: j['nen'] ?? '',
        nar: j['nar'] ?? '',
        type: j['type'] ?? 'edu',
        country: j['country'] ?? '',
        city: j['city'] ?? '',
        web: j['web'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        addr: j['addr'] ?? '',
        desc: j['desc'] ?? '',
        colleges: j['colleges'] ?? '',
        depts: j['depts'] ?? '',
        kgAge: j['kgAge'] ?? '',
        kgHours: j['kgHours'] ?? '',
        fb: j['fb'] ?? '',
        ig: j['ig'] ?? '',
        tg: j['tg'] ?? '',
        wa: j['wa'] ?? '',
        tk: j['tk'] ?? '',
        yt: j['yt'] ?? '',
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        logo: _resolveUrl(j['logo']),
        img: _resolveUrl(j['img']),
        approved: j['approved'] ?? false,
        userId: j['user_id'] != null ? int.tryParse(j['user_id'].toString()) : null,
      );
}
