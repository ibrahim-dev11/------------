import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ku'),
    Locale('kbd'),
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  String get languageCode => locale.languageCode;
  bool get isRTL => locale.languageCode == 'ku' || locale.languageCode == 'kbd' || locale.languageCode == 'ar';

  String _t(Map<String, String> map) => map[locale.languageCode] ?? map['ku'] ?? map['en'] ?? '';

  // =====================
  // APP GENERAL
  // =====================
  String get appName => _t({'ku': 'edu book', 'kbd': 'edu book', 'ar': 'edu book', 'en': 'edu book', 'tr': 'edu book'});
  String get appTagline => _t({'ku': 'پلاتفۆرمی پەروەردەی مۆدێرن', 'kbd': 'پلاتفۆڕما پەروەردەیا مۆدێرن', 'ar': 'منصة التعليم الحديثة', 'en': 'Modern Educational Platform', 'tr': 'Modern Eğitim Platformu'});
  String get loading => _t({'ku': 'چاوەڕوان بە...', 'kbd': 'ل هیڤیێ بە...', 'ar': 'جاري التحميل...', 'en': 'Loading...', 'tr': 'Yükleniyor...'});
  String get error => _t({'ku': 'هەڵە', 'kbd': 'شاشی', 'ar': 'خطأ', 'en': 'Error', 'tr': 'Hata'});
  String get retry => _t({'ku': 'دووبارە هەوڵ بدەرەوە', 'kbd': 'دووبارە هەول بدە', 'ar': 'أعد المحاولة', 'en': 'Retry', 'tr': 'Yeniden dene'});
  String get cancel => _t({'ku': 'هەڵوەشاندنەوە', 'kbd': 'پاشگەزبوون', 'ar': 'إلغاء', 'en': 'Cancel', 'tr': 'İptal'});
  String get save => _t({'ku': 'پاشەکەوت بکە', 'kbd': 'پاراستن', 'ar': 'حفظ', 'en': 'Save', 'tr': 'Kaydet'});
  String get done => _t({'ku': 'تەواوبوو', 'kbd': 'ب دوماهی هات', 'ar': 'تم', 'en': 'Done', 'tr': 'Tamamlandı'});
  String get next => _t({'ku': 'دواتر', 'kbd': 'پاشان', 'ar': 'التالي', 'en': 'Next', 'tr': 'İleri'});
  String get back => _t({'ku': 'گەڕانەوە', 'kbd': 'زڤرین', 'ar': 'رجوع', 'en': 'Back', 'tr': 'Geri'});
  String get skip => _t({'ku': 'تێپەڕ بکە', 'kbd': 'تێپەڕاندن', 'ar': 'تخطي', 'en': 'Skip', 'tr': 'Atla'});
  String get search => _t({'ku': 'گەڕان', 'kbd': 'گەڕیان', 'ar': 'بحث', 'en': 'Search', 'tr': 'Ara'});
  String get filter => _t({'ku': 'فلتەر', 'kbd': 'فلتەر', 'ar': 'تصفية', 'en': 'Filter', 'tr': 'Filtre'});
  String get seeAll => _t({'ku': 'هەموو ببینە', 'kbd': 'هەمی دیتن', 'ar': 'مشاهدة الكل', 'en': 'See All', 'tr': 'Tümünü Gör'});
  String get noData => _t({'ku': 'زانیاری نییە', 'kbd': 'زانیاری نینن', 'ar': 'لا توجد بيانات', 'en': 'No data found', 'tr': 'Veri bulunamadı'});
  String get submit => _t({'ku': 'ناردن', 'kbd': 'فرێکرن', 'ar': 'إرسال', 'en': 'Submit', 'tr': 'Gönder'});
  String get required => _t({'ku': 'پێویستە', 'kbd': 'یا پێدڤی', 'ar': 'مطلوب', 'en': 'Required', 'tr': 'Gerekli'});
  String get invalidEmail => _t({'ku': 'ئیمەیڵی نادروستە', 'kbd': 'ئیمەیڵێ نەدرۆست', 'ar': 'بريد إلكتروني غير صالح', 'en': 'Invalid email address', 'tr': 'Geçersiz e-posta'});
  String get passwordMinLength => _t({'ku': 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت', 'kbd': 'پەیڤا نهێنی دڤێت کێمترین ٦ پیت بن', 'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'en': 'Password must be at least 6 characters', 'tr': 'Şifre en az 6 karakter olmalı'});
  String get passwordsDoNotMatch => _t({'ku': 'وشەی نهێنییەکان جیاوازن', 'kbd': 'پەیڤێن نهێنی وەک ئێک نینن', 'ar': 'كلمتا المرور غير متطابقتين', 'en': 'Passwords do not match', 'tr': 'Şifreler eşleşmiyor'});
  String get registerFailed => _t({'ku': 'تۆمارکردن سەرکەوتوو نەبوو', 'kbd': 'تۆمارکرن سەرکەفتی نەبوو', 'ar': 'فشل التسجيل', 'en': 'Registration failed', 'tr': 'Kayıt başarısız'});
  String get optional => _t({'ku': 'ئارەزووی', 'kbd': 'ئارەزوومەندانە', 'ar': 'اختياري', 'en': 'Optional', 'tr': 'İsteğe bağlı'});
  String get viewDetails => _t({'ku': 'وردەکاریەکان ببینە', 'kbd': 'بینینا هویرکاریان', 'ar': 'عرض التفاصيل', 'en': 'View Details', 'tr': 'Detayları Gör'});

  // =====================
  // ONBOARDING
  // =====================
  String get onboardingTitle1 => _t({'ku': 'edu book بدۆزەرەوە', 'kbd': 'edu book بدۆزەرەوە', 'ar': 'اكتشف edu book', 'en': 'Discover edu book', 'tr': 'edu book\'u Keşfet'});
  String get onboardingDesc1 => _t({'ku': 'زانکۆ، قوتابخانە، و سەنتەرە پەروەردەییەکان بە ئاسانی بدۆزەرەوە', 'kbd': 'زانکۆ، قوتابخانە، و ناوەندێن پەروەردەیێ ب ئاسانی بدۆزەرەوە', 'ar': 'اكتشف الجامعات والمدارس والمراكز التعليمية بسهولة', 'en': 'Discover universities, schools & educational centers easily', 'tr': 'Üniversiteleri, okulları ve eğitim merkezlerini kolayca keşfet'});
  String get onboardingTitle2 => _t({'ku': 'مامۆستا بدۆزەرەوە', 'kbd': 'مامۆستە بدۆزەرەوە', 'ar': 'ابحث عن معلم', 'en': 'Find Your Teacher', 'tr': 'Öğretmenini Bul'});
  String get onboardingDesc2 => _t({'ku': 'مامۆستای تایبەتی و زانکۆیی بدۆزەرەوە بۆ وردکاری و پێشڕەوی خوێندنەکەت', 'kbd': 'مامۆستەیێن تایبەت و زانکۆیی بدۆزەرەوە بۆ پێشکەوتنا خوەندنا تە', 'ar': 'ابحث عن معلمين خاصين وجامعيين لتطوير مهاراتك', 'en': 'Find private & university teachers for your educational advancement', 'tr': 'Öğrenimi için özel ve üniversite öğretmenleri bul'});
  String get onboardingTitle3 => _t({'ku': 'CV بنێرە', 'kbd': 'CV بنێرە', 'ar': 'أرسل سيرتك الذاتية', 'en': 'Share Your CV', 'tr': 'CV\'ni Paylaş'});
  String get onboardingDesc3 => _t({'ku': 'CV خۆت دابنێ و دۆخی کارکردن بدۆزەرەوە', 'kbd': 'CVیا خوە دابنێ و دەرفەتێن کارکرنێ بدۆزەرەوە', 'ar': 'أضف سيرتك الذاتية وابحث عن فرص العمل', 'en': 'Upload your CV and discover job opportunities', 'tr': 'CV\'ni yükle ve iş fırsatlarını keşfet'});
  String get onboardingTitle4 => _t({'ku': 'زمان هەڵبژێرە', 'kbd': 'زمان هەلبژێرە', 'ar': 'اختر اللغة', 'en': 'Choose Language', 'tr': 'Dil Seç'});
  String get onboardingDesc4 => _t({'ku': 'ئەپەکە بە ٤ زمان بەردەستە: کوردی، عەرەبی، ئینگلیزی، و تورکی', 'kbd': 'ئەپ ب ٥ زمانا ئامادەیە: کوردی سۆرانی، کوردی بادینی، عەرەبی، ئینگلیزی، و تورکی', 'ar': 'التطبيق متاح بـ٤ لغات: كردي، عربي، إنجليزي، وتركي', 'en': 'The app supports 4 languages: Kurdish, Arabic, English, Turkish', 'tr': 'Uygulama 4 dili destekler: Kürtçe, Arapça, İngilizce, Türkçe'});
  String get getStarted => _t({'ku': 'دەستپێ بکە', 'kbd': 'دەست پێ بکە', 'ar': 'ابدأ الآن', 'en': 'Get Started', 'tr': 'Başla'});
  String get selectLanguage => _t({'ku': 'زمان هەڵبژێرە', 'kbd': 'زمان هەلبژێرە', 'ar': 'اختر اللغة', 'en': 'Select Language', 'tr': 'Dil Seç'});

  // =====================
  // AUTH
  // =====================
  String get login => _t({'ku': 'چوونەژوورەوە', 'kbd': 'کەتنا ژوورەوە', 'ar': 'تسجيل الدخول', 'en': 'Login', 'tr': 'Giriş'});
  String get register => _t({'ku': 'تۆمارکردن', 'kbd': 'تۆمارکرن', 'ar': 'التسجيل', 'en': 'Register', 'tr': 'Kayıt'});
  String get logout => _t({'ku': 'چوونەدەرەوە', 'kbd': 'دەرکەتن', 'ar': 'تسجيل الخروج', 'en': 'Logout', 'tr': 'Çıkış'});
  String get email => _t({'ku': 'ئیمەیڵ', 'kbd': 'ئیمەیل', 'ar': 'البريد الإلكتروني', 'en': 'Email', 'tr': 'E-posta'});
  String get password => _t({'ku': 'وشەی نهێنی', 'kbd': 'پەیڤا نهێنی', 'ar': 'كلمة المرور', 'en': 'Password', 'tr': 'Şifre'});
  String get confirmPassword => _t({'ku': 'دووبارەکردنەوەی وشەی نهێنی', 'kbd': 'دووبارەکرنا پەیڤا نهێنی', 'ar': 'تأكيد كلمة المرور', 'en': 'Confirm Password', 'tr': 'Şifreyi Onayla'});
  String get name => _t({'ku': 'ناو', 'kbd': 'ناڤ', 'ar': 'الاسم', 'en': 'Name', 'tr': 'İsim'});
  String get fullName => _t({'ku': 'ناوی تەواو', 'kbd': 'ناڤێ تەواو', 'ar': 'الاسم الكامل', 'en': 'Full Name', 'tr': 'Tam İsim'});
  String get phone => _t({'ku': 'ژمارەی مۆبایل', 'kbd': 'ژمارا مۆبایل', 'ar': 'رقم الهاتف', 'en': 'Phone Number', 'tr': 'Telefon Numarası'});
  String get forgotPassword => _t({'ku': 'وشەی نهێنیت لەبیرچووە؟', 'kbd': 'پەیڤا نهێنی ژ بیر کریە؟', 'ar': 'نسيت كلمة المرور؟', 'en': 'Forgot Password?', 'tr': 'Şifremi Unuttum?'});
  String get noAccount => _t({'ku': 'هەژمارت نییە؟', 'kbd': 'ھەژمارا تە نینە؟', 'ar': 'ليس لديك حساب؟', 'en': "Don't have an account?", 'tr': 'Hesabın yok mu?'});
  String get haveAccount => _t({'ku': 'هەژمارت هەیە؟', 'kbd': 'ھەژمارا تە ھەیە؟', 'ar': 'لديك حساب؟', 'en': 'Already have an account?', 'tr': 'Hesabın var mı?'});
  String get loginSuccess => _t({'ku': 'بەخێربێیت!', 'kbd': 'بی خێرھاتی!', 'ar': 'مرحباً!', 'en': 'Welcome back!', 'tr': 'Tekrar hoş geldin!'});
  String get loginFailed => _t({'ku': 'ئیمەیڵ یان وشەی نهێنی هەڵەیە', 'kbd': 'ئیمەیل یان پەیڤا نهێنی شاشییە', 'ar': 'البريد أو كلمة المرور غير صحيحة', 'en': 'Incorrect email or password', 'tr': 'E-posta veya şifre hatalı'});
  String get registerSuccess => _t({'ku': 'هەژمارت دروست کرا!', 'kbd': 'ھەژمارا تە درووست بوو!', 'ar': 'تم إنشاء حسابك!', 'en': 'Account created!', 'tr': 'Hesabın oluşturuldu!'});
  String get sendOtp => _t({'ku': 'کۆدی پشتڕاستکردنەوە بنێرە', 'kbd': 'کۆدا پشتراستکرنێ بنێرە', 'ar': 'إرسال رمز التحقق', 'en': 'Send OTP Code', 'tr': 'Doğrulama Kodu Gönder'});
  String get enterOtp => _t({'ku': 'کۆدی نێردراو بنووسە', 'kbd': 'کۆدا ھاتیە شاندن بنڤیسە', 'ar': 'أدخل الرمز المرسل', 'en': 'Enter the code sent', 'tr': 'Gönderilen kodu gir'});
  String get resendOtp => _t({'ku': 'کۆد دووبارە بنێرە', 'kbd': 'کۆد دووبارە بنێرە', 'ar': 'إعادة إرسال الرمز', 'en': 'Resend Code', 'tr': 'Kodu Yeniden Gönder'});
  String get resetPassword => _t({'ku': 'وشەی نهێنی نوێ بکەرەوە', 'kbd': 'پەیڤا نهێنی نوێ بکە', 'ar': 'إعادة تعيين كلمة المرور', 'en': 'Reset Password', 'tr': 'Şifreyi Sıfırla'});
  String get orContinueWith => _t({'ku': 'یان بەردەوام بکە بە', 'kbd': 'یان بەردەوام بکە ب', 'ar': 'أو تابع مع', 'en': 'Or continue with', 'tr': 'Ya da şununla devam et'});

  // =====================
  // HOME
  // =====================
  String get home => _t({'ku': 'سەرەکی', 'kbd': 'سەرەکی', 'ar': 'الرئيسية', 'en': 'Home', 'tr': 'Ana Sayfa'});
  String get welcome => _t({'ku': 'بەخێربێی', 'kbd': 'بخێر هاتی', 'ar': 'مرحباً', 'en': 'Welcome', 'tr': 'Hoş Geldin'});
  String get featuredInstitutions => _t({'ku': 'خوێندنگاکانی تایبەت', 'kbd': 'خویندنگەهێن تایبەت', 'ar': 'المؤسسات المميزة', 'en': 'Featured Institutions', 'tr': 'Öne Çıkan Kurumlar'});
  String get categories => _t({'ku': 'جۆرەکان', 'kbd': 'جۆر', 'ar': 'الفئات', 'en': 'Categories', 'tr': 'Kategoriler'});
  String get statistics => _t({'ku': 'ئامارەکان', 'kbd': 'ئامار', 'ar': 'الإحصائيات', 'en': 'Statistics', 'tr': 'İstatistikler'});
  String get recentUpdates => _t({'ku': 'نوێترین نوێکردنەوەکان', 'kbd': 'نوێترین نویکرنەڤە', 'ar': 'آخر التحديثات', 'en': 'Recent Updates', 'tr': 'Son Güncellemeler'});
  String get searchHint => _t({'ku': 'گەڕان', 'kbd': 'ل خویندنگەهەکێ بگەرە...', 'ar': 'ابحث عن مؤسسة...', 'en': 'Search institutions...', 'tr': 'Kurum ara...'});
  String get goodMorning => _t({'ku': 'بەیانیت باش', 'kbd': 'بەیانی باش', 'ar': 'صباح الخير', 'en': 'Good Morning', 'tr': 'Günaydın'});
  String get goodAfternoon => _t({'ku': 'نیوەڕۆت باش', 'kbd': 'نیڤرۆ باش', 'ar': 'مساء الخير', 'en': 'Good Afternoon', 'tr': 'İyi Öğlenler'});
  String get goodEvening => _t({'ku': 'ئێوارەت باش', 'kbd': 'ئێڤار باش', 'ar': 'مساء الخير', 'en': 'Good Evening', 'tr': 'İyi Akşamlar'});

  // =====================
  // INSTITUTIONS
  // =====================
  String get institutions => _t({'ku': 'خوێندنگاکان', 'kbd': 'خویندنگەهـ', 'ar': 'المؤسسات', 'en': 'Institutions', 'tr': 'Kurumlar'});
  String get institutionTypes => _t({'ku': 'جۆرەکان', 'kbd': 'جۆرێن دەزگەهان', 'ar': 'الأنواع', 'en': 'Types', 'tr': 'Türler'});
  String get university => _t({'ku': 'زانکۆ', 'kbd': 'زانکۆ', 'ar': 'جامعة', 'en': 'University', 'tr': 'Üniversite'});
  String get institute => _t({'ku': 'ئینستیتیوت', 'kbd': 'پەیمانگەهـ', 'ar': 'معهد', 'en': 'Institute', 'tr': 'Enstitü'});
  String get school => _t({'ku': 'قوتابخانە', 'kbd': 'قوتابخانە', 'ar': 'مدرسة', 'en': 'School', 'tr': 'Okul'});
  String get kindergarten => _t({'ku': 'باخچەی منداڵان', 'kbd': 'باخچێ زارۆکان', 'ar': 'روضة', 'en': 'Kindergarten', 'tr': 'Anaokulu'});
  String get languageCenter => _t({'ku': 'سەنتەری زمان', 'kbd': 'سەنتەرێ زمانان', 'ar': 'مركز لغات', 'en': 'Language Center', 'tr': 'Dil Merkezi'});
  String get city => _t({'ku': 'شار', 'kbd': 'باژێر', 'ar': 'المدينة', 'en': 'City', 'tr': 'Şehir'});
  String get country => _t({'ku': 'وڵات', 'kbd': 'وەڵات', 'ar': 'البلد', 'en': 'Country', 'tr': 'Ülke'});
  String get address => _t({'ku': 'ناونیشان', 'kbd': 'ناڤنیشان', 'ar': 'العنوان', 'en': 'Address', 'tr': 'Adres'});
  String get website => _t({'ku': 'مەلپەر', 'kbd': 'مالپەر', 'ar': 'الموقع', 'en': 'Website', 'tr': 'Web Sitesi'});
  String get gallery => _t({'ku': 'گالەری', 'kbd': 'گالەری', 'ar': 'معرض الصور', 'en': 'Gallery', 'tr': 'Galeri'});
  String get location => _t({'ku': 'شوێن', 'kbd': 'جهـ', 'ar': 'الموقع', 'en': 'Location', 'tr': 'Konum'});
  String get socialMedia => _t({'ku': 'تۆرە کۆمەڵایەتییەکان', 'kbd': 'تورێن جڤاکی', 'ar': 'وسائل التواصل', 'en': 'Social Media', 'tr': 'Sosyal Medya'});
  String get description => _t({'ku': 'وەسف', 'kbd': 'وەسف', 'ar': 'الوصف', 'en': 'Description', 'tr': 'Açıklama'});
  String get contact => _t({'ku': 'پەیوەندی', 'kbd': 'پەیوەندی', 'ar': 'التواصل', 'en': 'Contact', 'tr': 'İletişim'});
  String get openMap => _t({'ku': 'نەخشە بکەرەوە', 'kbd': 'نەخشەی ڤەکە', 'ar': 'فتح الخريطة', 'en': 'Open Map', 'tr': 'Haritayı Aç'});
  String get addToFavorites => _t({'ku': 'زیادکردن بۆ دڵخوازەکان', 'kbd': 'زێدەکرن بۆ دلخوازان', 'ar': 'إضافة للمفضلة', 'en': 'Add to Favorites', 'tr': 'Favorilere Ekle'});
  String get removeFromFavorites => _t({'ku': 'لەناو دڵخوازەکان بکە', 'kbd': 'ژ دلخوازان دەرخە', 'ar': 'إزالة من المفضلة', 'en': 'Remove from Favorites', 'tr': 'Favorilerden Kaldır'});
  String get favorites => _t({'ku': 'دڵخوازەکان', 'kbd': 'دلخواز', 'ar': 'المفضلة', 'en': 'Favorites', 'tr': 'Favoriler'});
  String get colleges => _t({'ku': 'کۆلێجەکان', 'kbd': 'کۆلێژ', 'ar': 'الكليات', 'en': 'Colleges', 'tr': 'Fakülteler'});
  String get departments => _t({'ku': 'بەشەکان', 'kbd': 'پشک', 'ar': 'الأقسام', 'en': 'Departments', 'tr': 'Bölümler'});
  String get sortBy => _t({'ku': 'ریزکردنی بەپێی', 'kbd': 'رێزکرن ل دویڤ', 'ar': 'ترتيب حسب', 'en': 'Sort By', 'tr': 'Sırala'});
  String get newest => _t({'ku': 'نوێترین', 'kbd': 'نوێترین', 'ar': 'الأحدث', 'en': 'Newest', 'tr': 'En Yeni'});
  String get filterByCity => _t({'ku': 'فلتەر بەپێی شار', 'kbd': 'فلتەرکرن ل دویڤ باژێری', 'ar': 'تصفية حسب المدينة', 'en': 'Filter by City', 'tr': 'Şehre Göre Filtrele'});
  String get filterByType => _t({'ku': 'فلتەر بەپێی جۆر', 'kbd': 'فلتەرکرن ل دویڤ جۆری', 'ar': 'تصفية حسب النوع', 'en': 'Filter by Type', 'tr': 'Türe Göre Filtrele'});
  String get allTypes => _t({'ku': 'هەموو جۆرەکان', 'kbd': 'هەمی جۆر', 'ar': 'جميع الأنواع', 'en': 'All Types', 'tr': 'Tüm Türler'});
  String get allCities => _t({'ku': 'هەموو شارەکان', 'kbd': 'هەمی باژێر', 'ar': 'جميع المدن', 'en': 'All Cities', 'tr': 'Tüm Şehirler'});
  String get report => _t({'ku': 'ڕاپۆرت', 'kbd': 'راپۆرت', 'ar': 'إبلاغ', 'en': 'Report', 'tr': 'Şikayet Et'});

  // TEACHERS
  // =====================
  String get teachers => _t({'ku': 'مامۆستایان', 'kbd': 'مامۆستە', 'ar': 'المعلمون', 'en': 'Teachers', 'tr': 'Öğretmenler'});
  String get myTeachers => _t({'ku': 'مامۆستاکانم', 'kbd': 'مامۆستەیێن من', 'ar': 'معلموني', 'en': 'My Teachers', 'tr': 'Öğretmenlerim'});
  String get privateTeacher => _t({'ku': 'مامۆستای تایبەت', 'kbd': 'مامۆستەیێ تایبەت', 'ar': 'معلم خاص', 'en': 'Private Teacher', 'tr': 'Özel Öğretmen'});
  String get universityTeacher => _t({'ku': 'مامۆستای زانکۆ', 'kbd': 'مامۆستەیێ زانکۆیێ', 'ar': 'معلم جامعي', 'en': 'University Teacher', 'tr': 'Üniversite Öğretmeni'});
  String get schoolTeacher => _t({'ku': 'مامۆستای قوتابخانە', 'kbd': 'مامۆستەیێ قوتابخانێ', 'ar': 'معلم مدرسة', 'en': 'School Teacher', 'tr': 'Okul Öğretmeni'});
  String get experience => _t({'ku': 'ئەزموون', 'kbd': 'ئەزموون', 'ar': 'الخبرة', 'en': 'Experience', 'tr': 'Deneyim'});
  String get experienceYears => _t({'ku': 'ساڵی ئەزموون', 'kbd': 'سالێن ئەزموونێ', 'ar': 'سنوات الخبرة', 'en': 'Years of Experience', 'tr': 'Deneyim Yılı'});
  String get hourlyRate => _t({'ku': 'کرێی هەر کاتژمێر', 'kbd': 'بهایێ هەر دەمژمێرەکێ', 'ar': 'الأجر في الساعة', 'en': 'Hourly Rate', 'tr': 'Saatlik Ücret'});
  String get about => _t({'ku': 'دەربارەی', 'kbd': 'دەربارەی', 'ar': 'عن', 'en': 'About', 'tr': 'Hakkında'});
  String get subject => _t({'ku': 'بابەت', 'kbd': 'بابەت', 'ar': 'المادة', 'en': 'Subject', 'tr': 'Ders'});
  String get rating => _t({'ku': 'هەڵسەنگاندن', 'kbd': 'هەلسەنگاندن', 'ar': 'التقييم', 'en': 'Rating', 'tr': 'Değerlendirme'});
  String get reviews => _t({'ku': 'ڕێکردنەوەکان', 'kbd': 'پەیڤێن هەلسەنگاندنێ', 'ar': 'التقييمات', 'en': 'Reviews', 'tr': 'İncelemeler'});
  String get bookTeacher => _t({'ku': 'مامۆستا بووکبکە', 'kbd': 'ژڤانەکی ل دەف مامۆستەی بگرە', 'ar': 'احجز معلم', 'en': 'Book Teacher', 'tr': 'Öğretmen Rezerve Et'});
  String get contactTeacher => _t({'ku': 'پەیوەندی بکە', 'kbd': 'پەیوەندیێ بکە', 'ar': 'تواصل معه', 'en': 'Contact', 'tr': 'İletişim Kur'});
  String get registerAsTeacher => _t({'ku': 'وەک مامۆستا تۆمار بکە', 'kbd': 'وەک مامۆستە تۆمار بکە', 'ar': 'سجل كمعلم', 'en': 'Register as Teacher', 'tr': 'Öğretmen Olarak Kayıt'});
  String get biography => _t({'ku': 'بیۆگرافی', 'kbd': 'ژیاننامە', 'ar': 'السيرة الذاتية المختصرة', 'en': 'Biography', 'tr': 'Biyografi'});
  String get subjects => _t({'ku': 'بابەتەکان', 'kbd': 'بابەت', 'ar': 'المواد', 'en': 'Subjects', 'tr': 'Dersler'});

  // =====================
  // CV
  // =====================
  String get cvBank => _t({'ku': 'سیڤیەکان', 'kbd': 'سیڤی', 'ar': 'السیرة الذاتیة', 'en': 'CV Bank', 'tr': 'CV Bankası'});
  String get uploadCv => _t({'ku': 'CV بنێرە', 'kbd': 'CVیا خوە بنێرە', 'ar': 'رفع السيرة الذاتية', 'en': 'Upload CV', 'tr': 'CV Yükle'});
  String get createCv => _t({'ku': 'CV دروست بکە', 'kbd': 'CVیەکێ درووست بکە', 'ar': 'إنشاء سيرة ذاتية', 'en': 'Create CV', 'tr': 'CV Oluştur'});
  String get jobOpportunities => _t({'ku': 'دۆخی کار', 'kbd': 'دەرفەتێن کاری', 'ar': 'فرص العمل', 'en': 'Job Opportunities', 'tr': 'İş Fırsatları'});
  String get applyNow => _t({'ku': 'ئێستا داواکاری بکە', 'kbd': 'نوکە داخوازیێ پێشکێش بکە', 'ar': 'قدم الآن', 'en': 'Apply Now', 'tr': 'Şimdi Başvur'});
  String get education => _t({'ku': 'خوێندن', 'kbd': 'خوەندن', 'ar': 'التعليم', 'en': 'Education', 'tr': 'Eğitim'});
  String get skills => _t({'ku': 'تواناکان', 'kbd': 'شیان', 'ar': 'المهارات', 'en': 'Skills', 'tr': 'Beceriler'});
  String get graduationYear => _t({'ku': 'ساڵی دەرچوون', 'kbd': 'سالا دەرچوونێ', 'ar': 'سنة التخرج', 'en': 'Graduation Year', 'tr': 'Mezuniyet Yılı'});
  String get field => _t({'ku': 'بوار', 'kbd': 'بوار', 'ar': 'التخصص', 'en': 'Field of Study', 'tr': 'Çalışma Alanı'});
  String get educationLevel => _t({'ku': 'ئاستی خوێندن', 'kbd': 'ئاستێ خوەندنێ', 'ar': 'المستوى التعليمي', 'en': 'Education Level', 'tr': 'Eğitim Seviyesi'});
  String get age => _t({'ku': 'تەمەن', 'kbd': 'ژیێ تە', 'ar': 'العمر', 'en': 'Age', 'tr': 'Yaş'});
  String get gender => _t({'ku': 'رەگەز', 'kbd': 'رەگەز', 'ar': 'الجنس', 'en': 'Gender', 'tr': 'Cinsiyet'});
  String get male => _t({'ku': 'نێر', 'kbd': 'نێر', 'ar': 'ذكر', 'en': 'Male', 'tr': 'Erkek'});
  String get female => _t({'ku': 'مێ', 'kbd': 'مێ', 'ar': 'أنثى', 'en': 'Female', 'tr': 'Kadın'});
  String get notes => _t({'ku': 'تێبینی', 'kbd': 'تێبینی', 'ar': 'ملاحظات', 'en': 'Notes', 'tr': 'Notlar'});
  String get saveCv => _t({'ku': 'CV پاشەکەوت بکە', 'kbd': 'CVیا خوە بپارێزە', 'ar': 'حفظ السيرة الذاتية', 'en': 'Save CV', 'tr': 'CV Kaydet'});

  // =====================
  // NOTIFICATIONS
  // =====================
  String get notifications => _t({'ku': 'ئاگادارکردنەوەکان', 'kbd': 'ئاگەداری', 'ar': 'الإشعارات', 'en': 'Notifications', 'tr': 'Bildirimler'});
  String get noNotifications => _t({'ku': 'ئاگادارکردنەوە نییە', 'kbd': 'چ ئاگەداری نینن', 'ar': 'لا توجد إشعارات', 'en': 'No notifications', 'tr': 'Bildirim yok'});
  String get markAllRead => _t({'ku': 'هەموو وەک خوێندراو دیاریبکە', 'kbd': 'هەمییان وەک خواندی نیشان بدە', 'ar': 'تحديد الكل كمقروء', 'en': 'Mark All Read', 'tr': 'Tümünü Okundu İşaretle'});
  String get newInstitution => _t({'ku': 'خوێندنگای نوێ', 'kbd': 'خویندنگەها نوێ', 'ar': 'مؤسسة جديدة', 'en': 'New Institution', 'tr': 'Yeni Kurum'});

  // =====================
  // PROFILE & SETTINGS
  // =====================
  String get profile => _t({'ku': 'پرۆفایل', 'kbd': 'پرۆفایل', 'ar': 'الملف الشخصي', 'en': 'Profile', 'tr': 'Profil'});
  String get settings => _t({'ku': 'ڕێکخستنەکان', 'kbd': 'ڕێکخستن', 'ar': 'الإعدادات', 'en': 'Settings', 'tr': 'Ayarlar'});
  String get editProfile => _t({'ku': 'پرۆفایل دەستکاری بکە', 'kbd': 'دەستکاریا پرۆفایلی بکە', 'ar': 'تعديل الملف', 'en': 'Edit Profile', 'tr': 'Profili Düzenle'});
  String get language => _t({'ku': 'زمان', 'kbd': 'زمان', 'ar': 'اللغة', 'en': 'Language', 'tr': 'Dil'});
  String get darkMode => _t({'ku': 'دۆخی تاریک', 'kbd': 'مۆدێ تاریک', 'ar': 'الوضع الداكن', 'en': 'Dark Mode', 'tr': 'Karanlık Mod'});
  String get lightMode => _t({'ku': 'دۆخی ڕووناک', 'kbd': 'مۆدێ رووناک', 'ar': 'الوضع الفاتح', 'en': 'Light Mode', 'tr': 'Aydınlık Mod'});
  String get appearance => _t({'ku': 'دیمەن', 'kbd': 'دیمەن', 'ar': 'المظهر', 'en': 'Appearance', 'tr': 'Görünüm'});
  String get privacy => _t({'ku': 'پاراستنی نهێنی', 'kbd': 'پاراستنا نهێنییان', 'ar': 'الخصوصية', 'en': 'Privacy', 'tr': 'Gizlilik'});
  String get security => _t({'ku': 'ئەمنیەت', 'kbd': 'ئەمنیەت', 'ar': 'الأمان', 'en': 'Security', 'tr': 'Güvenlik'});
  String get help => _t({'ku': 'یارمەتی', 'kbd': 'هاریکاری', 'ar': 'المساعدة', 'en': 'Help', 'tr': 'Yardım'});
  String get about2 => _t({'ku': 'دەربارەی ئەپ', 'kbd': 'دەربارەی ئەپی', 'ar': 'حول التطبيق', 'en': 'About App', 'tr': 'Uygulama Hakkında'});
  String get savedItems => _t({'ku': 'گیراوەکان', 'kbd': 'پاراستی', 'ar': 'المحفوظات', 'en': 'Saved Items', 'tr': 'Kaydedilenler'});
  String get version => _t({'ku': 'وەشان', 'kbd': 'وەشان', 'ar': 'الإصدار', 'en': 'Version', 'tr': 'Sürüm'});
  String get logoutConfirm => _t({'ku': 'دڵنیایت لە چوونەدەرەوە؟', 'kbd': 'تۆ یێ پشت راستی دڤێی دەرکەڤی؟', 'ar': 'هل أنت متأكد من تسجيل الخروج؟', 'en': 'Are you sure you want to logout?', 'tr': 'Çıkış yapmak istediğinden emin misin?'});
  String get notificationSettings => _t({'ku': 'ڕێکخستنی ئاگادارکردنەوەکان', 'kbd': 'رێکخستنا ئاگەدارییان', 'ar': 'إعدادات الإشعارات', 'en': 'Notification Settings', 'tr': 'Bildirim Ayarları'});
  String get enableNotifications => _t({'ku': 'ئاگادارکردنەوەکان چالاک بکە', 'kbd': 'ئاگەدارییان چالاک بکە', 'ar': 'تفعيل الإشعارات', 'en': 'Enable Notifications', 'tr': 'Bildirimleri Etkinleştir'});
  // EXTRA STRINGS
  // =====================
  String get featured => _t({'ku': 'تایبەت', 'kbd': 'تایبەت', 'ar': 'مميز', 'en': 'Featured', 'tr': 'Öne Çıkan'});
  String get recent => _t({'ku': 'نوێترین', 'kbd': 'نوێترین', 'ar': 'الأحدث', 'en': 'Recent', 'tr': 'Son'});
  String get noResults => _t({'ku': 'ئەنجام نییە', 'kbd': 'چ ئەنجام نینن', 'ar': 'لا توجد نتائج', 'en': 'No results found', 'tr': 'Sonuç bulunamadı'});
  String get years => _t({'ku': 'ساڵ', 'kbd': 'ساڵ', 'ar': 'سنة', 'en': 'Years', 'tr': 'Yıl'});
  String get loginToSeeNotifications => _t({'ku': 'داخڵ بوو بۆ بینینی ئاگادارکردنەوەکان', 'kbd': 'ژ بۆ دیتنا ئاگەدارییان بچووە ژوور', 'ar': 'سجل دخول لرؤية الإشعارات', 'en': 'Login to see notifications', 'tr': 'Bildirimleri görmek için giriş yap'});
  String get savedInstitutions => _t({'ku': 'خوێندنگاکانی گیراو', 'kbd': 'خویندنگەهێن پاراستی', 'ar': 'المؤسسات المحفوظة', 'en': 'Saved Institutions', 'tr': 'Kaydedilen Kurumlar'});
  String get noFavorites => _t({'ku': 'هیچ خوێندنگێکت گیراو نییە', 'kbd': 'تە چ خویندنگەهـ نەپاراستینە', 'ar': 'لم تحفظ أي مؤسسة بعد', 'en': 'No saved institutions yet', 'tr': 'Henüz kaydedilen kurum yok'});
  String get browseInstitutions => _t({'ku': 'خوێندنگاکان ببینە', 'kbd': 'ل خویندنگەهان بگەرە', 'ar': 'تصفح المؤسسات', 'en': 'Browse Institutions', 'tr': 'Kurumları Gezin'});
  String get saved => _t({'ku': 'گیراوەکان', 'kbd': 'پاراستی', 'ar': 'المحفوظات', 'en': 'Saved', 'tr': 'Kaydedilenler'});
  String get guest => _t({'ku': 'میوان', 'kbd': 'مێڤان', 'ar': 'ضيف', 'en': 'Guest', 'tr': 'Misafir'});
  String get teacherRegisterSuccess => _t({'ku': 'داواکاریت بە سەرکەوتوویی نێردرا، بچاوە ڕاگەیەنراوەکانت', 'kbd': 'داخوازییا تە ب سەرکەفتی هاتە شاندن، ل هیڤییا بەرسڤێ بە', 'ar': 'تم إرسال طلبك بنجاح، انتظر الموافقة', 'en': 'Your request was submitted. Await approval.', 'tr': 'Talebiniz gönderildi. Onay bekleyin.'});
  String get cvSubmitSuccess => _t({'ku': 'CV ت بە سەرکەوتوویی نێردرا', 'kbd': 'CVیا تە ب سەرکەفتی هاتە شاندن', 'ar': 'تم رفع سيرتك الذاتية بنجاح', 'en': 'Your CV was submitted successfully', 'tr': 'CV\'niz başarıyla gönderildi'});
  String get successTitle => _t({'ku': 'سەرکەوتوو بوو! ✅', 'kbd': 'ب سەرکەفتی! ✅', 'ar': 'تم بنجاح! ✅', 'en': 'Success! ✅', 'tr': 'Başarılı! ✅'});
  String get personalInfo => _t({'ku': 'زانیاری کەسی', 'kbd': 'پێزانیێن کەسی', 'ar': 'المعلومات الشخصية', 'en': 'Personal Info', 'tr': 'Kişisel Bilgiler'});
  String get fieldOfStudy => _t({'ku': 'بواری خوێندن', 'kbd': 'بوارێ خوەندنێ', 'ar': 'مجال الدراسة', 'en': 'Field of Study', 'tr': 'Çalışma Alanı'});
  String get subjectPhoto => _t({'ku': 'وێنەی بابەت', 'kbd': 'وێنێ بابەتی', 'ar': 'صورة المادة', 'en': 'Subject Photo', 'tr': 'Ders Fotoğrafı'});
  String get teacherType => _t({'ku': 'جۆری مامۆستا', 'kbd': 'جۆرێ مامۆستەی', 'ar': 'نوع المعلم', 'en': 'Teacher Type', 'tr': 'Öğretmen Türü'});
  String get privacyPolicy => _t({'ku': 'سیاسەتی نهێنی', 'kbd': 'سیاسەتا نهێنییان', 'ar': 'سياسة الخصوصية', 'en': 'Privacy Policy', 'tr': 'Gizlilik Politikası'});
  String get helpCenter => _t({'ku': 'ناوەندی یارمەتی', 'kbd': 'سەنتەرێ هاریکاریێ', 'ar': 'مركز المساعدة', 'en': 'Help Center', 'tr': 'Yardım Merkezi'});
  String get contactInfo => _t({'ku': 'زانیاری پەیوەندی', 'kbd': 'پێزانیێن پەیوەندیێ', 'ar': 'معلومات الاتصال', 'en': 'Contact Info', 'tr': 'İletişim Bilgileri'});
  String get social => _t({'ku': 'تۆرە کۆمەڵایەتییەکان', 'kbd': 'تورێن جڤاکی', 'ar': 'التواصل الاجتماعي', 'en': 'Social Media', 'tr': 'Sosyal Medya'});
  String get profilePhoto => _t({'ku': 'وێنەی پرۆفایل', 'kbd': 'وێنێ پرۆفایلی', 'ar': 'صورة الملف', 'en': 'Profile Photo', 'tr': 'Profil Fotoğrafı'});
  String get all => _t({'ku': 'هەموو', 'kbd': 'هەمی', 'ar': 'الكل', 'en': 'All', 'tr': 'Tümü'});
  String get stats => _t({'ku': 'ئامارەکان', 'kbd': 'ئامار', 'ar': 'الإحصائيات', 'en': 'Statistics', 'tr': 'İstatistikler'});

  String get totalInstitutions => _t({'ku': 'کۆی خوێندنگاکان', 'kbd': 'کۆما خویندنگەهان', 'ar': 'إجمالي المؤسسات', 'en': 'Total Institutions', 'tr': 'Toplam Kurum'});
  String get totalTeachers => _t({'ku': 'کۆی مامۆستایان', 'kbd': 'کۆما مامۆستەیان', 'ar': 'إجمالي المعلمين', 'en': 'Total Teachers', 'tr': 'Toplam Öğretmen'});
  String get totalCvs => _t({'ku': 'کۆی CVکان', 'kbd': 'کۆما CVیان', 'ar': 'إجمالي السير الذاتية', 'en': 'Total CVs', 'tr': 'Toplam CV'});
  String get cities => _t({'ku': 'شارەکان', 'kbd': 'باژێر', 'ar': 'المدن', 'en': 'Cities', 'tr': 'Şehirler'});
  String get foundedYearLabel => _t({'ku': 'ساڵی دامەزران', 'kbd': 'ساڵا دامەزرانێ', 'ar': 'سنة التأسيس', 'en': 'Founded Year', 'tr': 'Kuruluş Yılı'});
  String get studentsLabel => _t({'ku': 'قوتابی', 'kbd': 'قوتابی', 'ar': 'طلاب', 'en': 'Students', 'tr': 'Öğrenciler'});

  // =====================
  // MISSING COMMON STRINGS
  // =====================
  String get institutionMap => _t({'ku': 'نەخشەی دامەزراوەکان', 'kbd': 'نەخشەیا دەزگەهان', 'ar': 'خريطة المؤسسات', 'en': 'Institutions Map', 'tr': 'Kurum Haritası'});
  String get noInformation => _t({'ku': 'هیچ زانیارییەک نییە', 'kbd': 'چ پێزانیین نینن', 'ar': 'لا توجد معلومات', 'en': 'No information available', 'tr': 'Bilgi yok'});
  String get noPosts => _t({'ku': 'هیچ پۆستێک نییە', 'kbd': 'چ پۆست نینن', 'ar': 'لا توجد منشورات', 'en': 'No posts yet', 'tr': 'Henüz gönderi yok'});
  String get viewVideo => _t({'ku': 'ڤیدیۆی دامەزراوەکە ببینە', 'kbd': 'ڤیدیۆیا دەزگەهی ببینە', 'ar': 'شاهد فيديو المؤسسة', 'en': 'Watch Institution Video', 'tr': 'Kurum Videosunu İzle'});
  String get map => _t({'ku': 'نەخشە', 'kbd': 'نەخشە', 'ar': 'الخريطة', 'en': 'Map', 'tr': 'Harita'});
  String get clear => _t({'ku': 'پاکردنەوە', 'kbd': 'پاقژکرن', 'ar': 'مسح', 'en': 'Clear', 'tr': 'Temizle'});
  String get institutionType => _t({'ku': 'جۆری دامەزراوە', 'kbd': 'جۆرێ دەزگەهی', 'ar': 'نوع المؤسسة', 'en': 'Institution Type', 'tr': 'Kurum Türü'});
  String get scanQr => _t({'ku': 'سکانی کۆدی QR', 'kbd': 'سکانا کۆدا QR', 'ar': 'مسح رمز QR', 'en': 'Scan QR Code', 'tr': 'QR Kodunu Tara'});
  String get update => _t({'ku': 'نوێکردنەوە', 'kbd': 'نویکرنەڤە', 'ar': 'تحديث', 'en': 'Update', 'tr': 'Güncelle'});
  String get publishNew => _t({'ku': 'بڵاوکردنەوەی نوێ', 'kbd': 'بەلاڤکرنا نوێ', 'ar': 'نشر جديد', 'en': 'Publish New', 'tr': 'Yeni Yayınla'});
  String get addPhoto => _t({'ku': 'وێنەیەک بۆ شتەکە دابنێ', 'kbd': 'وێنەیەکێ بۆ تشتێ خوە دابنێ', 'ar': 'أضف صورة للشيء', 'en': 'Add photo for item', 'tr': 'Öğe için fotoğraf ekle'});
  String get itemName => _t({'ku': 'ناوی شتەکە', 'kbd': 'ناڤێ تشتێ تە', 'ar': 'اسم الشيء', 'en': 'Item Name', 'tr': 'Öğe Adı'});
  String get where => _t({'ku': 'لە کوێ؟', 'kbd': 'ل کیرێ؟', 'ar': 'أين؟', 'en': 'Where?', 'tr': 'Nerede?'});
  String get moreInfo => _t({'ku': 'زانیاری زیاتر', 'kbd': 'پێزانیێن زێدەتر', 'ar': 'معلومات أكثر', 'en': 'More Info', 'tr': 'Daha Fazla Bilgi'});
  String get fillAllInfo => _t({'ku': 'تکایە هەموو زانیارییەکان پڕبکەرەوە', 'kbd': 'تکایە هەمی پێزانییان تژی بکە', 'ar': 'يرجى ملء جميع المعلومات', 'en': 'Please fill all information', 'tr': 'Lütfen tüm bilgileri doldurun'});
  String get share => _t({'ku': 'ناردن', 'kbd': 'شاندن', 'ar': 'مشاركة', 'en': 'Share', 'tr': 'Paylaş'});
  String get close => _t({'ku': 'داخستن', 'kbd': 'داخستن', 'ar': 'إغلاق', 'en': 'Close', 'tr': 'Kapat'});
  String get apply => _t({'ku': 'جێبەجێکردن', 'kbd': 'بجهئینان', 'ar': 'تطبيق', 'en': 'Apply', 'tr': 'Uygula'});
  String get advancedFilter => _t({'ku': 'فلتەری پێشکەوتوو', 'kbd': 'فلتەرێن هویر', 'ar': 'تصفية متقدمة', 'en': 'Advanced Filter', 'tr': 'Gelişmiş Filtre'});
  String get scanQrInstructions => _t({'ku': 'کۆدی QR ی دامەزراوەکە بخەرە بەر کامێرا', 'kbd': 'کۆدا QR یا دەزگەهی بێخە بەر کامیرێ', 'ar': 'وجه الكاميرا نحو رمز QR للمؤسسة', 'en': 'Point camera at institution QR code', 'tr': 'Kamerayı kurumun QR koduna doğrultun'});
  String get viewInstitutionInfo => _t({'ku': 'بۆ بینینی زانیاری خوێندنگا', 'kbd': 'بۆ بینینا پێزانیێن خویندنگەهێ', 'ar': 'لرؤية معلومات المؤسسة', 'en': 'To view institution information', 'tr': 'Kurum bilgilerini görüntülemek için'});
  String get lost => _t({'ku': 'ونبووە', 'kbd': 'بەرزەبووی', 'ar': 'مفقود', 'en': 'Lost', 'tr': 'Kayıp'});
  String get found => _t({'ku': 'دۆزراوەتەوە', 'kbd': 'هاتیە دیتن', 'ar': 'موجود', 'en': 'Found', 'tr': 'Bulundu'});
  String get publish => _t({'ku': 'بڵاوکردنەوە', 'kbd': 'بەلاڤکرن', 'ar': 'نشر', 'en': 'Publish', 'tr': 'Yayınla'});
  String get publishedSuccess => _t({'ku': 'بە سەرکەوتوویی بڵاوکرایەوە!', 'kbd': 'ب سەرکەفتی هاتە بەلاڤکرن!', 'ar': 'تم النشر بنجاح!', 'en': 'Published successfully!', 'tr': 'Başarıyla yayınlandı!'});
  String get myAccount => _t({'ku': 'هەژماری من', 'kbd': 'هەژمارا من', 'ar': 'حسابي', 'en': 'My Account', 'tr': 'Hesabım'});
  String get lostAndFound => _t({'ku': 'ونبوو و دۆزراوە', 'kbd': 'بەرزەبووی و دیتنی', 'ar': 'المفقودات', 'en': 'Lost & Found', 'tr': 'Kayıp ve Buluntu'});
  String get messageSent => _t({'ku': 'نامە نێردرا بە سەرکەوتوویی!', 'kbd': 'نامە ب سەرکەفتی هاتە فرێکرن!', 'ar': 'تم إرسال الرسالة بنجاح!', 'en': 'Message sent successfully!', 'tr': 'Mesaj başarıyla gönderildi!'});
  String get publisher => _t({'ku': 'بڵاوکەرەوە', 'kbd': 'بەلاڤکەر', 'ar': 'الناشر', 'en': 'Publisher', 'tr': 'Yayıncı'});
  String get pathFinder => _t({'ku': 'ڕێبەرە زیرەکەکەت', 'kbd': 'رێبەرێ زیرەک', 'ar': 'دليلك الذكي', 'en': 'Path Finder', 'tr': 'Akıllı Rehber'});
  String get previous => _t({'ku': 'پێشتر', 'kbd': 'بەری نوکە', 'ar': 'السابق', 'en': 'Previous', 'tr': 'Önceki'});
  String get losts => _t({'ku': 'ونبووەکان', 'kbd': 'بەرزەبوویی', 'ar': 'المفقودات', 'en': 'Lost Items', 'tr': 'Kayıp Eşyalar'});
  String get founds => _t({'ku': 'دۆزراوەکان', 'kbd': 'دیتنی', 'ar': 'الموجودات', 'en': 'Found Items', 'tr': 'Bulunan Eşyalar'});
  String get itIsMine => _t({'ku': 'ئەوە هی منە!', 'kbd': 'ئەڤە یا منە!', 'ar': 'هذا لي!', 'en': 'It is mine!', 'tr': 'Bu benim!'});
  String get iFoundIt => _t({'ku': 'من دۆزیومەتەوە!', 'kbd': 'من دیتووە!', 'ar': 'لقد وجدته!', 'en': 'I found it!', 'tr': 'Buldum!'});
  String get searchHintLostFound => _t({'ku': 'گەڕان بەدوای کلیل، باج، مۆبایل...', 'kbd': 'گەریان ل سویچ، باج، مۆبایل...', 'ar': 'بحث عن مفتاح، بطاقة، هاتف...', 'en': 'Search for key, ID, phone...', 'tr': 'Anahtar, kimlik, telefon ara...'});
  String get noItemsFound => _t({'ku': 'هیچ شتێک نەدۆزرایەوە', 'kbd': 'چ تشت نەهاتنە دیتن', 'ar': 'لم يتم العثور على أي شيء', 'en': 'No items found', 'tr': 'Hiçbir şey bulunamadı'});
  String get nextStep => _t({'ku': 'دواتر', 'kbd': 'پاشان', 'ar': 'التالي', 'en': 'Next', 'tr': 'Sonraki'});
  String get findResults => _t({'ku': 'دۆزینەوەی ئەنجام', 'kbd': 'دیتنا ئەنجامان', 'ar': 'البحث عن النتائج', 'en': 'Find Results', 'tr': 'Sonuçları Bul'});
  String get whatIsYourGrade => _t({'ku': 'نمرەی پۆلی ١٢ت چەندە؟', 'kbd': 'نمرەیا تە یا پۆلا ١٢ چەندە؟', 'ar': 'ما هو معدلك في الصف ١٢؟', 'en': 'What is your grade 12 average?', 'tr': '12. sınıf ortalamanız kaç?'});
  String get whichFieldDoYouLike => _t({'ku': 'حەزت لە کام بووارەیە؟', 'kbd': 'تە حەز ل کیژ بوارەیە؟', 'ar': 'ما هو المجال الذي تفضله؟', 'en': 'Which field do you like?', 'tr': 'Hangi alanı seviyorsunuz?'});
  String get whichCity => _t({'ku': 'لە کام شار بێت؟', 'kbd': 'ل کیژ باژێری بیت؟', 'ar': 'في أي مدينة؟', 'en': 'In which city?', 'tr': 'Hangi şehirde?'});
  String get institutionTypeQuestion => _t({'ku': 'جۆری دامەزراوەکە؟', 'kbd': 'جۆرێ دەزگەهی؟', 'ar': 'نوع المؤسسة؟', 'en': 'Institution type?', 'tr': 'Kurum türü?'});
  String get both => _t({'ku': 'هەردووکی', 'kbd': 'هەردوو', 'ar': 'كلاهما', 'en': 'Both', 'tr': 'Her ikisi de'});
  String get public => _t({'ku': 'حکومی', 'kbd': 'حکومی', 'ar': 'حكومي', 'en': 'Public', 'tr': 'Devlet'});
  String get private => _t({'ku': 'ئەهلی', 'kbd': 'ئەهلی', 'ar': 'أهلي', 'en': 'Private', 'tr': 'Özel'});
  String get medical => _t({'ku': 'پزیشکی', 'kbd': 'پزیشکی', 'ar': 'طب', 'en': 'Medical', 'tr': 'Tıp'});
  String get engineering => _t({'ku': 'ئەندازیاری', 'kbd': 'ئەندازیاری', 'ar': 'هندسة', 'en': 'Engineering', 'tr': 'Mühendislik'});
  String get it => _t({'ku': 'تەکنەلۆژیا', 'kbd': 'تەکنەلۆژیا', 'ar': 'تكنولوجيا', 'en': 'Technology', 'tr': 'Teknoloji'});
  String get law => _t({'ku': 'یاسا', 'kbd': 'یاسا', 'ar': 'قانون', 'en': 'Law', 'tr': 'Hukuk'});
  String get business => _t({'ku': 'کارگێڕی', 'kbd': 'کارگێری', 'ar': 'إدارة أعمال', 'en': 'Business', 'tr': 'İşletme'});
  String get arts => _t({'ku': 'هونەر', 'kbd': 'هونەر', 'ar': 'فنون', 'en': 'Arts', 'tr': 'Sanat'});

  // =====================
  // NEWS
  // =====================
  String get news => _t({'ku': 'هەواڵەکان', 'kbd': 'هەواڵ', 'ar': 'الأخبار', 'en': 'News', 'tr': 'Haberler'});
  String get newsSubtitle => _t({'ku': 'تازەترین بڵاوکراوە و چالاکییەکان', 'kbd': 'نوێترین بەلاڤکراو و چالاکی', 'ar': 'أحدث المنشورات والفعاليات', 'en': 'Latest posts and activities', 'tr': 'Son yayınlar ve etkinlikler'});
  String get noContent => _t({'ku': 'هیچ ناوەرۆکێک نەدۆزرایەوە', 'kbd': 'چ ناوەرۆک نەهاتە دیتن', 'ar': 'لم يتم العثور على أي محتوى', 'en': 'No content found', 'tr': 'İçerik bulunamadı'});
  String get officialNews => _t({'ku': 'هەواڵی فەرمی', 'kbd': 'هەواڵێ فەرمی', 'ar': 'خبر رسمي', 'en': 'Official News', 'tr': 'Resmi Haber'});
  String get newsTag => _t({'ku': 'هەواڵ', 'kbd': 'هەواڵ', 'ar': 'خبر', 'en': 'News', 'tr': 'Haber'});

  // =====================
  // TIME AGO
  // =====================
  String get timeNow => _t({'ku': 'ئێستا', 'kbd': 'ئێستا', 'ar': 'الآن', 'en': 'Just now', 'tr': 'Şimdi'});
  String timeMinutesAgo(int m) => _t({'ku': '$m خولەک پێش', 'kbd': '$m خولەک پێش', 'ar': 'منذ $m دقيقة', 'en': '${m}m ago', 'tr': '$m dk önce'});
  String timeHoursAgo(int h) => _t({'ku': '$h کاتژمێر پێش', 'kbd': '$h کاتژمێر پێش', 'ar': 'منذ $h ساعة', 'en': '${h}h ago', 'tr': '$h sa önce'});
  String timeDaysAgo(int d) => _t({'ku': '$d ڕۆژ پێش', 'kbd': '$d رۆژ پێش', 'ar': 'منذ $d يوم', 'en': '${d}d ago', 'tr': '$d gün önce'});
  String timeMinutesAgoBefore(int m) => _t({'ku': '$m خولەک لەمەوبەر', 'kbd': '$m خولەک پێش', 'ar': 'منذ $m دقيقة', 'en': '${m}m ago', 'tr': '$m dk önce'});
  String timeHoursAgoBefore(int h) => _t({'ku': '$h کاتژمێر لەمەوبەر', 'kbd': '$h کاتژمێر پێش', 'ar': 'منذ $h ساعة', 'en': '${h}h ago', 'tr': '$h sa önce'});
  String timeDaysAgoBefore(int d) => _t({'ku': '$d ڕۆژ لەمەوبەر', 'kbd': '$d رۆژ پێش', 'ar': 'منذ $d يوم', 'en': '${d}d ago', 'tr': '$d gün önce'});

  // =====================
  // INSTITUTION TYPE LABELS
  // =====================
  String get typeUniversity => _t({'ku': 'زانکۆ', 'kbd': 'زانکۆ', 'ar': 'جامعة', 'en': 'University', 'tr': 'Üniversite'});
  String get typeSchool => _t({'ku': 'قوتابخانە', 'kbd': 'قوتابخانە', 'ar': 'مدرسة', 'en': 'School', 'tr': 'Okul'});
  String get typeLanguageCenter => _t({'ku': 'سەنتەری زمان', 'kbd': 'سەنتەرێ زمانان', 'ar': 'مركز لغات', 'en': 'Language Center', 'tr': 'Dil Merkezi'});
  String get typeKindergarten => _t({'ku': 'باخچەی ساوایان', 'kbd': 'باخچێ زارۆکان', 'ar': 'روضة', 'en': 'Kindergarten', 'tr': 'Anaokulu'});
  String get typeInstitute => _t({'ku': 'پەیمانگا', 'kbd': 'پەیمانگەهـ', 'ar': 'معهد', 'en': 'Institute', 'tr': 'Enstitü'});

  // =====================
  // HOME SCREEN
  // =====================
  String get ministryOfEducation => _t({'ku': 'وەزارەتی پەروەردە', 'kbd': 'وەزارەتا پەروەردێ', 'ar': 'وزارة التربية', 'en': 'Ministry of Education', 'tr': 'Milli Eğitim Bakanlığı'});
  String get higherEducation => _t({'ku': 'خوێندنی باڵا', 'kbd': 'خوەندنا باڵا', 'ar': 'التعليم العالي', 'en': 'Higher Education', 'tr': 'Yükseköğretim'});
  String get otherInstitutions => _t({'ku': 'دامەزراوەکانی تر', 'kbd': 'دەزگەهێن دی', 'ar': 'مؤسسات أخرى', 'en': 'Other Institutions', 'tr': 'Diğer Kurumlar'});
  String get educationTypes => _t({'ku': 'جۆرەکانی خوێندن', 'kbd': 'جۆرێن خوەندنێ', 'ar': 'أنواع التعليم', 'en': 'Education Types', 'tr': 'Eğitim Türleri'});
  String get seeAllShort => _t({'ku': 'هەمووی', 'kbd': 'هەمی', 'ar': 'الكل', 'en': 'See All', 'tr': 'Tümü'});
  String get allFilter => _t({'ku': 'هەموو', 'kbd': 'هەمی', 'ar': 'الكل', 'en': 'All', 'tr': 'Tümü'});
  String get bestInstitutions => _t({'ku': 'دامەزراوەکان', 'kbd': 'دەزگەهـ', 'ar': 'المؤسسات', 'en': 'Institutions', 'tr': 'Kurumlar'});
  String get noInstitutionsFound => _t({'ku': 'هیچ دامەزراوەیەک نەدۆزرایەوە', 'kbd': 'چ دەزگەهـ نەهاتە دیتن', 'ar': 'لا توجد مؤسسات', 'en': 'No institutions found', 'tr': 'Kurum bulunamadı'});
  String get applyFilter => _t({'ku': 'جێبەجێکردنی فلتەر', 'kbd': 'بجهئینانا فلتەری', 'ar': 'تطبيق الفلتر', 'en': 'Apply Filter', 'tr': 'Filtreyi Uygula'});
  String get ratingLevel => _t({'ku': 'ئاستی هەڵسەنگاندن', 'kbd': 'ئاستێ هەلسەنگاندنێ', 'ar': 'مستوى التقييم', 'en': 'Rating Level', 'tr': 'Derecelendirme Seviyesi'});

  // Cities (filter chips)
  String get cityErbil => _t({'ku': 'هەولێر', 'kbd': 'هەولێر', 'ar': 'أربيل', 'en': 'Erbil', 'tr': 'Erbil'});
  String get citySulaymaniyah => _t({'ku': 'سلێمانی', 'kbd': 'سلێمانی', 'ar': 'السليمانية', 'en': 'Sulaymaniyah', 'tr': 'Süleymaniye'});
  String get cityDuhok => _t({'ku': 'دهۆک', 'kbd': 'دهۆک', 'ar': 'دهوك', 'en': 'Duhok', 'tr': 'Duhok'});
  String get cityHalabja => _t({'ku': 'هەڵەبجە', 'kbd': 'هەڵەبجە', 'ar': 'حلبجة', 'en': 'Halabja', 'tr': 'Halabja'});
  String get cityKirkuk => _t({'ku': 'کەرکوک', 'kbd': 'کەرکوک', 'ar': 'كركوك', 'en': 'Kirkuk', 'tr': 'Kerkük'});
  List<String> get filterCities => [cityErbil, citySulaymaniyah, cityDuhok, cityHalabja, cityKirkuk];

  // Ads Carousel
  String get adDiplomaTitle => _t({'ku': 'سەنتەری دیپلۆمان', 'kbd': 'سەنتەرێ دیپلۆمان', 'ar': 'مركز الدبلومات', 'en': 'Diploma Center', 'tr': 'Diploma Merkezi'});
  String get adDiplomaSubtitle => _t({'ku': 'بەهێزترین کۆرسی زمانی ئینگلیزی', 'kbd': 'بەهێزترین کۆرسێ زمانێ ئینگلیزی', 'ar': 'أقوى دورة لغة إنجليزية', 'en': 'Most powerful English course', 'tr': 'En güçlü İngilizce kursu'});
  String get adDiplomaTag => _t({'ku': '🔥 تایبەت بەم هەفتەیە', 'kbd': '🔥 تایبەت ب ئەڤ هەفتایێ', 'ar': '🔥 عرض هذا الأسبوع', 'en': '🔥 This Week Special', 'tr': '🔥 Bu Haftaya Özel'});
  String get adComputerTitle => _t({'ku': 'پەیمانگای کۆمپیوتەر', 'kbd': 'پەیمانگەهێ کۆمپیوتەر', 'ar': 'معهد الحاسوب', 'en': 'Computer Institute', 'tr': 'Bilgisayar Enstitüsü'});
  String get adComputerSubtitle => _t({'ku': 'خولی فێربوونی پڕۆگرامسازی بۆ ئاستی سەرەتایی', 'kbd': 'کۆرسێ فێربوونا پڕۆگرامسازی بۆ ئاستێ سەرەتایی', 'ar': 'دورة تعلم البرمجة للمبتدئين', 'en': 'Programming course for beginners', 'tr': 'Yeni başlayanlar için programlama kursu'});
  String get adComputerTag => _t({'ku': '💻 خولی نوێ', 'kbd': '💻 کۆرسێ نوێ', 'ar': '💻 دورة جديدة', 'en': '💻 New Course', 'tr': '💻 Yeni Kurs'});
  String get adAmericanTitle => _t({'ku': 'زانکۆی ئەمریکی', 'kbd': 'زانکۆیا ئەمریکی', 'ar': 'الجامعة الأمريكية', 'en': 'American University', 'tr': 'Amerikan Üniversitesi'});
  String get adAmericanSubtitle => _t({'ku': 'دەرگای پێشکەشکردن کرایەوە بۆ ساڵی نوێ', 'kbd': 'دەرگێ پێشکێشکرنی کرایە ڤەکرن بۆ سالا نوێ', 'ar': 'باب القبول مفتوح للعام الجديد', 'en': 'Admissions open for the new year', 'tr': 'Yeni yıl kayıtları açık'});
  String get adAmericanTag => _t({'ku': '🎓 زانکۆ', 'kbd': '🎓 زانکۆ', 'ar': '🎓 جامعة', 'en': '🎓 University', 'tr': '🎓 Üniversite'});

  // =====================
  // HOME DRAWER
  // =====================
  String get drawerStudent => _t({'ku': 'خوێندکار', 'kbd': 'قوتابی', 'ar': 'طالب', 'en': 'Student', 'tr': 'Öğrenci'});
  String get drawerSectionTools => _t({'ku': 'ئامرازەکان', 'kbd': 'ئامراز', 'ar': 'الأدوات', 'en': 'Tools', 'tr': 'Araçlar'});
  String get drawerPathFinder => _t({'ku': 'ڕێبەرە زیرەکەکەت', 'kbd': 'رێبەرێ زیرەک', 'ar': 'دليلك الذكي', 'en': 'Smart Guide', 'tr': 'Akıllı Rehber'});
  String get drawerPathFinderSub => _t({'ku': 'یارمەتیت دەدات بۆ هەڵبژاردنی بەش', 'kbd': 'یاریکارێ تە دکە ژ بۆ هەلبژاردنا پشکێ', 'ar': 'يساعدك في اختيار التخصص', 'en': 'Helps you choose your major', 'tr': 'Bölüm seçmende yardımcı olur'});
  String get drawerLostFound => _t({'ku': 'ونبوو و دۆزراوە', 'kbd': 'بەرزەبووی و دیتنی', 'ar': 'المفقودات', 'en': 'Lost & Found', 'tr': 'Kayıp & Bulunan'});
  String get drawerLostFoundSub => _t({'ku': 'شتێکت لێ ون بووە؟ لێرە بڵاوی بکەرەوە', 'kbd': 'تشتێک بەرزبوویە؟ لێرە بەلاڤی بکە', 'ar': 'فقدت شيئاً؟ انشر هنا', 'en': 'Lost something? Post it here', 'tr': 'Bir şey mi kaybettin? Burada paylaş'});
  String get drawerCv => _t({'ku': 'کۆچنووس (CV)', 'kbd': 'CVیا تە', 'ar': 'السيرة الذاتية', 'en': 'CV', 'tr': 'CV'});
  String get drawerCvSub => _t({'ku': 'دروستکردنی سیڤی تایبەت بە خۆت', 'kbd': 'درووستکرنا CVیەکێ تایبەت بۆ تە', 'ar': 'إنشاء سيرة ذاتية خاصة بك', 'en': 'Create your personal CV', 'tr': 'Kişisel CV oluştur'});
  String get drawerSectionSettings => _t({'ku': 'ڕێکخستنەکان', 'kbd': 'ڕێکخستن', 'ar': 'الإعدادات', 'en': 'Settings', 'tr': 'Ayarlar'});
  String get drawerTheme => _t({'ku': 'دۆخی تاریک و ڕووناک', 'kbd': 'مۆدێ تاریک و رووناک', 'ar': 'الوضع الداكن والفاتح', 'en': 'Dark & Light Mode', 'tr': 'Karanlık & Aydınlık Mod'});
  String get drawerChangeLanguage => _t({'ku': 'گۆڕینی زمان', 'kbd': 'گوهەرینا زمانی', 'ar': 'تغيير اللغة', 'en': 'Change Language', 'tr': 'Dil Değiştir'});
  String get drawerSectionInfo => _t({'ku': 'زانیاری', 'kbd': 'زانیاری', 'ar': 'معلومات', 'en': 'Info', 'tr': 'Bilgi'});
  String get drawerPrivacyPolicy => _t({'ku': 'سیاسەتی تایبەتمەندی', 'kbd': 'سیاسەتا تایبەتمەندیێ', 'ar': 'سياسة الخصوصية', 'en': 'Privacy Policy', 'tr': 'Gizlilik Politikası'});
  String get drawerAboutApp => _t({'ku': 'دەربارەی ئەپەکە', 'kbd': 'دەربارەی ئەپی', 'ar': 'حول التطبيق', 'en': 'About App', 'tr': 'Uygulama Hakkında'});
  String get drawerLogout => _t({'ku': 'چوونە دەرەوە', 'kbd': 'دەرکەتن', 'ar': 'تسجيل الخروج', 'en': 'Logout', 'tr': 'Çıkış'});

  // =====================
  // TEACHERS SCREEN
  // =====================
  String get teachersSubtitle => _t({'ku': 'باشترین مامۆستایانی پەسەندکراو', 'kbd': 'باشترین مامۆستەیێن پەسەندکراو', 'ar': 'أفضل المعلمين المعتمدين', 'en': 'Best approved teachers', 'tr': 'En iyi onaylı öğretmenler'});
  String get searchTeacherHint => _t({'ku': 'گەڕان بەدوای مامۆستا...', 'kbd': 'گەریان ب دواری مامۆستەیێ...', 'ar': 'ابحث عن معلم...', 'en': 'Search for a teacher...', 'tr': 'Öğretmen ara...'});
  String get filterByCity2 => _t({'ku': 'فلتەرکردن بەپێی شار', 'kbd': 'فلتەرکرن ل دویڤ باژێری', 'ar': 'تصفية حسب المدينة', 'en': 'Filter by City', 'tr': 'Şehre Göre Filtrele'});

  // =====================
  // TEACHER PROFILE SCREEN
  // =====================
  String teacherOf(String subject) => _t({'ku': 'مامۆستای $subject', 'kbd': 'مامۆستەیێ $subject', 'ar': 'أستاذ $subject', 'en': 'Teacher of $subject', 'tr': '$subject Öğretmeni'});
  String get educationSpecialization => _t({'ku': 'پسپۆڕی پەروەردە', 'kbd': 'پسپۆریا پەروەردەیێ', 'ar': 'متخصص في التعليم', 'en': 'Education Specialist', 'tr': 'Eğitim Uzmanı'});
  String get tileExperience => _t({'ku': 'ئەزموون', 'kbd': 'ئەزموون', 'ar': 'الخبرة', 'en': 'Experience', 'tr': 'Deneyim'});
  String get tileProvince => _t({'ku': 'پارێزگا', 'kbd': 'پارێزگا', 'ar': 'المحافظة', 'en': 'Province', 'tr': 'İl'});
  String get tileCurriculum => _t({'ku': 'مەنهەج', 'kbd': 'مەنهەج', 'ar': 'المنهج', 'en': 'Curriculum', 'tr': 'Müfredat'});
  String get yearsUnit => _t({'ku': 'ساڵ', 'kbd': 'سال', 'ar': 'سنة', 'en': 'yr', 'tr': 'yıl'});
  String get specializationFallback => _t({'ku': 'پسپۆڕی', 'kbd': 'پسپۆری', 'ar': 'تخصص', 'en': 'Specialty', 'tr': 'Uzmanlık'});
  String get curriculumSection => _t({'ku': 'کتێب و مەنهەج', 'kbd': 'کتێب و مەنهەج', 'ar': 'الكتاب والمنهج', 'en': 'Book & Curriculum', 'tr': 'Kitap & Müfredat'});
  String get curriculumCaption => _t({'ku': 'پوختەی مەنهەجی خوێندن بە شێوازێکی مۆدێرن لایەن مامۆستاوە ئامادەکراوە.', 'kbd': 'پوختەیا مەنهەجێ خوەندنێ بە شێوازێ مۆدێرن لا مامۆستایێ ئامادەکراوە.', 'ar': 'ملخص المنهج الدراسي أعده المعلم بأسلوب عصري.', 'en': 'Curriculum summary prepared by the teacher in a modern style.', 'tr': 'Öğretmen tarafından modern bir tarzda hazırlanan müfredat özeti.'});
  String get contactPhone => _t({'ku': 'پەیوەندی تەلەفۆنی', 'kbd': 'پەیوەندیا تەلەفۆنی', 'ar': 'اتصال هاتفي', 'en': 'Phone Call', 'tr': 'Telefon Ara'});
  String get contactWhatsapp => _t({'ku': 'نامەی واتساپ', 'kbd': 'نامەیا واتساپ', 'ar': 'واتساب', 'en': 'WhatsApp', 'tr': 'WhatsApp'});

  // =====================
  // CV SCREEN & DETAIL
  // =====================
  String get cvBankSubtitle => _t({'ku': 'بانکی سیڤی فەرمی خوێندکاران', 'kbd': 'بانکی سیڤیێن فەرمی قوتابیان', 'ar': 'بنك السيرة الذاتية الرسمي للطلاب', 'en': 'Official student CV bank', 'tr': 'Öğrencilerin resmi CV bankası'});
  String get searchCvHint => _t({'ku': 'گەڕان لە بانکی سیڤیەکان...', 'kbd': 'گەریان ل بانکی سیڤیان...', 'ar': 'ابحث في بنك السير الذاتية...', 'en': 'Search CV bank...', 'tr': 'CV bankasında ara...'});
  String get cvVerified => _t({'ku': 'پشکنراوە', 'kbd': 'پشکنراوە', 'ar': 'تم التحقق', 'en': 'Verified', 'tr': 'Doğrulandı'});

}


class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ku', 'kbd', 'ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
