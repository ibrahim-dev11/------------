class AppConstants {
  AppConstants._();

  // === API ===
  static const String baseUrl = 'http://192.168.7.164:8001/api';
  // For Android Emulator: 'http://10.0.2.2:8001/api'
  // Production: 'https://your-domain.com/api'

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // === STORAGE KEYS ===
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String langKey = 'app_language';
  static const String langSelectedKey = 'lang_selected';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_done';
  static const String favoritesKey = 'favorites';

  // === DEFAULTS ===
  static const String defaultLang = 'ku';
  static const int pageSize = 15;

  // === LANGUAGES ===
  static const Map<String, Map<String, String>> languages = {
    'ku': {'name': 'کوردی (سۆرانی)', 'flag': '❤️☀️💚', 'dir': 'rtl'},
    'kbd': {'name': 'کوردی (بادینی)', 'flag': '❤️☀️💚', 'dir': 'rtl'},
    'ar': {'name': 'العربية', 'flag': '🇮🇶', 'dir': 'rtl'},
    'en': {'name': 'English', 'flag': '🇬🇧', 'dir': 'ltr'},
  };

  // === ANIMATION DURATIONS ===
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 1000);

  // === BORDER RADIUS ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 100.0;

  // === SPACING ===
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // === INSTITUTION TYPES ===
  static const Map<String, Map<String, String>> institutionTypes = {
    'university': {
      'ku': 'زانکۆ',
      'ar': 'جامعة',
      'en': 'University',
      'tr': 'Üniversite',
      'emoji': '🎓',
    },
    'institute': {
      'ku': 'ئینستیتیوت',
      'ar': 'معهد',
      'en': 'Institute',
      'tr': 'Enstitü',
      'emoji': '🏛️',
    },
    'school': {
      'ku': 'قوتابخانە',
      'ar': 'مدرسة',
      'en': 'School',
      'tr': 'Okul',
      'emoji': '🏫',
    },
    'kindergarten': {
      'ku': 'باخچەی منداڵان',
      'ar': 'روضة',
      'en': 'Kindergarten',
      'tr': 'Anaokulu',
      'emoji': '🌱',
    },
    'language_center': {
      'ku': 'سەنتەری زمان',
      'ar': 'مركز لغات',
      'en': 'Language Center',
      'tr': 'Dil Merkezi',
      'emoji': '💬',
    },
  };

  // === FILTER CITIES (display-name → DB value map) ===
  // DB stores Kurdish names; these are the exact values used in WHERE clause
  static const List<String> filterCityApiValues = [
    'هەولێر',
    'سلێمانی',
    'دهۆک',
    'هەڵەبجە',
    'کەرکوک',
  ];

  // === CITIES ===
  static const List<String> iraqiCities = [
    // کوردستان
    'هەولێر',
    'سلێمانی',
    'دهۆک',
    'زاخۆ',
    'ئامێدی',
    'سیمێل',
    'شێخان',
    'دیانا',
    'چۆمان',
    'سۆران',

    'کەرکووک',
    'هەڵەبجە',
    'رانیە',
    'کەلار',
    'قلادزێ',
    'دوکان',
    'دەربەندیخان',
    'کفری',
    'چەمچەماڵ',
    'شارەزووری',
    'پێنجوێن',
    'سەید سادق',
    'دوزەخوڕماتو',
    // عراق
    'بەغداد',
    'مووسڵ',
    'بەسرە',
    'نەجەف',
    'کەربەلا',
    'حیللە',
    'سامەراء',
    'تکریت',
    'رمادی',
    'فەللووجە',
    'نەسیریە',
    'عەماره',
    'کووت',
    'دیوانیە',
    'دیالی',
    'بعقووبە',
    'رووتبە',
    'قائم',
    'عەلی گەرب',
    'مەیسان',
    'واسط',
    'صلاح الدین',
    'ئەنبار',
    'نینەوا',
    'سینجار',
    'تەلاعەفەر',
  ];
}
