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
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  String get languageCode => locale.languageCode;
  bool get isRTL => locale.languageCode == 'ku' || locale.languageCode == 'ar';

  String _t(Map<String, String> map) => map[locale.languageCode] ?? map['en'] ?? '';

  // =====================
  // APP GENERAL
  // =====================
  String get appName => _t({'ku': 'edu book', 'ar': 'edu book', 'en': 'edu book', 'tr': 'edu book'});
  String get appTagline => _t({'ku': 'پلاتفۆرمی پەروەردەی مۆدێرن', 'ar': 'منصة التعليم الحديثة', 'en': 'Modern Educational Platform', 'tr': 'Modern Eğitim Platformu'});
  String get loading => _t({'ku': 'چاوەڕوان بە...', 'ar': 'جاري التحميل...', 'en': 'Loading...', 'tr': 'Yükleniyor...'});
  String get error => _t({'ku': 'هەڵە', 'ar': 'خطأ', 'en': 'Error', 'tr': 'Hata'});
  String get retry => _t({'ku': 'دووبارە هەوڵ بدەرەوە', 'ar': 'أعد المحاولة', 'en': 'Retry', 'tr': 'Yeniden dene'});
  String get cancel => _t({'ku': 'هەڵوەشاندنەوە', 'ar': 'إلغاء', 'en': 'Cancel', 'tr': 'İptal'});
  String get save => _t({'ku': 'پاشەکەوت بکە', 'ar': 'حفظ', 'en': 'Save', 'tr': 'Kaydet'});
  String get done => _t({'ku': 'تەواوبوو', 'ar': 'تم', 'en': 'Done', 'tr': 'Tamamlandı'});
  String get next => _t({'ku': 'دواتر', 'ar': 'التالي', 'en': 'Next', 'tr': 'İleri'});
  String get back => _t({'ku': 'گەڕانەوە', 'ar': 'رجوع', 'en': 'Back', 'tr': 'Geri'});
  String get skip => _t({'ku': 'تێپەڕ بکە', 'ar': 'تخطي', 'en': 'Skip', 'tr': 'Atla'});
  String get search => _t({'ku': 'گەڕان', 'ar': 'بحث', 'en': 'Search', 'tr': 'Ara'});
  String get filter => _t({'ku': 'فلتەر', 'ar': 'تصفية', 'en': 'Filter', 'tr': 'Filtre'});
  String get seeAll => _t({'ku': 'هەموو ببینە', 'ar': 'مشاهدة الكل', 'en': 'See All', 'tr': 'Tümünü Gör'});
  String get noData => _t({'ku': 'زانیاری نییە', 'ar': 'لا توجد بيانات', 'en': 'No data found', 'tr': 'Veri bulunamadı'});
  String get submit => _t({'ku': 'ناردن', 'ar': 'إرسال', 'en': 'Submit', 'tr': 'Gönder'});
  String get required => _t({'ku': 'پێویستە', 'ar': 'مطلوب', 'en': 'Required', 'tr': 'Gerekli'});
  String get invalidEmail => _t({'ku': 'ئیمەیڵی نادروستە', 'ar': 'بريد إلكتروني غير صالح', 'en': 'Invalid email address', 'tr': 'Geçersiz e-posta'});
  String get passwordMinLength => _t({'ku': 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت', 'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'en': 'Password must be at least 6 characters', 'tr': 'Şifre en az 6 karakter olmalı'});
  String get passwordsDoNotMatch => _t({'ku': 'وشەی نهێنییەکان جیاوازن', 'ar': 'كلمتا المرور غير متطابقتين', 'en': 'Passwords do not match', 'tr': 'Şifreler eşleşmiyor'});
  String get registerFailed => _t({'ku': 'تۆمارکردن سەرکەوتوو نەبوو', 'ar': 'فشل التسجيل', 'en': 'Registration failed', 'tr': 'Kayıt başarısız'});
  String get optional => _t({'ku': 'ئارەزووی', 'ar': 'اختياري', 'en': 'Optional', 'tr': 'İsteğe bağlı'});
  String get viewDetails => _t({'ku': 'وردەکاریەکان ببینە', 'ar': 'عرض التفاصيل', 'en': 'View Details', 'tr': 'Detayları Gör'});

  // =====================
  // ONBOARDING
  // =====================
  String get onboardingTitle1 => _t({'ku': 'edu book بدۆزەرەوە', 'ar': 'اكتشف edu book', 'en': 'Discover edu book', 'tr': 'edu book\'u Keşfet'});
  String get onboardingDesc1 => _t({'ku': 'زانکۆ، قوتابخانە، و سەنتەرە پەروەردەییەکان بە ئاسانی بدۆزەرەوە', 'ar': 'اكتشف الجامعات والمدارس والمراكز التعليمية بسهولة', 'en': 'Discover universities, schools & educational centers easily', 'tr': 'Üniversiteleri, okulları ve eğitim merkezlerini kolayca keşfet'});
  String get onboardingTitle2 => _t({'ku': 'مامۆستا بدۆزەرەوە', 'ar': 'ابحث عن معلم', 'en': 'Find Your Teacher', 'tr': 'Öğretmenini Bul'});
  String get onboardingDesc2 => _t({'ku': 'مامۆستای تایبەتی و زانکۆیی بدۆزەرەوە بۆ وردکاری و پێشڕەوی خوێندنەکەت', 'ar': 'ابحث عن معلمين خاصين وجامعيين لتطوير مهاراتك', 'en': 'Find private & university teachers for your educational advancement', 'tr': 'Öğrenimi için özel ve üniversite öğretmenleri bul'});
  String get onboardingTitle3 => _t({'ku': 'CV بنێرە', 'ar': 'أرسل سيرتك الذاتية', 'en': 'Share Your CV', 'tr': 'CV\'ni Paylaş'});
  String get onboardingDesc3 => _t({'ku': 'CV خۆت دابنێ و دۆخی کارکردن بدۆزەرەوە', 'ar': 'أضف سيرتك الذاتية وابحث عن فرص العمل', 'en': 'Upload your CV and discover job opportunities', 'tr': 'CV\'ni yükle ve iş fırsatlarını keşfet'});
  String get onboardingTitle4 => _t({'ku': 'زمان هەڵبژێرە', 'ar': 'اختر اللغة', 'en': 'Choose Language', 'tr': 'Dil Seç'});
  String get onboardingDesc4 => _t({'ku': 'ئەپەکە بە ٤ زمان بەردەستە: کوردی، عەرەبی، ئینگلیزی، و تورکی', 'ar': 'التطبيق متاح بـ٤ لغات: كردي، عربي، إنجليزي، وتركي', 'en': 'The app supports 4 languages: Kurdish, Arabic, English, Turkish', 'tr': 'Uygulama 4 dili destekler: Kürtçe, Arapça, İngilizce, Türkçe'});
  String get getStarted => _t({'ku': 'دەستپێ بکە', 'ar': 'ابدأ الآن', 'en': 'Get Started', 'tr': 'Başla'});
  String get selectLanguage => _t({'ku': 'زمان هەڵبژێرە', 'ar': 'اختر اللغة', 'en': 'Select Language', 'tr': 'Dil Seç'});

  // =====================
  // AUTH
  // =====================
  String get login => _t({'ku': 'چوونەژوورەوە', 'ar': 'تسجيل الدخول', 'en': 'Login', 'tr': 'Giriş'});
  String get register => _t({'ku': 'تۆمارکردن', 'ar': 'التسجيل', 'en': 'Register', 'tr': 'Kayıt'});
  String get logout => _t({'ku': 'چوونەدەرەوە', 'ar': 'تسجيل الخروج', 'en': 'Logout', 'tr': 'Çıkış'});
  String get email => _t({'ku': 'ئیمەیڵ', 'ar': 'البريد الإلكتروني', 'en': 'Email', 'tr': 'E-posta'});
  String get password => _t({'ku': 'وشەی نهێنی', 'ar': 'كلمة المرور', 'en': 'Password', 'tr': 'Şifre'});
  String get confirmPassword => _t({'ku': 'دووبارەکردنەوەی وشەی نهێنی', 'ar': 'تأكيد كلمة المرور', 'en': 'Confirm Password', 'tr': 'Şifreyi Onayla'});
  String get name => _t({'ku': 'ناو', 'ar': 'الاسم', 'en': 'Name', 'tr': 'İsim'});
  String get fullName => _t({'ku': 'ناوی تەواو', 'ar': 'الاسم الكامل', 'en': 'Full Name', 'tr': 'Tam İsim'});
  String get phone => _t({'ku': 'ژمارەی مۆبایل', 'ar': 'رقم الهاتف', 'en': 'Phone Number', 'tr': 'Telefon Numarası'});
  String get forgotPassword => _t({'ku': 'وشەی نهێنیت لەبیرچووە؟', 'ar': 'نسيت كلمة المرور؟', 'en': 'Forgot Password?', 'tr': 'Şifremi Unuttum?'});
  String get noAccount => _t({'ku': 'هەژمارت نییە؟', 'ar': 'ليس لديك حساب؟', 'en': "Don't have an account?", 'tr': 'Hesabın yok mu?'});
  String get haveAccount => _t({'ku': 'هەژمارت هەیە؟', 'ar': 'لديك حساب؟', 'en': 'Already have an account?', 'tr': 'Hesabın var mı?'});
  String get loginSuccess => _t({'ku': 'بەخێربێیت!', 'ar': 'مرحباً!', 'en': 'Welcome back!', 'tr': 'Tekrar hoş geldin!'});
  String get loginFailed => _t({'ku': 'ئیمەیڵ یان وشەی نهێنی هەڵەیە', 'ar': 'البريد أو كلمة المرور غير صحيحة', 'en': 'Incorrect email or password', 'tr': 'E-posta veya şifre hatalı'});
  String get registerSuccess => _t({'ku': 'هەژمارت دروست کرا!', 'ar': 'تم إنشاء حسابك!', 'en': 'Account created!', 'tr': 'Hesabın oluşturuldu!'});
  String get sendOtp => _t({'ku': 'کۆدی پشتڕاستکردنەوە بنێرە', 'ar': 'إرسال رمز التحقق', 'en': 'Send OTP Code', 'tr': 'Doğrulama Kodu Gönder'});
  String get enterOtp => _t({'ku': 'کۆدی نێردراو بنووسە', 'ar': 'أدخل الرمز المرسل', 'en': 'Enter the code sent', 'tr': 'Gönderilen kodu gir'});
  String get resendOtp => _t({'ku': 'کۆد دووبارە بنێرە', 'ar': 'إعادة إرسال الرمز', 'en': 'Resend Code', 'tr': 'Kodu Yeniden Gönder'});
  String get resetPassword => _t({'ku': 'وشەی نهێنی نوێ بکەرەوە', 'ar': 'إعادة تعيين كلمة المرور', 'en': 'Reset Password', 'tr': 'Şifreyi Sıfırla'});
  String get orContinueWith => _t({'ku': 'یان بەردەوام بکە بە', 'ar': 'أو تابع مع', 'en': 'Or continue with', 'tr': 'Ya da şununla devam et'});

  // =====================
  // HOME
  // =====================
  String get home => _t({'ku': 'سەرەکی', 'ar': 'الرئيسية', 'en': 'Home', 'tr': 'Ana Sayfa'});
  String get welcome => _t({'ku': 'بەخێربێی', 'ar': 'مرحباً', 'en': 'Welcome', 'tr': 'Hoş Geldin'});
  String get featuredInstitutions => _t({'ku': 'خوێندنگاکانی تایبەت', 'ar': 'المؤسسات المميزة', 'en': 'Featured Institutions', 'tr': 'Öne Çıkan Kurumlar'});
  String get categories => _t({'ku': 'جۆرەکان', 'ar': 'الفئات', 'en': 'Categories', 'tr': 'Kategoriler'});
  String get statistics => _t({'ku': 'ئامارەکان', 'ar': 'الإحصائيات', 'en': 'Statistics', 'tr': 'İstatistikler'});
  String get recentUpdates => _t({'ku': 'نوێترین نوێکردنەوەکان', 'ar': 'آخر التحديثات', 'en': 'Recent Updates', 'tr': 'Son Güncellemeler'});
  String get searchHint => _t({'ku': 'خوێندنگا بگەڕێ...', 'ar': 'ابحث عن مؤسسة...', 'en': 'Search institutions...', 'tr': 'Kurum ara...'});
  String get goodMorning => _t({'ku': 'بەیانیت باش', 'ar': 'صباح الخير', 'en': 'Good Morning', 'tr': 'Günaydın'});
  String get goodAfternoon => _t({'ku': 'نیوەڕۆت باش', 'ar': 'مساء الخير', 'en': 'Good Afternoon', 'tr': 'İyi Öğlenler'});
  String get goodEvening => _t({'ku': 'ئێوارەت باش', 'ar': 'مساء الخير', 'en': 'Good Evening', 'tr': 'İyi Akşamlar'});

  // =====================
  // INSTITUTIONS
  // =====================
  String get institutions => _t({'ku': 'خوێندنگاکان', 'ar': 'المؤسسات', 'en': 'Institutions', 'tr': 'Kurumlar'});
  String get institutionTypes => _t({'ku': 'جۆرەکان', 'ar': 'الأنواع', 'en': 'Types', 'tr': 'Türler'});
  String get university => _t({'ku': 'زانکۆ', 'ar': 'جامعة', 'en': 'University', 'tr': 'Üniversite'});
  String get institute => _t({'ku': 'ئینستیتیوت', 'ar': 'معهد', 'en': 'Institute', 'tr': 'Enstitü'});
  String get school => _t({'ku': 'قوتابخانە', 'ar': 'مدرسة', 'en': 'School', 'tr': 'Okul'});
  String get kindergarten => _t({'ku': 'باخچەی منداڵان', 'ar': 'روضة', 'en': 'Kindergarten', 'tr': 'Anaokulu'});
  String get languageCenter => _t({'ku': 'سەنتەری زمان', 'ar': 'مركز لغات', 'en': 'Language Center', 'tr': 'Dil Merkezi'});
  String get city => _t({'ku': 'شار', 'ar': 'المدينة', 'en': 'City', 'tr': 'Şehir'});
  String get country => _t({'ku': 'وڵات', 'ar': 'البلد', 'en': 'Country', 'tr': 'Ülke'});
  String get address => _t({'ku': 'ناونیشان', 'ar': 'العنوان', 'en': 'Address', 'tr': 'Adres'});
  String get website => _t({'ku': 'مەلپەر', 'ar': 'الموقع', 'en': 'Website', 'tr': 'Web Sitesi'});
  String get gallery => _t({'ku': 'گالەری', 'ar': 'معرض الصور', 'en': 'Gallery', 'tr': 'Galeri'});
  String get location => _t({'ku': 'شوێن', 'ar': 'الموقع', 'en': 'Location', 'tr': 'Konum'});
  String get socialMedia => _t({'ku': 'تۆرە کۆمەڵایەتییەکان', 'ar': 'وسائل التواصل', 'en': 'Social Media', 'tr': 'Sosyal Medya'});
  String get description => _t({'ku': 'وەسف', 'ar': 'الوصف', 'en': 'Description', 'tr': 'Açıklama'});
  String get contact => _t({'ku': 'پەیوەندی', 'ar': 'التواصل', 'en': 'Contact', 'tr': 'İletişim'});
  String get openMap => _t({'ku': 'نەخشە بکەرەوە', 'ar': 'فتح الخريطة', 'en': 'Open Map', 'tr': 'Haritayı Aç'});
  String get addToFavorites => _t({'ku': 'زیادکردن بۆ دڵخوازەکان', 'ar': 'إضافة للمفضلة', 'en': 'Add to Favorites', 'tr': 'Favorilere Ekle'});
  String get removeFromFavorites => _t({'ku': 'لەناو دڵخوازەکان بکە', 'ar': 'إزالة من المفضلة', 'en': 'Remove from Favorites', 'tr': 'Favorilerden Kaldır'});
  String get favorites => _t({'ku': 'دڵخوازەکان', 'ar': 'المفضلة', 'en': 'Favorites', 'tr': 'Favoriler'});
  String get colleges => _t({'ku': 'کۆلێجەکان', 'ar': 'الكليات', 'en': 'Colleges', 'tr': 'Fakülteler'});
  String get departments => _t({'ku': 'بەشەکان', 'ar': 'الأقسام', 'en': 'Departments', 'tr': 'Bölümler'});
  String get sortBy => _t({'ku': 'ریزکردنی بەپێی', 'ar': 'ترتيب حسب', 'en': 'Sort By', 'tr': 'Sırala'});
  String get newest => _t({'ku': 'نوێترین', 'ar': 'الأحدث', 'en': 'Newest', 'tr': 'En Yeni'});
  String get filterByCity => _t({'ku': 'فلتەر بەپێی شار', 'ar': 'تصفية حسب المدينة', 'en': 'Filter by City', 'tr': 'Şehre Göre Filtrele'});
  String get filterByType => _t({'ku': 'فلتەر بەپێی جۆر', 'ar': 'تصفية حسب النوع', 'en': 'Filter by Type', 'tr': 'Türe Göre Filtrele'});
  String get allTypes => _t({'ku': 'هەموو جۆرەکان', 'ar': 'جميع الأنواع', 'en': 'All Types', 'tr': 'Tüm Türler'});
  String get allCities => _t({'ku': 'هەموو شارەکان', 'ar': 'جميع المدن', 'en': 'All Cities', 'tr': 'Tüm Şehirler'});
  String get report => _t({'ku': 'ڕاپۆرت', 'ar': 'إبلاغ', 'en': 'Report', 'tr': 'Şikayet Et'});

  // =====================
  // TEACHERS
  // =====================
  String get teachers => _t({'ku': 'مامۆستایان', 'ar': 'المعلمون', 'en': 'Teachers', 'tr': 'Öğretmenler'});
  String get myTeachers => _t({'ku': 'مامۆستاکانم', 'ar': 'معلموني', 'en': 'My Teachers', 'tr': 'Öğretmenlerim'});
  String get privateTeacher => _t({'ku': 'مامۆستای تایبەت', 'ar': 'معلم خاص', 'en': 'Private Teacher', 'tr': 'Özel Öğretmen'});
  String get universityTeacher => _t({'ku': 'مامۆستای زانکۆ', 'ar': 'معلم جامعي', 'en': 'University Teacher', 'tr': 'Üniversite Öğretmeni'});
  String get schoolTeacher => _t({'ku': 'مامۆستای قوتابخانە', 'ar': 'معلم مدرسة', 'en': 'School Teacher', 'tr': 'Okul Öğretmeni'});
  String get experience => _t({'ku': 'ئەزموون', 'ar': 'الخبرة', 'en': 'Experience', 'tr': 'Deneyim'});
  String get experienceYears => _t({'ku': 'ساڵی ئەزموون', 'ar': 'سنوات الخبرة', 'en': 'Years of Experience', 'tr': 'Deneyim Yılı'});
  String get hourlyRate => _t({'ku': 'کرێی هەر کاتژمێر', 'ar': 'الأجر في الساعة', 'en': 'Hourly Rate', 'tr': 'Saatlik Ücret'});
  String get about => _t({'ku': 'دەربارەی', 'ar': 'عن', 'en': 'About', 'tr': 'Hakkında'});
  String get subject => _t({'ku': 'بابەت', 'ar': 'المادة', 'en': 'Subject', 'tr': 'Ders'});
  String get rating => _t({'ku': 'هەڵسەنگاندن', 'ar': 'التقييم', 'en': 'Rating', 'tr': 'Değerlendirme'});
  String get reviews => _t({'ku': 'ڕێکردنەوەکان', 'ar': 'التقييمات', 'en': 'Reviews', 'tr': 'İncelemeler'});
  String get bookTeacher => _t({'ku': 'مامۆستا بووکبکە', 'ar': 'احجز معلم', 'en': 'Book Teacher', 'tr': 'Öğretmen Rezerve Et'});
  String get contactTeacher => _t({'ku': 'پەیوەندی بکە', 'ar': 'تواصل معه', 'en': 'Contact', 'tr': 'İletişim Kur'});
  String get registerAsTeacher => _t({'ku': 'وەک مامۆستا تۆمار بکە', 'ar': 'سجل كمعلم', 'en': 'Register as Teacher', 'tr': 'Öğretmen Olarak Kayıt'});
  String get biography => _t({'ku': 'بیۆگرافی', 'ar': 'السيرة الذاتية المختصرة', 'en': 'Biography', 'tr': 'Biyografi'});
  String get subjects => _t({'ku': 'بابەتەکان', 'ar': 'المواد', 'en': 'Subjects', 'tr': 'Dersler'});

  // =====================
  // CV
  // =====================
  String get cvBank => _t({'ku': 'سیڤیەکان', 'ar': 'السیرة الذاتیة', 'en': 'CV Bank', 'tr': 'CV Bankası'});
  String get uploadCv => _t({'ku': 'CV بنێرە', 'ar': 'رفع السيرة الذاتية', 'en': 'Upload CV', 'tr': 'CV Yükle'});
  String get createCv => _t({'ku': 'CV دروست بکە', 'ar': 'إنشاء سيرة ذاتية', 'en': 'Create CV', 'tr': 'CV Oluştur'});
  String get jobOpportunities => _t({'ku': 'دۆخی کار', 'ar': 'فرص العمل', 'en': 'Job Opportunities', 'tr': 'İş Fırsatları'});
  String get applyNow => _t({'ku': 'ئێستا داواکاری بکە', 'ar': 'قدم الآن', 'en': 'Apply Now', 'tr': 'Şimdi Başvur'});
  String get education => _t({'ku': 'خوێندن', 'ar': 'التعليم', 'en': 'Education', 'tr': 'Eğitim'});
  String get skills => _t({'ku': 'تواناکان', 'ar': 'المهارات', 'en': 'Skills', 'tr': 'Beceriler'});
  String get graduationYear => _t({'ku': 'ساڵی دەرچوون', 'ar': 'سنة التخرج', 'en': 'Graduation Year', 'tr': 'Mezuniyet Yılı'});
  String get field => _t({'ku': 'بوار', 'ar': 'التخصص', 'en': 'Field of Study', 'tr': 'Çalışma Alanı'});
  String get educationLevel => _t({'ku': 'ئاستی خوێندن', 'ar': 'المستوى التعليمي', 'en': 'Education Level', 'tr': 'Eğitim Seviyesi'});
  String get age => _t({'ku': 'تەمەن', 'ar': 'العمر', 'en': 'Age', 'tr': 'Yaş'});
  String get gender => _t({'ku': 'رەگەز', 'ar': 'الجنس', 'en': 'Gender', 'tr': 'Cinsiyet'});
  String get male => _t({'ku': 'نێر', 'ar': 'ذكر', 'en': 'Male', 'tr': 'Erkek'});
  String get female => _t({'ku': 'مێ', 'ar': 'أنثى', 'en': 'Female', 'tr': 'Kadın'});
  String get notes => _t({'ku': 'تێبینی', 'ar': 'ملاحظات', 'en': 'Notes', 'tr': 'Notlar'});
  String get saveCv => _t({'ku': 'CV پاشەکەوت بکە', 'ar': 'حفظ السيرة الذاتية', 'en': 'Save CV', 'tr': 'CV Kaydet'});

  // =====================
  // NOTIFICATIONS
  // =====================
  String get notifications => _t({'ku': 'ئاگادارکردنەوەکان', 'ar': 'الإشعارات', 'en': 'Notifications', 'tr': 'Bildirimler'});
  String get noNotifications => _t({'ku': 'ئاگادارکردنەوە نییە', 'ar': 'لا توجد إشعارات', 'en': 'No notifications', 'tr': 'Bildirim yok'});
  String get markAllRead => _t({'ku': 'هەموو وەک خوێندراو دیاریبکە', 'ar': 'تحديد الكل كمقروء', 'en': 'Mark All Read', 'tr': 'Tümünü Okundu İşaretle'});
  String get newInstitution => _t({'ku': 'خوێندنگای نوێ', 'ar': 'مؤسسة جديدة', 'en': 'New Institution', 'tr': 'Yeni Kurum'});

  // =====================
  // PROFILE & SETTINGS
  // =====================
  String get profile => _t({'ku': 'پرۆفایل', 'ar': 'الملف الشخصي', 'en': 'Profile', 'tr': 'Profil'});
  String get settings => _t({'ku': 'ڕێکخستنەکان', 'ar': 'الإعدادات', 'en': 'Settings', 'tr': 'Ayarlar'});
  String get editProfile => _t({'ku': 'پرۆفایل دەستکاری بکە', 'ar': 'تعديل الملف', 'en': 'Edit Profile', 'tr': 'Profili Düzenle'});
  String get language => _t({'ku': 'زمان', 'ar': 'اللغة', 'en': 'Language', 'tr': 'Dil'});
  String get darkMode => _t({'ku': 'دۆخی تاریک', 'ar': 'الوضع الداكن', 'en': 'Dark Mode', 'tr': 'Karanlık Mod'});
  String get lightMode => _t({'ku': 'دۆخی ڕووناک', 'ar': 'الوضع الفاتح', 'en': 'Light Mode', 'tr': 'Aydınlık Mod'});
  String get appearance => _t({'ku': 'دیمەن', 'ar': 'المظهر', 'en': 'Appearance', 'tr': 'Görünüm'});
  String get privacy => _t({'ku': 'پاراستنی نهێنی', 'ar': 'الخصوصية', 'en': 'Privacy', 'tr': 'Gizlilik'});
  String get security => _t({'ku': 'ئەمنیەت', 'ar': 'الأمان', 'en': 'Security', 'tr': 'Güvenlik'});
  String get help => _t({'ku': 'یارمەتی', 'ar': 'المساعدة', 'en': 'Help', 'tr': 'Yardım'});
  String get about2 => _t({'ku': 'دەربارەی ئەپ', 'ar': 'حول التطبيق', 'en': 'About App', 'tr': 'Uygulama Hakkında'});
  String get savedItems => _t({'ku': 'گیراوەکان', 'ar': 'المحفوظات', 'en': 'Saved Items', 'tr': 'Kaydedilenler'});
  String get version => _t({'ku': 'وەشان', 'ar': 'الإصدار', 'en': 'Version', 'tr': 'Sürüm'});
  String get logoutConfirm => _t({'ku': 'دڵنیایت لە چوونەدەرەوە؟', 'ar': 'هل أنت متأكد من تسجيل الخروج؟', 'en': 'Are you sure you want to logout?', 'tr': 'Çıkış yapmak istediğinden emin misin?'});
  String get notificationSettings => _t({'ku': 'ڕێکخستنی ئاگادارکردنەوەکان', 'ar': 'إعدادات الإشعارات', 'en': 'Notification Settings', 'tr': 'Bildirim Ayarları'});
  String get enableNotifications => _t({'ku': 'ئاگادارکردنەوەکان چالاک بکە', 'ar': 'تفعيل الإشعارات', 'en': 'Enable Notifications', 'tr': 'Bildirimleri Etkinleştir'});

  // STATS
  // EXTRA STRINGS
  String get featured => _t({'ku': 'تایبەت', 'ar': 'مميز', 'en': 'Featured', 'tr': 'Öne Çıkan'});
  String get recent => _t({'ku': 'نوێترین', 'ar': 'الأحدث', 'en': 'Recent', 'tr': 'Son'});
  String get noResults => _t({'ku': 'ئەنجام نییە', 'ar': 'لا توجد نتائج', 'en': 'No results found', 'tr': 'Sonuç bulunamadı'});
  String get years => _t({'ku': 'ساڵ', 'ar': 'سنة', 'en': 'Years', 'tr': 'Yıl'});
  String get loginToSeeNotifications => _t({'ku': 'داخڵ بوو بۆ بینینی ئاگادارکردنەوەکان', 'ar': 'سجل دخول لرؤية الإشعارات', 'en': 'Login to see notifications', 'tr': 'Bildirimleri görmek için giriş yap'});
  String get savedInstitutions => _t({'ku': 'خوێندنگاکانی گیراو', 'ar': 'المؤسسات المحفوظة', 'en': 'Saved Institutions', 'tr': 'Kaydedilen Kurumlar'});
  String get noFavorites => _t({'ku': 'هیچ خوێندنگێکت گیراو نییە', 'ar': 'لم تحفظ أي مؤسسة بعد', 'en': 'No saved institutions yet', 'tr': 'Henüz kaydedilen kurum yok'});
  String get browseInstitutions => _t({'ku': 'خوێندنگاکان ببینە', 'ar': 'تصفح المؤسسات', 'en': 'Browse Institutions', 'tr': 'Kurumları Gezin'});
  String get saved => _t({'ku': 'گیراوەکان', 'ar': 'المحفوظات', 'en': 'Saved', 'tr': 'Kaydedilenler'});
  String get guest => _t({'ku': 'میوان', 'ar': 'ضيف', 'en': 'Guest', 'tr': 'Misafir'});
  String get teacherRegisterSuccess => _t({'ku': 'داواکاریت بە سەرکەوتوویی نێردرا، بچاوە ڕاگەیەنراوەکانت', 'ar': 'تم إرسال طلبك بنجاح، انتظر الموافقة', 'en': 'Your request was submitted. Await approval.', 'tr': 'Talebiniz gönderildi. Onay bekleyin.'});
  String get cvSubmitSuccess => _t({'ku': 'CV ت بە سەرکەوتوویی نێردرا', 'ar': 'تم رفع سيرتك الذاتية بنجاح', 'en': 'Your CV was submitted successfully', 'tr': 'CV\'niz başarıyla gönderildi'});
  String get successTitle => _t({'ku': 'سەرکەوتوو بوو! ✅', 'ar': 'تم بنجاح! ✅', 'en': 'Success! ✅', 'tr': 'Başarılı! ✅'});
  String get personalInfo => _t({'ku': 'زانیاری کەسی', 'ar': 'المعلومات الشخصية', 'en': 'Personal Info', 'tr': 'Kişisel Bilgiler'});
  String get fieldOfStudy => _t({'ku': 'بواری خوێندن', 'ar': 'مجال الدراسة', 'en': 'Field of Study', 'tr': 'Çalışma Alanı'});
  String get subjectPhoto => _t({'ku': 'وێنەی بابەت', 'ar': 'صورة المادة', 'en': 'Subject Photo', 'tr': 'Ders Fotoğrafı'});
  String get teacherType => _t({'ku': 'جۆری مامۆستا', 'ar': 'نوع المعلم', 'en': 'Teacher Type', 'tr': 'Öğretmen Türü'});
  String get privacyPolicy => _t({'ku': 'سیاسەتی نهێنی', 'ar': 'سياسة الخصوصية', 'en': 'Privacy Policy', 'tr': 'Gizlilik Politikası'});
  String get helpCenter => _t({'ku': 'ناوەندی یارمەتی', 'ar': 'مركز المساعدة', 'en': 'Help Center', 'tr': 'Yardım Merkezi'});
  String get contactInfo => _t({'ku': 'زانیاری پەیوەندی', 'ar': 'معلومات الاتصال', 'en': 'Contact Info', 'tr': 'İletişim Bilgileri'});
  String get social => _t({'ku': 'تۆرە کۆمەڵایەتییەکان', 'ar': 'التواصل الاجتماعي', 'en': 'Social Media', 'tr': 'Sosyal Medya'});
  String get profilePhoto => _t({'ku': 'وێنەی پرۆفایل', 'ar': 'صورة الملف', 'en': 'Profile Photo', 'tr': 'Profil Fotoğrafı'});
  String get all => _t({'ku': 'هەموو', 'ar': 'الكل', 'en': 'All', 'tr': 'Tümü'});
  String get stats => _t({'ku': 'ئامارەکان', 'ar': 'الإحصائيات', 'en': 'Statistics', 'tr': 'İstatistikler'});

  String get totalInstitutions => _t({'ku': 'کۆی خوێندنگاکان', 'ar': 'إجمالي المؤسسات', 'en': 'Total Institutions', 'tr': 'Toplam Kurum'});
  String get totalTeachers => _t({'ku': 'کۆی مامۆستایان', 'ar': 'إجمالي المعلمين', 'en': 'Total Teachers', 'tr': 'Toplam Öğretmen'});
  String get totalCvs => _t({'ku': 'کۆی CVکان', 'ar': 'إجمالي السير الذاتية', 'en': 'Total CVs', 'tr': 'Toplam CV'});
  String get cities => _t({'ku': 'شارەکان', 'ar': 'المدن', 'en': 'Cities', 'tr': 'Şehirler'});
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ku', 'ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
