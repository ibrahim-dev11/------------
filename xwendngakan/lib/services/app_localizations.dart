import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class S {
  static String of(BuildContext context, String key, [Map<String, String>? params]) {
    final lang = context.read<AppProvider>().language;
    return get(lang, key, params);
  }

  static String get(String lang, String key, [Map<String, String>? params]) {
    String? text = _translations[key]?[lang];
    if (text == null && (lang == 'tr' || lang == 'fr')) {
      text = _translations[key]?['en'];
    }
    text ??= _translations[key]?['ku'] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text!.replaceAll('{$k}', v);
      });
    }
    return text!;
  }

  static const Map<String, Map<String, String>> _translations = {
    // ─── App ───
    'appName': {
      'ku': 'خوێندنگاکانم',
      'ar': 'مؤسساتي التعليمية',
      'en': 'My Schools',
      'tr': 'Okullarım',
      'fr': 'Mes Écoles',
    },

    // ─── Nav ───
    'navHome': {
      'ku': 'سەرەکی',
      'ar': 'الرئيسية',
      'en': 'Home',
      'tr': 'Ana Sayfa',
      'fr': 'Accueil',
    },
    'navSearch': {
      'ku': 'گەڕان',
      'ar': 'بحث',
      'en': 'Search',
      'tr': 'Arama',
      'fr': 'Recherche',
    },
    'navRegister': {
      'ku': 'تۆمارکردن',
      'ar': 'تسجيل',
      'en': 'Register',
      'tr': 'Kayıt',
      'fr': 'Inscrire',
    },
    'navSettings': {
      'ku': 'ڕێکخستن',
      'ar': 'الإعدادات',
      'en': 'Settings',
      'tr': 'Ayarlar',
      'fr': 'Paramètres',
    },
    'navMap': {
      'ku': 'نەخشە',
      'ar': 'الخريطة',
      'en': 'Map',
      'tr': 'Harita',
      'fr': 'Carte',
    },
    'mapView': {
      'ku': 'نەخشەی دامەزراوەکان',
      'ar': 'خريطة المؤسسات',
      'en': 'Institutions Map',
 
      'tr': 'Kurumlar Haritası',
      'fr': 'Carte des Établissements',
    },
    'all': {
      'ku': 'هەمووی',
      'ar': 'الكل',
      'en': 'All',
 
      'tr': 'Hepsi',
      'fr': 'Tous',
    },
    'unknown': {
      'ku': 'نادیار',
      'ar': 'غير معروف',
      'en': 'Unknown',
 
      'tr': 'Bilinmiyor',
      'fr': 'Inconnu',
    },

    // ─── Home ───
    'defaultUser': {
      'ku': 'بەکارهێنەر',
      'ar': 'مستخدم',
      'en': 'User',
 
      'tr': 'Kullanıcı',
      'fr': 'Utilisateur',
    },
    'institution': {
      'ku': 'دامەزراوە',
      'ar': 'مؤسسة',
      'en': 'institution',
 
      'tr': 'kurum',
      'fr': 'établissement',
    },
    'searchInInstitutions': {
      'ku': 'گەڕان لە نێو {count} دامەزراوە...',
      'ar': 'البحث في {count} مؤسسة...',
      'en': 'Search in {count} institutions...',
      'tr': '{count} kurum içinde ara...',
      'fr': 'Rechercher dans {count} établissements...',
    },
    'noResults': {
      'ku': 'هیچ ئەنجامێک نەدۆزرایەوە',
      'ar': 'لم يتم العثور على نتائج',
      'en': 'No results found',
 
      'tr': 'Sonuç bulunamadı',
      'fr': 'Aucun résultat trouvé',
    },
    'changeFilters': {
      'ku': 'فلتەرەکان بگۆڕە یان بە ناوێکی تر بگەڕێ',
      'ar': 'غيّر الفلاتر أو ابحث باسم آخر',
      'en': 'Change filters or search with another name',
 
      'tr': 'Filtreleri değiştir veya farklı bir isimle ara',
      'fr': 'Changer les filtres ou rechercher avec un autre nom',
    },
    'clearFilters': {
      'ku': 'پاککردنەوەی فلتەرەکان',
      'ar': 'مسح الفلاتر',
      'en': 'Clear filters',
 
      'tr': 'Filtreleri Temizle',
      'fr': 'Effacer les filtres',
    },
    'filter': {
      'ku': 'فلتەرکردن',
      'ar': 'تصفية',
      'en': 'Filter',
 
      'tr': 'Filtrele',
      'fr': 'Filtrer',
    },
    'findFavorite': {
      'ku': 'دۆزینەوەی خوێندنگای دڵخواز',
      'ar': 'ابحث عن مؤسستك المفضلة',
      'en': 'Find your favorite institution',
 
      'tr': 'Favori kurumunu bul',
      'fr': 'Trouvez votre établissement favori',
    },
    'clear': {
      'ku': 'پاککردنەوە',
      'ar': 'مسح',
      'en': 'Clear',
 
      'tr': 'Temizle',
      'fr': 'Effacer',
    },
    'institutionType': {
      'ku': 'جۆری دامەزراوە',
      'ar': 'نوع المؤسسة',
      'en': 'Institution type',
 
      'tr': 'Kurum Türü',
      'fr': 'Type d\'établissement',
    },
    'allTypes': {
      'ku': 'هەموو جۆرەکان',
      'ar': 'جميع الأنواع',
      'en': 'All types',
 
      'tr': 'Tüm Türler',
      'fr': 'Tous les types',
    },
    'city': {
      'ku': 'شار',
      'ar': 'مدينة',
      'en': 'City',
 
      'tr': 'Şehir',
      'fr': 'Ville',
    },
    'allCities': {
      'ku': 'هەموو شارەکان',
      'ar': 'جميع المدن',
      'en': 'All cities',
 
      'tr': 'Tüm Şehirler',
      'fr': 'Toutes les villes',
    },
    'apply': {
      'ku': 'جێبەجێکردن',
      'ar': 'تطبيق',
      'en': 'Apply',
 
      'tr': 'Uygula',
      'fr': 'Appliquer',
    },

  
'greeting': {
      'ku': 'سڵاو',
      'ar': 'مرحباً',
      'en': 'Hello',
      'tr': 'Merhaba',
      'fr': 'Bonjour',
    },    'greetingSubtitle': {
      'ku': 'خوێندنگای دڵخوازت بدۆزەوە',
      'ar': 'ابحث عن مؤسستك المفضلة',
      'en': 'Find your favorite institution',
 
      'tr': 'Favori kurumunu bul',
      'fr': 'Trouvez votre établissement favori',
    },

    // ─── Search ───
    'searchHint': {
      'ku': 'ناوی خوێندنگا بنووسە...',
      'ar': 'اكتب اسم المؤسسة...',
      'en': 'Type institution name...',
 
      'tr': 'Kurum adı gir...',
      'fr': 'Saisissez le nom de l\'établissement...',
    },
    'popularSearches': {
      'ku': 'گەڕانی باو',
      'ar': 'عمليات بحث شائعة',
      'en': 'Popular searches',
 
      'tr': 'Popüler Aramalar',
      'fr': 'Recherches populaires',
    },
    'categories': {
      'ku': 'جۆرەکان',
      'ar': 'الأنواع',
      'en': 'Categories',
 
      'tr': 'Kategoriler',
      'fr': 'Catégories',
    },
    'featured': {
      'ku': 'هەڵبژێردراو',
      'ar': 'مميز',
      'en': 'Featured',
 
      'tr': 'Öne Çıkan',
      'fr': 'À la une',
    },
    'seeAll': {
      'ku': 'هەموو ببینە',
      'ar': 'عرض الكل',
      'en': 'See all',
 
      'tr': 'Hepsini Gör',
      'fr': 'Voir tout',
    },
    'searchDifferent': {
      'ku': 'بە وشەیەکی تر بگەڕێ',
      'ar': 'ابحث بكلمة أخرى',
      'en': 'Try a different search',
 
      'tr': 'Farklı bir kelimeyle ara',
      'fr': 'Chercher avec un autre mot',
    },
    'resultCount': {
      'ku': '{count} ئەنجام',
      'ar': '{count} نتيجة',
      'en': '{count} results',
      'tr': '{count} sonuç',
      'fr': '{count} résultats',
    },

    // ─── Settings ───
    'settings': {
      'ku': 'ڕێکخستنەکان',
      'ar': 'الإعدادات',
      'en': 'Settings',
      'tr': 'Ayarlar',
      'fr': 'Paramètres',
    },
    'appearance': {
      'ku': 'ڕووکار',
      'ar': 'المظهر',
      'en': 'Appearance',
      'tr': 'Görünüm',
      'fr': 'Apparence',
    },
    'darkMode': {
      'ku': 'دۆخی تاریک',
      'ar': 'الوضع الداكن',
      'en': 'Dark mode',
      'tr': 'Karanlık Mod',
      'fr': 'Mode sombre',
    },
    'lightMode': {
      'ku': 'دۆخی ڕوناک',
      'ar': 'الوضع الفاتح',
      'en': 'Light mode',
      'tr': 'Açık Mod',
      'fr': 'Mode clair',
    },
    'changeAppTheme': {
      'ku': 'گۆڕینی ڕووکاری ئەپلیکەیشن',
      'ar': 'تغيير مظهر التطبيق',
      'en': 'Change app theme',
 
      'tr': 'Uygulama temasını değiştir',
      'fr': 'Changer le thème de l\'application',
    },
    'about': {
      'ku': 'دەربارە',
      'ar': 'حول',
      'en': 'About',
 
      'tr': 'Hakkında',
      'fr': 'À propos',
    },
    'appDescription': {
      'ku': 'ئەم ئەپلیکەیشنە دلیلێکی گشتگیرە بۆ هەموو دامەزراوە پەروەردەیی و خوێندنییەکانی عێراق و کوردستان. لێرەوە دەتوانیت زانکۆ، پەیمانگە، قوتابخانە، باخچەی منداڵان و زۆر شتی تر ببینیت و بەراوردیان بکەیت.',
      'ar': 'هذا التطبيق دليل شامل لجميع المؤسسات التعليمية في العراق وكوردستان. يمكنك من هنا مشاهدة ومقارنة الجامعات والمعاهد والمدارس ورياض الأطفال وأكثر.',
      'en': 'This app is a comprehensive guide for all educational institutions in Iraq and Kurdistan. Here you can view and compare universities, institutes, schools, kindergartens and more.',
 
      'tr': 'Bu uygulama, Irak ve Kürdistan\'daki tüm eğitim kurumları için kapsamlı bir rehberdir.',
      'fr': 'Cette application est un guide complet de tous les établissements d\'enseignement en Irak et au Kurdistan.',
    },
    'developer': {
      'ku': 'گەشەپێدەر',
      'ar': 'المطور',
      'en': 'Developer',
 
      'tr': 'Geliştirici',
      'fr': 'Développeur',
    },
    'language': {
      'ku': 'زمان',
      'ar': 'اللغة',
      'en': 'Language',
      'tr': 'Dil',
      'fr': 'Langue',
    },
    'chooseLanguage': {
      'ku': 'زمان هەڵبژێرە',
      'ar': 'اختر اللغة',
      'en': 'Choose language',
      'tr': 'Dil Seç',
      'fr': 'Choisir la langue',
    },
    'kurdish': {
      'ku': 'کوردی',
      'ar': 'الكوردية',
      'en': 'Kurdish',
      'tr': 'Kürtçe',
      'fr': 'Kurde',
    },
    'arabic': {
      'ku': 'العربية',
      'ar': 'العربية',
      'en': 'Arabic',
      'tr': 'Arapça',
      'fr': 'Arabe',
    },
    'english': {
      'ku': 'English',
      'ar': 'الإنجليزية',
      'en': 'English',
      'tr': 'İngilizce',
      'fr': 'Anglais',
    },
    'active': {
      'ku': 'چالاک',
      'ar': 'نشط',
      'en': 'Active',
 
      'tr': 'Aktif',
      'fr': 'Actif',
    },
    'notLoggedIn': {
      'ku': 'چوونەژوورەوە نەکراوە',
      'ar': 'لم يتم تسجيل الدخول',
      'en': 'Not logged in',
 
      'tr': 'Giriş yapılmadı',
      'fr': 'Non connecté',
    },
    'loginForFeatures': {
      'ku': 'بۆ بەکارهێنانی تایبەتمەندییەکان بچۆرە ژوورەوە',
      'ar': 'سجّل الدخول لاستخدام الميزات',
      'en': 'Log in to use features',
 
      'tr': 'Özellikleri kullanmak için giriş yapın',
      'fr': 'Connectez-vous pour utiliser les fonctionnalités',
    },
    'login': {
      'ku': 'چوونەژوورەوە',
      'ar': 'تسجيل الدخول',
      'en': 'Log in',
      'tr': 'Giriş Yap',
      'fr': 'Se connecter',
    },
    'logout': {
      'ku': 'دەرچوون',
      'ar': 'تسجيل الخروج',
      'en': 'Log out',
      'tr': 'Çıkış Yap',
      'fr': 'Se déconnecter',
    },
    'logoutConfirm': {
      'ku': 'دڵنیایت دەتەوێت لە ئەکاونتەکەت بچیتە دەرەوە؟',
      'ar': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'en': 'Are you sure you want to log out?',
 
      'tr': 'Çıkış yapmak istediğinizden emin misiniz?',
      'fr': 'Êtes-vous sûr de vouloir vous déconnecter ?',
    },
    'no': {
      'ku': 'نەخێر',
      'ar': 'لا',
      'en': 'No',
 
      'tr': 'Hayır',
      'fr': 'Non',
    },
    'yesLogout': {
      'ku': 'بەڵێ، دەرچوون',
      'ar': 'نعم، خروج',
      'en': 'Yes, log out',
 
      'tr': 'Evet, Çıkış Yap',
      'fr': 'Oui, se déconnecter',
    },
    'loggedOutSuccess': {
      'ku': 'بە سەرکەوتوویی دەرچوویت',
      'ar': 'تم تسجيل الخروج بنجاح',
      'en': 'Logged out successfully',
 
      'tr': 'Başarıyla çıkış yapıldı',
      'fr': 'Déconnexion réussie',
    },
    'loading': {
      'ku': 'چاوەڕوانبە...',
      'ar': 'انتظر...',
      'en': 'Loading...',
 
      'tr': 'Yükleniyor...',
      'fr': 'Chargement...',
    },

    // ─── Detail ───
    'aboutTab': {
      'ku': 'دەربارە',
      'ar': 'حول',
      'en': 'About',
 
      'tr': 'Hakkında',
      'fr': 'À propos',
    },
    'college': {
      'ku': 'کۆلێژ',
      'ar': 'كلية',
      'en': 'College',
 
      'tr': 'Fakülte',
      'fr': 'Faculté',
    },
    'department': {
      'ku': 'بەش',
      'ar': 'قسم',
      'en': 'Department',
 
      'tr': 'Bölüm',
      'fr': 'Département',
    },
    'locationTab': {
      'ku': 'شوێن',
      'ar': 'الموقع',
      'en': 'Location',
 
      'tr': 'Konum',
      'fr': 'Emplacement',
    },
    'contactTab': {
      'ku': 'پەیوەندی',
      'ar': 'اتصال',
      'en': 'Contact',
 
      'tr': 'İletişim',
      'fr': 'Contact',
    },
    'socialTab': {
      'ku': 'سۆشیال',
      'ar': 'التواصل',
      'en': 'Social',
 
      'tr': 'Sosyal',
      'fr': 'Réseaux sociaux',
    },
    'email': {
      'ku': 'ئیمەیڵ',
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
 
      'tr': 'E-posta',
      'fr': 'E-mail',
    },
    'website': {
      'ku': 'وێبسایت',
      'ar': 'الموقع الإلكتروني',
      'en': 'Website',
 
      'tr': 'Web sitesi',
      'fr': 'Site web',
    },
    'noAboutInfo': {
      'ku': 'هیچ زانیاریەک لەسەر دەربارە نییە',
      'ar': 'لا توجد معلومات',
      'en': 'No information available',
 
      'tr': 'Hakkında bilgi yok',
      'fr': 'Aucune information disponible',
    },
    'noDepartments': {
      'ku': 'هیچ بەشێک زیاد نەکراوە',
      'ar': 'لم تتم إضافة أقسام',
      'en': 'No departments added',
 
      'tr': 'Bölüm eklenmedi',
      'fr': 'Aucun département ajouté',
    },
    'collegesAndDepts': {
      'ku': 'کۆلێژ و بەشەکان',
      'ar': 'الكليات والأقسام',
      'en': 'Colleges & Departments',
 
      'tr': 'Fakülte ve Bölümler',
      'fr': 'Facultés et Départements',
    },
    'departments': {
      'ku': 'بەشەکان',
      'ar': 'الأقسام',
      'en': 'Departments',
 
      'tr': 'Bölümler',
      'fr': 'Départements',
    },
    'collegeCount': {
      'ku': '{count} کۆلێژ',
      'ar': '{count} كلية',
      'en': '{count} colleges',
      'tr': '{count} fakülte',
      'fr': '{count} facultés',
    },
    'deptCount': {
      'ku': '{count} بەش',
      'ar': '{count} قسم',
      'en': '{count} depts',
      'tr': '{count} bölüm',
      'fr': '{count} depts',
    },
    'colleges': {
      'ku': 'کۆلێژەکان',
      'ar': 'الكليات',
      'en': 'Colleges',
 
      'tr': 'Fakülteler',
      'fr': 'Facultés',
    },
    'noContactInfo': {
      'ku': 'هیچ زانیاریەکی پەیوەندی نییە',
      'ar': 'لا توجد معلومات اتصال',
      'en': 'No contact information',
 
      'tr': 'İletişim bilgisi yok',
      'fr': 'Aucune information de contact',
    },
    'phone': {
      'ku': 'ژمارەی تەلەفۆن',
      'ar': 'رقم الهاتف',
      'en': 'Phone number',
 
      'tr': 'Telefon numarası',
      'fr': 'Numéro de téléphone',
    },
    'openMap': {
      'ku': 'کردنەوەی نەخشە',
      'ar': 'فتح الخريطة',
      'en': 'Open map',
 
      'tr': 'Haritayı Aç',
      'fr': 'Ouvrir la carte',
    },
    'noSocial': {
      'ku': 'هیچ سۆشیالێک زیاد نەکراوە',
      'ar': 'لم تتم إضافة حسابات تواصل',
      'en': 'No social media added',
 
      'tr': 'Sosyal medya eklenmedi',
      'fr': 'Aucun réseau social ajouté',
    },
    'socialMedia': {
      'ku': 'سۆشیال میدیا',
      'ar': 'وسائل التواصل',
      'en': 'Social media',
 
      'tr': 'Sosyal Medya',
      'fr': 'Réseaux sociaux',
    },
    'facebook': {
      'ku': 'فەیسبووک',
      'ar': 'فيسبوك',
      'en': 'Facebook',
 
      'tr': 'Facebook',
      'fr': 'Facebook',
    },
    'whatsapp': {
      'ku': 'واتساپ',
      'ar': 'واتساب',
      'en': 'WhatsApp',
 
      'tr': 'WhatsApp',
      'fr': 'WhatsApp',
    },

    'translate': {
      'ku': 'وەرگێڕان',
      'ar': 'ترجمة',
      'en': 'Translate',
      'tr': 'Çevir',
      'fr': 'Traduire',
    },

    'address': {
      'ku': 'ناونیشان',
      'ar': 'العنوان',
      'en': 'Address',
      'tr': 'Adres',
      'fr': 'Adresse',
    },

    'editInstitution': {
      'ku': 'دەستکاریکردنی دامەزراوە',
      'ar': 'تعديل المؤسسة',
      'en': 'Edit Institution',
      'tr': 'Kurumu Düzenle',
      'fr': 'Modifier l\'établissement',
    },
    'updateSuccess': {
      'ku': 'زانیارییەکان بە سەرکەوتوویی نوێکرانەوە.',
      'ar': 'تم تحديث المعلومات بنجاح.',
      'en': 'Information updated successfully.',
      'tr': 'Bilgiler başarıyla güncellendi.',
      'fr': 'Informations mises à jour avec succès.',
    },

    // ─── Register ───
    'registerInstitution': {
      'ku': 'تۆمارکردنی دامەزراوە',
      'ar': 'تسجيل مؤسسة',
      'en': 'Register Institution',
 
      'tr': 'Kurum Kaydet',
      'fr': 'Enregistrer un établissement',
    },
    'adminApprovalNotice': {
      'ku': 'دوای ناردن، ئەدمین پەسەندی دەکات.',
      'ar': 'بعد الإرسال، سيوافق المشرف.',
      'en': 'After submission, admin will approve.',
 
      'tr': 'Gönderildikten sonra yönetici onaylayacak.',
      'fr': 'Après soumission, l\'administrateur approuvera.',
    },
    'mainInfo': {
      'ku': 'زانیاری سەرەکی',
      'ar': 'المعلومات الأساسية',
      'en': 'Main information',
 
      'tr': 'Ana Bilgiler',
      'fr': 'Informations principales',
    },
    'institutionName': {
      'ku': 'ناوی دامەزراوە *',
      'ar': 'اسم المؤسسة *',
      'en': 'Institution name *',
 
      'tr': 'Kurum Adı *',
      'fr': 'Nom de l\'établissement *',
    },
    'institutionNameHint': {
      'ku': 'ناوی دامەزراوەکە...',
      'ar': 'اسم المؤسسة...',
      'en': 'Institution name...',
 
      'tr': 'Kurum adı...',
      'fr': 'Nom de l\'établissement...',
    },
    'cityHint': {
      'ku': 'بۆ نموونە: هەولێر',
      'ar': 'مثال: أربيل',
      'en': 'e.g. Erbil',
 
      'tr': 'Örn: Erbil',
      'fr': 'Ex: Erbil',
    },
    'typeRequired': {
      'ku': 'جۆر *',
      'ar': 'النوع *',
      'en': 'Type *',
 
      'tr': 'Tür *',
      'fr': 'Type *',
    },
    'addressRequired': {
      'ku': 'ناونیشان *',
      'ar': 'العنوان *',
      'en': 'Address *',
 
      'tr': 'Adres *',
      'fr': 'Adresse *',
    },
    'addressHint': {
      'ku': 'ناونیشانی دامەزراوەکە...',
      'ar': 'عنوان المؤسسة...',
      'en': 'Institution address...',
 
      'tr': 'Kurum adresi...',
      'fr': 'Adresse de l\'établissement...',
    },
    'moreInfo': {
      'ku': 'زانیاری زیاتر',
      'ar': 'معلومات إضافية',
      'en': 'More info',
 
      'tr': 'Daha Fazla Bilgi',
      'fr': 'Plus d\'informations',
    },
    'englishName': {
      'ku': 'ناوی ئینگلیزی',
      'ar': 'الاسم بالإنجليزية',
      'en': 'English name',
 
      'tr': 'İngilizce Adı',
      'fr': 'Nom en anglais',
    },
    'aboutInstitution': {
      'ku': 'دەربارەی دامەزراوەکە',
      'ar': 'حول المؤسسة',
      'en': 'About the institution',
 
      'tr': 'Kurum Hakkında',
      'fr': 'À propos de l\'établissement',
    },
    'aboutHint': {
      'ku': 'کورتەیەک لەسەر دامەزراوەکە...',
      'ar': 'نبذة عن المؤسسة...',
      'en': 'Brief about the institution...',
 
      'tr': 'Kurum hakkında kısa bilgi...',
      'fr': 'Brève description...',
    },
    'addCollege': {
      'ku': 'زیادکردنی کۆلێژ',
      'ar': 'إضافة كلية',
      'en': 'Add college',
 
      'tr': 'Fakülte Ekle',
      'fr': 'Ajouter une faculté',
    },
    'addDept': {
      'ku': 'زیادکردنی بەش',
      'ar': 'إضافة قسم',
      'en': 'Add department',
 
      'tr': 'Bölüm Ekle',
      'fr': 'Ajouter un département',
    },
    'extraInfo': {
      'ku': 'زانیاری زیادە',
      'ar': 'معلومات إضافية',
      'en': 'Extra info',
 
      'tr': 'Ek Bilgiler',
      'fr': 'Informations supplémentaires',
    },
    'admissionAge': {
      'ku': 'تەمەنی وەرگرتن',
      'ar': 'سن القبول',
      'en': 'Admission age',
 
      'tr': 'Kabul Yaşı',
      'fr': 'Âge d\'admission',
    },
    'admissionAgeHint': {
      'ku': 'بۆ نموونە: ٣ - ٦ ساڵ',
      'ar': 'مثال: ٣ - ٦ سنة',
      'en': 'e.g. 3 - 6 years',
 
      'tr': 'Örn: 3 - 6 yıl',
      'fr': 'Ex: 3 - 6 ans',
    },
    'workHours': {
      'ku': 'کاتی کار',
      'ar': 'أوقات العمل',
      'en': 'Work hours',
 
      'tr': 'Çalışma Saatleri',
      'fr': 'Heures de travail',
    },
    'workHoursHint': {
      'ku': 'بۆ نموونە: ٨:٠٠ - ٢:٠٠',
      'ar': 'مثال: ٨:٠٠ - ٢:٠٠',
      'en': 'e.g. 8:00 - 2:00',
 
      'tr': 'Örn: 8:00 - 2:00',
      'fr': 'Ex: 8h00 - 14h00',
    },
    'contact': {
      'ku': 'پەیوەندی',
      'ar': 'اتصال',
      'en': 'Contact',
 
      'tr': 'İletişim',
      'fr': 'Contact',
    },
    'social': {
      'ku': 'سۆشیال',
      'ar': 'التواصل الاجتماعي',
      'en': 'Social',
 
      'tr': 'Sosyal',
      'fr': 'Réseaux sociaux',
    },
    'submitToAdmin': {
      'ku': 'ناردن بۆ ئەدمین',
      'ar': 'إرسال للمشرف',
      'en': 'Submit to admin',
 
      'tr': 'Yöneticiye Gönder',
      'fr': 'Envoyer à l\'administrateur',
    },
    'iraq': {
      'ku': 'عێراق',
      'ar': 'العراق',
      'en': 'Iraq',
 
      'tr': 'Irak',
      'fr': 'Irak',
    },
    'addLogo': {
      'ku': 'وێنەی دامەزراوەکەت زیاد بکە',
      'ar': 'أضف شعار المؤسسة',
      'en': 'Add institution logo',
 
      'tr': 'Kurum logosu ekle',
      'fr': 'Ajouter le logo',
    },
    'changeLogo': {
      'ku': 'گۆڕینی وێنە',
      'ar': 'تغيير الصورة',
      'en': 'Change image',
 
      'tr': 'Görseli Değiştir',
      'fr': 'Changer l\'image',
    },
    'loginRequired': {
      'ku': 'پێویستە لۆگین بکەیت',
      'ar': 'يجب تسجيل الدخول',
      'en': 'Login required',
 
      'tr': 'Giriş gerekli',
      'fr': 'Connexion requise',
    },
    'loginRequiredDesc': {
      'ku': 'بۆ تۆمارکردنی دامەزراوەی نوێ، تکایە سەرەتا بچۆ ژوورەوە.',
      'ar': 'لتسجيل مؤسسة جديدة، يرجى تسجيل الدخول أولاً.',
      'en': 'To register a new institution, please log in first.',
 
      'tr': 'Yeni bir kurum kaydı için lütfen önce giriş yapın.',
      'fr': 'Pour enregistrer un nouvel établissement, veuillez d\'abord vous connecter.',
    },
    'goToLogin': {
      'ku': 'چوونە ژوورەوە',
      'ar': 'تسجيل الدخول',
      'en': 'Go to login',
 
      'tr': 'Giriş Yap',
      'fr': 'Se connecter',
    },
    'errorNameRequired': {
      'ku': 'تکایە ناوی دامەزراوەکە بنووسە',
      'ar': 'يرجى كتابة اسم المؤسسة',
      'en': 'Please enter the institution name',
 
      'tr': 'Lütfen kurum adını girin',
      'fr': 'Veuillez saisir le nom de l\'établissement',
    },
    'errorTypeRequired': {
      'ku': 'تکایە جۆری دامەزراوە هەڵبژێرە',
      'ar': 'يرجى اختيار نوع المؤسسة',
      'en': 'Please select institution type',
 
      'tr': 'Lütfen kurum türünü seçin',
      'fr': 'Veuillez sélectionner le type d\'établissement',
    },
    'errorAddressRequired': {
      'ku': 'تکایە ناونیشان دیاری بکە',
      'ar': 'يرجى تحديد العنوان',
      'en': 'Please provide an address',
 
      'tr': 'Lütfen adres belirtin',
      'fr': 'Veuillez fournir une adresse',
    },
    'errorLoginFirst': {
      'ku': 'تکایە سەرەتا لۆگین بکە',
      'ar': 'يرجى تسجيل الدخول أولاً',
      'en': 'Please log in first',
 
      'tr': 'Lütfen önce giriş yapın',
      'fr': 'Veuillez d\'abord vous connecter',
    },
    'submitSuccess': {
      'ku': 'زۆر سوپاس! داواکارییەکەت نێردرا بۆ ئەدمین.',
      'ar': 'شكراً! تم إرسال طلبك للمشرف.',
      'en': 'Thank you! Your request has been sent to admin.',
 
      'tr': 'Teşekkürler! İsteğiniz yöneticiye gönderildi.',
      'fr': 'Merci ! Votre demande a été envoyée à l\'administrateur.',
    },
    'errorOccurred': {
      'ku': 'هەڵەیەک ڕوویدا',
      'ar': 'حدث خطأ',
      'en': 'An error occurred',
 
      'tr': 'Bir hata oluştu',
      'fr': 'Une erreur s\'est produite',
    },
    'submitFailed': {
      'ku': 'نەتوانرا بنێردرێت',
      'ar': 'فشل الإرسال',
      'en': 'Failed to submit',
 
      'tr': 'Gönderilemedi',
      'fr': 'Échec de l\'envoi',
    },
    'collegeN': {
      'ku': 'کۆلێژی {n}',
      'ar': 'كلية {n}',
      'en': 'College {n}',
      'tr': '{n}. Fakülte',
      'fr': 'Faculté {n}',
    },
    'deptN': {
      'ku': 'بەشی {n}',
      'ar': 'قسم {n}',
      'en': 'Department {n}',
      'tr': '{n}. Bölüm',
      'fr': 'Département {n}',
    },
    'collegeNameHint': {
      'ku': 'ناوی کۆلێژ...',
      'ar': 'اسم الكلية...',
      'en': 'College name...',
 
      'tr': 'Fakülte adı...',
      'fr': 'Nom de la faculté...',
    },
    'deptNameHint': {
      'ku': 'ناوی بەش...',
      'ar': 'اسم القسم...',
      'en': 'Department name...',
 
      'tr': 'Bölüm adı...',
      'fr': 'Nom du département...',
    },
    'subDeptHint': {
      'ku': 'ناوی لق...',
      'ar': 'اسم الفرع...',
      'en': 'Branch name...',
 
      'tr': 'Dal adı...',
      'fr': 'Nom de la branche...',
    },
    'addSubDept': {
      'ku': 'زیادکردنی لق',
      'ar': 'إضافة فرع',
      'en': 'Add branch',
 
      'tr': 'Dal Ekle',
      'fr': 'Ajouter une branche',
    },

    // ─── GPS/Location ───
    'enableGPS': {
      'ku': 'تکایە GPS چالاک بکە',
      'ar': 'يرجى تفعيل GPS',
      'en': 'Please enable GPS',
 
      'tr': 'Lütfen GPS\'i etkinleştirin',
      'fr': 'Veuillez activer le GPS',
    },
    'enableLocationService': {
      'ku': 'تکایە GPS/لۆکەیشن سەرڤیس لە ئامێرەکەت چالاک بکە',
      'ar': 'يرجى تفعيل خدمة الموقع في جهازك',
      'en': 'Please enable location service on your device',
 
      'tr': 'Lütfen cihazınızda GPS/konum servisini etkinleştirin',
      'fr': 'Veuillez activer le service de localisation sur votre appareil',
    },
    'locationPermissionNeeded': {
      'ku': 'ڕێگەپێدان بۆ لۆکەیشن پێویستە',
      'ar': 'مطلوب إذن الوصول للموقع',
      'en': 'Location permission is required',
 
      'tr': 'Konum izni gerekli',
      'fr': 'Permission de localisation requise',
    },
    'enableLocationSettings': {
      'ku': 'ڕێگەپێدانی لۆکەیشن لە ڕێکخستنەکان چالاکی بکەرەوە',
      'ar': 'فعّل إذن الموقع من الإعدادات',
      'en': 'Enable location permission in settings',
 
      'tr': 'Ayarlardan konum iznini etkinleştirin',
      'fr': 'Activez la permission de localisation dans les paramètres',
    },
    'locationError': {
      'ku': 'نەتوانرا لۆکەیشنەکە بدۆزرێتەوە',
      'ar': 'تعذر تحديد الموقع',
      'en': 'Could not determine location',
 
      'tr': 'Konum bulunamadı',
      'fr': 'Impossible de déterminer la localisation',
    },

    // ─── Login ───
    'welcomeLogin': {
      'ku': 'بەخێربێیت! بچۆ ناو ئەکاونتەکەت',
      'ar': 'مرحباً! سجّل الدخول إلى حسابك',
      'en': 'Welcome! Log into your account',
 
      'tr': 'Hoş Geldiniz! Hesabınıza giriş yapın',
      'fr': 'Bienvenue ! Connectez-vous à votre compte',
    },
    'password': {
      'ku': 'وشەی نهێنی',
      'ar': 'كلمة المرور',
      'en': 'Password',
 
      'tr': 'Şifre',
      'fr': 'Mot de passe',
    },
    'forgotPassword': {
      'ku': 'وشەی نهێنیت لەبیرکردووە؟',
      'ar': 'نسيت كلمة المرور؟',
      'en': 'Forgot password?',
 
      'tr': 'Şifrenizi mi unuttunuz?',
      'fr': 'Mot de passe oublié ?',
    },
    'enterEmailPassword': {
      'ku': 'تکایە ئیمەیڵ و وشەی نهێنی بنووسە',
      'ar': 'يرجى إدخال البريد وكلمة المرور',
      'en': 'Please enter email and password',
 
      'tr': 'Lütfen e-posta ve şifre girin',
      'fr': 'Veuillez saisir l\'e-mail et le mot de passe',
    },
    'loginSuccess': {
      'ku': 'بە سەرکەوتوویی چوویتە ژوورەوە!',
      'ar': 'تم تسجيل الدخول بنجاح!',
      'en': 'Logged in successfully!',
 
      'tr': 'Başarıyla giriş yapıldı!',
      'fr': 'Connexion réussie !',
    },
    'loginError': {
      'ku': 'ئیمەیڵ یان وشەی نهێنی هەڵەیە',
      'ar': 'البريد أو كلمة المرور خاطئة',
      'en': 'Incorrect email or password',
 
      'tr': 'E-posta veya şifre hatalı',
      'fr': 'E-mail ou mot de passe incorrect',
    },
    'noAccount': {
      'ku': 'ئەکاونتت نییە؟',
      'ar': 'ليس لديك حساب؟',
      'en': "Don't have an account?",
 
      'tr': 'Hesabınız yok mu?',
      'fr': 'Vous n\'avez pas de compte ?',
    },
    'createAccount': {
      'ku': 'ئەکاونت دروست بکە',
      'ar': 'أنشئ حساباً',
      'en': 'Create account',
 
      'tr': 'Hesap Oluştur',
      'fr': 'Créer un compte',
    },
    'continueWithout': {
      'ku': 'بەبێ ئەکاونت بەردەوام بە',
      'ar': 'المتابعة بدون حساب',
      'en': 'Continue without account',
 
      'tr': 'Hesapsız Devam Et',
      'fr': 'Continuer sans compte',
    },

    // ─── Signup ───
    'signupTitle': {
      'ku': 'ئەکاونت دروست بکە',
      'ar': 'إنشاء حساب',
      'en': 'Create account',
 
      'tr': 'Hesap Oluştur',
      'fr': 'Créer un compte',
    },
    'signupSubtitle': {
      'ku': 'زانیاریەکانت بنووسە بۆ دروستکردنی ئەکاونت',
      'ar': 'أدخل معلوماتك لإنشاء حساب',
      'en': 'Enter your info to create an account',
 
      'tr': 'Hesap oluşturmak için bilgilerinizi girin',
      'fr': 'Entrez vos informations pour créer un compte',
    },
    'fullName': {
      'ku': 'ناوی تەواو',
      'ar': 'الاسم الكامل',
      'en': 'Full name',
 
      'tr': 'Tam Ad',
      'fr': 'Nom complet',
    },
    'fullNameHint': {
      'ku': 'ناوی تەواوت بنووسە',
      'ar': 'أدخل اسمك الكامل',
      'en': 'Enter your full name',
 
      'tr': 'Tam adınızı girin',
      'fr': 'Entrez votre nom complet',
    },
    'minChars': {
      'ku': 'لانیکەم ٦ پیت',
      'ar': 'على الأقل ٦ أحرف',
      'en': 'At least 6 characters',
 
      'tr': 'En az 6 karakter',
      'fr': 'Au moins 6 caractères',
    },
    'enterName': {
      'ku': 'تکایە ناوت بنووسە',
      'ar': 'يرجى إدخال اسمك',
      'en': 'Please enter your name',
 
      'tr': 'Lütfen adınızı girin',
      'fr': 'Veuillez saisir votre nom',
    },
    'enterEmail': {
      'ku': 'تکایە ئیمەیڵت بنووسە',
      'ar': 'يرجى إدخال بريدك',
      'en': 'Please enter your email',
 
      'tr': 'Lütfen e-postanızı girin',
      'fr': 'Veuillez saisir votre e-mail',
    },
    'enterPassword': {
      'ku': 'تکایە وشەی نهێنی بنووسە',
      'ar': 'يرجى إدخال كلمة المرور',
      'en': 'Please enter a password',
 
      'tr': 'Lütfen şifre girin',
      'fr': 'Veuillez saisir un mot de passe',
    },
    'passwordMinLength': {
      'ku': 'وشەی نهێنی دەبێ لانیکەم ٦ پیت بێ',
      'ar': 'يجب أن تكون كلمة المرور ٦ أحرف على الأقل',
      'en': 'Password must be at least 6 characters',
 
      'tr': 'Şifre en az 6 karakter olmalı',
      'fr': 'Le mot de passe doit comporter au moins 6 caractères',
    },
    'signupSuccess': {
      'ku': 'ئەکاونتەکەت بە سەرکەوتوویی دروست کرا!',
      'ar': 'تم إنشاء حسابك بنجاح!',
      'en': 'Account created successfully!',
 
      'tr': 'Hesabınız başarıyla oluşturuldu!',
      'fr': 'Votre compte a été créé avec succès !',
    },
    'connectionError': {
      'ku': 'کێشەیەک هەیە لە کۆنێکشن',
      'ar': 'مشكلة في الاتصال',
      'en': 'Connection error',
 
      'tr': 'Bağlantı sorunu',
      'fr': 'Erreur de connexion',
    },
    'haveAccount': {
      'ku': 'ئەکاونتت هەیە؟',
      'ar': 'لديك حساب؟',
      'en': 'Have an account?',
 
      'tr': 'Hesabınız var mı?',
      'fr': 'Vous avez déjà un compte ?',
    },
    'goToLoginLink': {
      'ku': 'بچۆ ژوورەوە',
      'ar': 'سجّل الدخول',
      'en': 'Log in',
 
      'tr': 'Giriş Yap',
      'fr': 'Se connecter',
    },

    // ─── Map Picker ───
    'pickLocation': {
      'ku': 'شوێن هەڵبژێرە',
      'ar': 'اختر الموقع',
      'en': 'Pick location',
 
      'tr': 'Konum Seç',
      'fr': 'Choisir l\'emplacement',
    },
    'confirm': {
      'ku': 'دیاریکردن',
      'ar': 'تأكيد',
      'en': 'Confirm',
 
      'tr': 'Onayla',
      'fr': 'Confirmer',
    },
    'selectedLocation': {
      'ku': 'شوێنی هەڵبژێردراو',
      'ar': 'الموقع المختار',
      'en': 'Selected location',
 
      'tr': 'Seçilen Konum',
      'fr': 'Emplacement sélectionné',
    },

    // ─── Edit Screen ───
    'editAdmin': {
      'ku': '✏️ دەستکاریکردن — ئەدمین',
      'ar': '✏️ تعديل — المشرف',
      'en': '✏️ Edit — Admin',
 
      'tr': '✏️ Düzenle — Yönetici',
      'fr': '✏️ Modifier — Administrateur',
    },
    'adminNotice': {
      'ku': '⚙️ ئەم بەشە تەنها بۆ ئەدمینە. دەتوانیت ناو، شار و زانیارییەکان بگۆڕیت.',
      'ar': '⚙️ هذا القسم للمشرف فقط. يمكنك تعديل الأسماء والمدينة والمعلومات.',
      'en': '⚙️ This section is admin-only. You can edit names, city and info.',
 
      'tr': '⚙️ Bu bölüm yalnızca yöneticiler içindir. Adları, şehri ve bilgileri düzenleyebilirsiniz.',
      'fr': '⚙️ Cette section est réservée aux administrateurs. Vous pouvez modifier les noms, la ville et les informations.',
    },
    'kurdishName': {
      'ku': 'ناوی کوردی',
      'ar': 'الاسم بالكوردية',
      'en': 'Kurdish name',
 
      'tr': 'Kürtçe Adı',
      'fr': 'Nom en kurde',
    },
    'arabicName': {
      'ku': 'ناوی عەرەبی',
      'ar': 'الاسم بالعربية',
      'en': 'Arabic name',
 
      'tr': 'Arapça Adı',
      'fr': 'Nom en arabe',
    },
    'cityDropdownHint': {
      'ku': 'شار...',
      'ar': 'المدينة...',
      'en': 'City...',
 
      'tr': 'Şehir...',
      'fr': 'Ville...',
    },
    'save': {
      'ku': 'پاشەکەوتکردن',
      'ar': 'حفظ',
      'en': 'Save',
 
      'tr': 'Kaydet',
      'fr': 'Enregistrer',
    },
    'delete': {
      'ku': 'سڕینەوە',
      'ar': 'حذف',
      'en': 'Delete',
 
      'tr': 'Sil',
      'fr': 'Supprimer',
    },
    'deleteConfirm': {
      'ku': 'دڵنیایت دەتەوێت ئەم دامەزراوەیە بسڕیتەوە؟',
      'ar': 'هل أنت متأكد أنك تريد حذف هذه المؤسسة؟',
      'en': 'Are you sure you want to delete this institution?',
 
      'tr': 'Bu kurumu silmek istediğinizden emin misiniz?',
      'fr': 'Êtes-vous sûr de vouloir supprimer cet établissement ?',
    },
    'yesDelete': {
      'ku': 'بەڵێ، بسڕەوە',
      'ar': 'نعم، احذف',
      'en': 'Yes, delete',
 
      'tr': 'Evet, Sil',
      'fr': 'Oui, supprimer',
    },
    'savedSuccess': {
      'ku': 'زانیارییەکان پاشەکەوتکران.',
      'ar': 'تم حفظ المعلومات.',
      'en': 'Information saved.',
 
      'tr': 'Bilgiler kaydedildi.',
      'fr': 'Informations enregistrées.',
    },
    'deletedSuccess': {
      'ku': 'دامەزراوەکە سڕایەوە.',
      'ar': 'تم حذف المؤسسة.',
      'en': 'Institution deleted.',
 
      'tr': 'Kurum silindi.',
      'fr': 'Établissement supprimé.',
    },
    'logoUrl': {
      'ku': 'لۆگۆ (URL)',
      'ar': 'الشعار (URL)',
      'en': 'Logo (URL)',
 
      'tr': 'Logo (URL)',
      'fr': 'Logo (URL)',
    },
    'imageUrl': {
      'ku': 'وێنە (URL)',
      'ar': 'الصورة (URL)',
      'en': 'Image (URL)',
 
      'tr': 'Görsel (URL)',
      'fr': 'Image (URL)',
    },

    // ─── Stats ───
    'total': {
      'ku': 'کۆی گشتی',
      'ar': 'الإجمالي',
      'en': 'Total',
 
      'tr': 'Toplam',
      'fr': 'Total',
    },
    'government': {
      'ku': 'حکومی',
      'ar': 'حكومي',
      'en': 'Government',
 
      'tr': 'Devlet',
      'fr': 'Gouvernemental',
    },
    'private': {
      'ku': 'تایبەت',
      'ar': 'خاص',
      'en': 'Private',
 
      'tr': 'Özel',
      'fr': 'Privé',
    },
    'institute': {
      'ku': 'پەیمانگە',
      'ar': 'معهد',
      'en': 'Institute',
 
      'tr': 'Enstitü',
      'fr': 'Institut',
    },
    'school': {
      'ku': 'قوتابخانە',
      'ar': 'مدرسة',
      'en': 'School',
 
      'tr': 'Okul',
      'fr': 'École',
    },
    'kindergarten': {
      'ku': 'باخچە',
      'ar': 'روضة',
      'en': 'Kindergarten',
 
      'tr': 'Anaokulu',
      'fr': 'Maternelle',
    },

    // ─── Signup Form Header ───
    'signupFormHeader': {
      'ku': 'دروستکردنی ئەکاونت',
      'ar': 'إنشاء حساب',
      'en': 'Create Account',
 
      'tr': 'Hesap Oluştur',
      'fr': 'Créer un compte',
    },
    'enableGPSService': {
      'ku': 'تکایە GPS/لۆکەیشن سەرڤیس چالاک بکە',
      'ar': 'يرجى تفعيل خدمة الموقع',
      'en': 'Please enable GPS/Location service',
 
      'tr': 'Lütfen GPS/Konum Servisini etkinleştirin',
      'fr': 'Veuillez activer le service GPS/Localisation',
    },
    'sections': {
      'ku': 'بەشەکان',
      'ar': 'الأقسام',
      'en': 'Departments',
 
      'tr': 'Bölümler',
      'fr': 'Sections',
    },
    'addDeptSub': {
      'ku': 'زیادکردنی بەش',
      'ar': 'إضافة قسم',
      'en': 'Add department',
 
      'tr': 'Bölüm Ekle',
      'fr': 'Ajouter une section',
    },
    'addBranch': {
      'ku': 'زیادکردنی لق',
      'ar': 'إضافة فرع',
      'en': 'Add branch',
 
      'tr': 'Dal Ekle',
      'fr': 'Ajouter une branche',
    },

    // ─── Snackbar ───
    'success': {
      'ku': 'سەرکەوتوو!',
      'ar': 'نجاح!',
      'en': 'Success!',
 
      'tr': 'Başarılı!',
      'fr': 'Succès !',
    },
    'error': {
      'ku': 'هەڵە!',
      'ar': 'خطأ!',
      'en': 'Error!',
 
      'tr': 'Hata!',
      'fr': 'Erreur !',
    },
    'warning': {
      'ku': 'ئاگاداری!',
      'ar': 'تنبيه!',
      'en': 'Warning!',
 
      'tr': 'Uyarı!',
      'fr': 'Avertissement !',
    },
    'info': {
      'ku': 'زانیاری',
      'ar': 'معلومة',
      'en': 'Info',
 
      'tr': 'Bilgi',
      'fr': 'Info',
    },
    'back': {
      'ku': 'گەڕانەوە',
      'ar': 'رجوع',
      'en': 'Go back',
 
      'tr': 'Geri',
      'fr': 'Retour',
    },

    // ─── Validation ───
    'confirmPassword': {
      'ku': 'دووبارەکردنەوەی وشەی نهێنی',
      'ar': 'تأكيد كلمة المرور',
      'en': 'Confirm password',
 
      'tr': 'Şifreyi Onayla',
      'fr': 'Confirmer le mot de passe',
    },
    'passwordMismatch': {
      'ku': 'وشەی نهێنی یەک ناگرنەوە',
      'ar': 'كلمتا المرور غير متطابقتين',
      'en': 'Passwords do not match',
 
      'tr': 'Şifreler eşleşmiyor',
      'fr': 'Les mots de passe ne correspondent pas',
    },
    'invalidEmail': {
      'ku': 'ئیمەیڵەکە دروست نیە',
      'ar': 'البريد الإلكتروني غير صالح',
      'en': 'Invalid email address',
 
      'tr': 'Geçersiz e-posta',
      'fr': 'E-mail invalide',
    },
    'invalidPhone': {
      'ku': 'ژمارەی مۆبایل دروست نیە',
      'ar': 'رقم الهاتف غير صالح',
      'en': 'Invalid phone number',
 
      'tr': 'Geçersiz telefon numarası',
      'fr': 'Numéro de téléphone invalide',
    },
    'invalidUrl': {
      'ku': 'لینکەکە دروست نیە',
      'ar': 'الرابط غير صالح',
      'en': 'Invalid URL',
 
      'tr': 'Geçersiz URL',
      'fr': 'URL invalide',
    },
    'networkError': {
      'ku': 'کێشەیەک لە تۆڕەکەدا ڕوویدا',
      'ar': 'حدث خطأ في الشبكة',
      'en': 'A network error occurred',
 
      'tr': 'Ağ hatası oluştu',
      'fr': 'Une erreur réseau s\'est produite',
    },
    'retry': {
      'ku': 'هەوڵبدەرەوە',
      'ar': 'إعادة المحاولة',
      'en': 'Retry',
 
      'tr': 'Tekrar Dene',
      'fr': 'Réessayer',
    },
    'locationFailed': {
      'ku': 'شوێنەکە نەدۆزرایەوە',
      'ar': 'تعذر تحديد الموقع',
      'en': 'Location not found',
 
      'tr': 'Konum bulunamadı',
      'fr': 'Localisation introuvable',
    },
    'filterResults': {
      'ku': 'فلتەرکردن',
      'ar': 'تصفية',
      'en': 'Filter',
 
      'tr': 'Filtrele',
      'fr': 'Filtrer',
    },

    // ─── Favorites ───
    'favorites': {
      'ku': 'دڵخوازەکان',
      'ar': 'المفضلة',
      'en': 'Favorites',
 
      'tr': 'Favoriler',
      'fr': 'Favoris',
    },
    'noFavorites': {
      'ku': 'هیچ دڵخوازێکت نییە',
      'ar': 'لا توجد مفضلات',
      'en': 'No favorites yet',
 
      'tr': 'Henüz favoriniz yok',
      'fr': 'Pas encore de favoris',
    },
    'noFavoritesDesc': {
      'ku': 'خوێندنگای دڵخوازت پاشەکەوت بکە بۆ ئەوەی لێرە ببینیت',
      'ar': 'احفظ مؤسساتك المفضلة لتراها هنا',
      'en': 'Save your favorite institutions to see them here',
 
      'tr': 'Favori kurumlarınızı kaydedin',
      'fr': 'Sauvegardez vos établissements favoris pour les voir ici',
    },
    'addedToFavorites': {
      'ku': 'زیادکرا بۆ دڵخوازەکان',
      'ar': 'أُضيف إلى المفضلة',
      'en': 'Added to favorites',
 
      'tr': 'Favorilere eklendi',
      'fr': 'Ajouté aux favoris',
    },
    'removedFromFavorites': {
      'ku': 'لابرا لە دڵخوازەکان',
      'ar': 'أُزيل من المفضلة',
      'en': 'Removed from favorites',
 
      'tr': 'Favorilerden kaldırıldı',
      'fr': 'Retiré des favoris',
    },

    // ─── Password Reset ───
    'enterValidEmail': {
      'ku': 'تکایە ئیمەیڵێکی دروست بنووسە',
      'ar': 'يرجى إدخال بريد إلكتروني صالح',
      'en': 'Please enter a valid email',
 
      'tr': 'Lütfen geçerli bir e-posta girin',
      'fr': 'Veuillez saisir un e-mail valide',
    },
    'codeSent': {
      'ku': 'کۆدەکە نێردرا بۆ ئیمەیڵەکەت',
      'ar': 'تم إرسال الرمز إلى بريدك',
      'en': 'Code sent to your email',
 
      'tr': 'Kod e-postanıza gönderildi',
      'fr': 'Code envoyé à votre e-mail',
    },
    'enterValidCode': {
      'ku': 'تکایە کۆدی ٦ ژمارەیی بنووسە',
      'ar': 'يرجى إدخال الرمز المكون من ٦ أرقام',
      'en': 'Please enter the 6-digit code',
 
      'tr': 'Lütfen 6 haneli kodu girin',
      'fr': 'Veuillez saisir le code à 6 chiffres',
    },
    'invalidCode': {
      'ku': 'کۆدەکە هەڵەیە',
      'ar': 'الرمز خاطئ',
      'en': 'Invalid code',
 
      'tr': 'Geçersiz kod',
      'fr': 'Code invalide',
    },
    'passwordTooShort': {
      'ku': 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت',
      'ar': 'يجب أن تكون كلمة المرور ٦ أحرف على الأقل',
      'en': 'Password must be at least 6 characters',
 
      'tr': 'Şifre en az 6 karakter olmalı',
      'fr': 'Le mot de passe doit comporter au moins 6 caractères',
    },
    'passwordsDoNotMatch': {
      'ku': 'وشەی نهێنییەکان یەک ناگرنەوە',
      'ar': 'كلمتا المرور غير متطابقتين',
      'en': 'Passwords do not match',
 
      'tr': 'Şifreler eşleşmiyor',
      'fr': 'Les mots de passe ne correspondent pas',
    },
    'passwordResetSuccess': {
      'ku': 'وشەی نهێنی بە سەرکەوتوویی گۆڕدرا',
      'ar': 'تم تغيير كلمة المرور بنجاح',
      'en': 'Password reset successfully',
 
      'tr': 'Şifre başarıyla sıfırlandı',
      'fr': 'Mot de passe réinitialisé avec succès',
    },
    'enterEmailForReset': {
      'ku': 'ئیمەیڵەکەت بنووسە',
      'ar': 'أدخل بريدك الإلكتروني',
      'en': 'Enter your email',
 
      'tr': 'E-postanızı girin',
      'fr': 'Entrez votre e-mail',
    },
    'enterEmailDescription': {
      'ku': 'کۆدێکت بۆ دەنێرین بۆ گۆڕینی وشەی نهێنی',
      'ar': 'سنرسل لك رمزاً لإعادة تعيين كلمة المرور',
      'en': 'We will send you a code to reset your password',
 
      'tr': 'Şifre sıfırlama kodu göndereceğiz',
      'fr': 'Nous vous enverrons un code de réinitialisation',
    },
    'enterCode': {
      'ku': 'کۆدەکە بنووسە',
      'ar': 'أدخل الرمز',
      'en': 'Enter code',
 
      'tr': 'Kodu girin',
      'fr': 'Entrez le code',
    },
    'enterCodeDescription': {
      'ku': 'کۆدەکە نێردراوە بۆ ئیمەیڵەکەت',
      'ar': 'تم إرسال الرمز إلى بريدك الإلكتروني',
      'en': 'The code has been sent to your email',
 
      'tr': 'Kod e-postanıza gönderildi',
      'fr': 'Le code a été envoyé à votre e-mail',
    },
    'resendCode': {
      'ku': 'دووبارە ناردنی کۆد',
      'ar': 'إعادة إرسال الرمز',
      'en': 'Resend code',
 
      'tr': 'Kodu Yeniden Gönder',
      'fr': 'Renvoyer le code',
    },
    'enterNewPassword': {
      'ku': 'وشەی نهێنی نوێ بنووسە',
      'ar': 'أدخل كلمة مرور جديدة',
      'en': 'Enter new password',
 
      'tr': 'Yeni şifre girin',
      'fr': 'Entrez un nouveau mot de passe',
    },
    'enterNewPasswordDescription': {
      'ku': 'وشەیەکی نهێنی بە هێز هەڵبژێرە',
      'ar': 'اختر كلمة مرور قوية',
      'en': 'Choose a strong password',
 
      'tr': 'Güçlü bir şifre seçin',
      'fr': 'Choisissez un mot de passe fort',
    },
    'newPassword': {
      'ku': 'وشەی نهێنی نوێ',
      'ar': 'كلمة المرور الجديدة',
      'en': 'New password',
 
      'tr': 'Yeni Şifre',
      'fr': 'Nouveau mot de passe',
    },
    'sendCode': {
      'ku': 'ناردنی کۆد',
      'ar': 'إرسال الرمز',
      'en': 'Send code',
 
      'tr': 'Kod Gönder',
      'fr': 'Envoyer le code',
    },
    'verifyCode': {
      'ku': 'پشتڕاستکردنەوەی کۆد',
      'ar': 'التحقق من الرمز',
      'en': 'Verify code',
 
      'tr': 'Kodu Doğrula',
      'fr': 'Vérifier le code',
    },
    'resetPassword': {
      'ku': 'گۆڕینی وشەی نهێنی',
      'ar': 'إعادة تعيين كلمة المرور',
      'en': 'Reset password',
 
      'tr': 'Şifreyi Sıfırla',
      'fr': 'Réinitialiser le mot de passe',
    },

    // ─── Onboarding ───
    'skip': {
      'ku': 'بازدان',
      'ar': 'تخطي',
      'en': 'Skip',
 
      'tr': 'Atla',
      'fr': 'Passer',
    },
    'next': {
      'ku': 'دواتر',
      'ar': 'التالي',
      'en': 'Next',
 
      'tr': 'İleri',
      'fr': 'Suivant',
    },
    'getStarted': {
      'ku': 'دەست پێ بکە',
      'ar': 'ابدأ الآن',
      'en': 'Get Started',
 
      'tr': 'Başla',
      'fr': 'Commencer',
    },
    'onboarding1Title': {
      'ku': 'خوێندنگاکانی کوردستان و عێراق',
      'ar': 'مؤسسات كوردستان والعراق',
      'en': 'Kurdistan & Iraq Institutions',
 
      'tr': 'Kürdistan ve Irak Kurumları',
      'fr': 'Établissements du Kurdistan et d\'Irak',
    },
    'onboarding1Desc': {
      'ku': 'هەموو زانکۆ، پەیمانگە، قوتابخانە و باخچەکان لەیەک شوێندا',
      'ar': 'جميع الجامعات والمعاهد والمدارس والروضات في مكان واحد',
      'en': 'All universities, institutes, schools and kindergartens in one place',
 
      'tr': 'Tüm üniversiteler, enstitüler, okullar ve anaokulları tek bir yerde',
      'fr': 'Toutes les universités, instituts, écoles et maternelles en un seul endroit',
    },
    'onboarding2Title': {
      'ku': 'گەڕان و دۆزینەوە',
      'ar': 'البحث والاستكشاف',
      'en': 'Search & Discover',
 
      'tr': 'Ara ve Keşfet',
      'fr': 'Rechercher et Découvrir',
    },
    'onboarding2Desc': {
      'ku': 'بە ئاسانی بگەڕێ و خوێندنگای گونجاوت بدۆزەوە',
      'ar': 'ابحث بسهولة وابحث عن المؤسسة المناسبة لك',
      'en': 'Easily search and find the right institution for you',
 
      'tr': 'Kolayca ara ve doğru kurumu bul',
      'fr': 'Recherchez facilement et trouvez le bon établissement',
    },
    'onboarding3Title': {
      'ku': 'نەخشەی شوێنەکان',
      'ar': 'خريطة المواقع',
      'en': 'Location Map',
 
      'tr': 'Konum Haritası',
      'fr': 'Carte des emplacements',
    },
    'onboarding3Desc': {
      'ku': 'شوێنی خوێندنگاکان ببینە لەسەر نەخشە',
      'ar': 'شاهد مواقع المؤسسات على الخريطة',
      'en': 'See institution locations on the map',
 
      'tr': 'Kurumların konumlarını haritada gör',
      'fr': 'Voir les emplacements des établissements sur la carte',
    },
    'onboarding4Title': {
      'ku': 'پاشەکەوتکردن',
      'ar': 'حفظ المفضلات',
      'en': 'Save Favorites',
 
      'tr': 'Favorilere Ekle',
      'fr': 'Sauvegarder les favoris',
    },
    'onboarding4Desc': {
      'ku': 'خوێندنگای دڵخوازت پاشەکەوت بکە بۆ دواتر',
      'ar': 'احفظ مؤسساتك المفضلة للرجوع إليها لاحقاً',
      'en': 'Save your favorite institutions for later',
 
      'tr': 'Favori kurumlarını daha sonra için kaydet',
      'fr': 'Sauvegardez vos établissements favoris pour plus tard',
    },

    // ─── Report ───
    'reportInstitution': {
      'ku': 'ڕاپۆرتکردن',
      'ar': 'الإبلاغ',
      'en': 'Report',
 
      'tr': 'Şikayet Et',
      'fr': 'Signaler',
    },
    'selectReportType': {
      'ku': 'جۆری ڕاپۆرت هەڵبژێرە',
      'ar': 'اختر نوع البلاغ',
      'en': 'Select report type',
 
      'tr': 'Şikayet türünü seçin',
      'fr': 'Sélectionnez le type de signalement',
    },
    'additionalDetails': {
      'ku': 'وردەکارییەکانی زیادە',
      'ar': 'تفاصيل إضافية',
      'en': 'Additional details',
 
      'tr': 'Ek Detaylar',
      'fr': 'Détails supplémentaires',
    },
    'additionalDetailsOptional': {
      'ku': 'ئارەزوومەندانە - بۆ باشترکردنی ڕاپۆرتەکەت',
      'ar': 'اختياري - لتحسين بلاغك',
      'en': 'Optional - to improve your report',
 
      'tr': 'İsteğe bağlı - şikayetinizi geliştirmek için',
      'fr': 'Optionnel - pour améliorer votre signalement',
    },
    'describeIssue': {
      'ku': 'کێشەکە شرۆڤە بکە...',
      'ar': 'اشرح المشكلة...',
      'en': 'Describe the issue...',
 
      'tr': 'Sorunu açıklayın...',
      'fr': 'Décrivez le problème...',
    },
    'submitReport': {
      'ku': 'ناردنی ڕاپۆرت',
      'ar': 'إرسال البلاغ',
      'en': 'Submit report',
 
      'tr': 'Şikayet Gönder',
      'fr': 'Envoyer le signalement',
    },
    'reportSubmitted': {
      'ku': 'سوپاس! ڕاپۆرتەکەت نێردرا',
      'ar': 'شكراً! تم إرسال بلاغك',
      'en': 'Thanks! Your report has been submitted',
 
      'tr': 'Teşekkürler! Şikayetiniz gönderildi',
      'fr': 'Merci ! Votre signalement a été soumis',
    },

    // ─── Force Update ───
    'updateAvailable': {
      'ku': 'نوێکردنەوەی نوێ بەردەستە',
      'ar': 'تحديث جديد متاح',
      'en': 'Update Available',
 
      'tr': 'Güncelleme Mevcut',
      'fr': 'Mise à jour disponible',
    },
    'version': {
      'ku': 'وەشان',
      'ar': 'الإصدار',
      'en': 'Version',
 
      'tr': 'Sürüm',
      'fr': 'Version',
    },
    'forceUpdateDesc': {
      'ku': 'پێویستە ئەپلیکەیشنەکە نوێ بکەیتەوە بۆ بەردەوامبوون',
      'ar': 'يجب تحديث التطبيق للاستمرار',
      'en': 'You must update the app to continue',
 
      'tr': 'Devam etmek için uygulamayı güncellemeniz gerekiyor',
      'fr': 'Vous devez mettre à jour l\'application pour continuer',
    },
    'updateDesc': {
      'ku': 'وەشانی نوێ بەردەستە بۆ تایبەتمەندی و چاکسازی باشتر',
      'ar': 'إصدار جديد متاح بميزات وإصلاحات أفضل',
      'en': 'A new version is available with better features and fixes',
 
      'tr': 'Daha iyi özellikler ve düzeltmelerle yeni sürüm mevcut',
      'fr': 'Nouvelle version disponible avec de meilleures fonctionnalités',
    },
    'whatsNew': {
      'ku': 'چی نوێیە؟',
      'ar': 'ما الجديد؟',
      'en': "What's new?",
 
      'tr': 'Yenilikler?',
      'fr': 'Quoi de neuf ?',
    },
    'updateNow': {
      'ku': 'نوێکردنەوە',
      'ar': 'تحديث الآن',
      'en': 'Update Now',
 
      'tr': 'Şimdi Güncelle',
      'fr': 'Mettre à jour',
    },
    'later': {
      'ku': 'دواتر',
      'ar': 'لاحقاً',
      'en': 'Later',
 
      'tr': 'Daha Sonra',
      'fr': 'Plus tard',
    },

    // ─── Nearby ───
    'nearbyTitle': {
      'ku': 'نزیکترینەکان',
      'ar': 'الأقرب',
      'en': 'Nearby',
 
      'tr': 'Yakındakiler',
      'fr': 'À proximité',
    },
    'nearbyDiscover': {
      'ku': 'نزیکترین خوێندنگاکان بدۆزەرەوە',
      'ar': 'اكتشف أقرب المؤسسات',
      'en': 'Discover nearby institutions',
 
      'tr': 'En yakın kurumları keşfet',
      'fr': 'Découvrir les établissements proches',
    },
    'nearbyDiscoverDesc': {
      'ku': 'دەستگەیشتن بە GPS بۆ بینینی نزیکترینەکان',
      'ar': 'اسمح بالوصول إلى GPS لرؤية الأقرب',
      'en': 'Allow GPS access to see nearest ones',
 
      'tr': 'En yakındakileri görmek için GPS erişimine izin verin',
      'fr': 'Autorisez l\'accès GPS pour voir les plus proches',
    },
    'nearbyLoading': {
      'ku': 'شوێنەکەت دەدۆزرێتەوە...',
      'ar': 'جارٍ البحث عن موقعك...',
      'en': 'Finding your location...',
 
      'tr': 'Konumunuz aranıyor...',
      'fr': 'Recherche de votre position...',
    },
    'nearbyMap': {
      'ku': 'لە ماپ',
      'ar': 'الخريطة',
      'en': 'Map',
 
      'tr': 'Harita',
      'fr': 'Carte',
    },

    // ─── Posts ───
    'postsTab': {
      'ku': 'پۆستەکان',
      'ar': 'المنشورات',
      'en': 'Posts',
 
      'tr': 'Gönderiler',
      'fr': 'Publications',
    },
    'noPosts': {
      'ku': 'هیچ پۆستێک نییە',
      'ar': 'لا توجد منشورات',
      'en': 'No posts yet',
 
      'tr': 'Gönderi yok',
      'fr': 'Aucune publication',
    },
    'noPostsDesc': {
      'ku': 'هێشتا پۆستێک بڵاو نەکراوەتەوە',
      'ar': 'لم يتم نشر أي منشور بعد',
      'en': 'No posts have been published yet',
 
      'tr': 'Henüz hiçbir gönderi paylaşılmadı',
      'fr': 'Aucune publication n\'a été publiée pour l\'instant',
    },
    'writePost': {
      'ku': 'نووسینی پۆست',
      'ar': 'كتابة منشور',
      'en': 'Write a post',
 
      'tr': 'Gönderi Yaz',
      'fr': 'Écrire une publication',
    },
    'postTitle': {
      'ku': 'بابەت',
      'ar': 'العنوان',
      'en': 'Title',
 
      'tr': 'Başlık',
      'fr': 'Titre',
    },
    'postTitleHint': {
      'ku': 'بابەتی پۆستەکە...',
      'ar': 'عنوان المنشور...',
      'en': 'Post title...',
 
      'tr': 'Gönderi başlığı...',
      'fr': 'Titre de la publication...',
    },
    'postContent': {
      'ku': 'ناوەڕۆک',
      'ar': 'المحتوى',
      'en': 'Content',
 
      'tr': 'İçerik',
      'fr': 'Contenu',
    },
    'postContentHint': {
      'ku': 'ناوەڕۆکی پۆستەکە بنووسە...',
      'ar': 'اكتب محتوى المنشور...',
      'en': 'Write your post content...',
 
      'tr': 'Gönderi içeriğini yaz...',
      'fr': 'Rédigez votre publication...',
    },
    'publishPost': {
      'ku': 'بڵاوکردنەوە',
      'ar': 'نشر',
      'en': 'Publish',
 
      'tr': 'Yayınla',
      'fr': 'Publier',
    },
    'postPublished': {
      'ku': 'پۆستەکەت بڵاوکرایەوە!',
      'ar': 'تم نشر منشورك!',
      'en': 'Your post has been published!',
 
      'tr': 'Gönderiniz yayınlandı!',
      'fr': 'Votre publication a été publiée !',
    },
    'postAwaitingApproval': {
      'ku': 'پۆستەکەت نێردرا و چاوەڕوانی پەسەندکردنە',
      'ar': 'تم إرسال منشورك وينتظر الموافقة',
      'en': 'Your post has been sent and is awaiting approval',
 
      'tr': 'Gönderiniz gönderildi ve onay bekliyor',
      'fr': 'Votre publication a été envoyée et attend l\'approbation',
    },
    'deletePost': {
      'ku': 'سڕینەوەی پۆست',
      'ar': 'حذف المنشور',
      'en': 'Delete post',
 
      'tr': 'Gönderiyi Sil',
      'fr': 'Supprimer la publication',
    },
    'deletePostConfirm': {
      'ku': 'دڵنیایت دەتەوێت ئەم پۆستە بسڕیتەوە؟',
      'ar': 'هل أنت متأكد أنك تريد حذف هذا المنشور؟',
      'en': 'Are you sure you want to delete this post?',
 
      'tr': 'Bu gönderiyi silmek istediğinizden emin misiniz?',
      'fr': 'Êtes-vous sûr de vouloir supprimer cette publication ?',
    },
    'postDeleted': {
      'ku': 'پۆستەکە سڕایەوە',
      'ar': 'تم حذف المنشور',
      'en': 'Post deleted',
 
      'tr': 'Gönderi silindi',
      'fr': 'Publication supprimée',
    },
    'addImage': {
      'ku': 'زیادکردنی وێنە',
      'ar': 'إضافة صورة',
      'en': 'Add image',
 
      'tr': 'Görsel Ekle',
      'fr': 'Ajouter une image',
    },
    'ago': {
      'ku': 'لەمەوبەر',
      'ar': 'منذ',
      'en': 'ago',
 
      'tr': 'önce',
      'fr': 'il y a',
    },

    // ─── Admin Dashboard ───
    'adminDashboard': {
      'ku': 'داشبۆردی ئەدمین',
      'ar': 'لوحة الإدارة',
      'en': 'Admin Dashboard',
 
      'tr': 'Yönetici Paneli',
      'fr': 'Tableau de bord administrateur',
    },
    'adminPosts': {
      'ku': 'بەڕێوەبردنی پۆستەکان',
      'ar': 'إدارة المنشورات',
      'en': 'Manage Posts',
 
      'tr': 'Gönderileri Yönet',
      'fr': 'Gérer les publications',
    },
    'adminPostsDesc': {
      'ku': 'پەسەندکردن و بەڕێوەبردنی هەموو پۆستەکان',
      'ar': 'الموافقة على المنشورات وإدارتها',
      'en': 'Approve and manage all posts',
 
      'tr': 'Tüm gönderileri onayla ve yönet',
      'fr': 'Approuver et gérer toutes les publications',
    },
    'allPosts': {
      'ku': 'هەموو پۆستەکان',
      'ar': 'جميع المنشورات',
      'en': 'All Posts',
 
      'tr': 'Tüm Gönderiler',
      'fr': 'Toutes les publications',
    },
    'pendingPosts': {
      'ku': 'چاوەڕوانی پەسەند',
      'ar': 'بانتظار الموافقة',
      'en': 'Pending',
 
      'tr': 'Onay Bekliyor',
      'fr': 'En attente',
    },
    'approvedPosts': {
      'ku': 'پەسەندکراو',
      'ar': 'تمت الموافقة',
      'en': 'Approved',
 
      'tr': 'Onaylandı',
      'fr': 'Approuvé',
    },
    'approvePost': {
      'ku': 'پەسەندکردن',
      'ar': 'موافقة',
      'en': 'Approve',
 
      'tr': 'Onayla',
      'fr': 'Approuver',
    },
    'rejectPost': {
      'ku': 'ڕەتکردنەوە',
      'ar': 'رفض',
      'en': 'Reject',
 
      'tr': 'Reddet',
      'fr': 'Rejeter',
    },
    'postApproved': {
      'ku': 'پۆستەکە پەسەندکرا',
      'ar': 'تمت الموافقة على المنشور',
      'en': 'Post approved',
 
      'tr': 'Gönderi onaylandı',
      'fr': 'Publication approuvée',
    },
    'postRejected': {
      'ku': 'پۆستەکە ڕەتکرایەوە',
      'ar': 'تم رفض المنشور',
      'en': 'Post rejected',
 
      'tr': 'Gönderi reddedildi',
      'fr': 'Publication rejetée',
    },
    'adminInstitutions': {
      'ku': 'بەڕێوەبردنی دامەزراوەکان',
      'ar': 'إدارة المؤسسات',
      'en': 'Manage Institutions',
 
      'tr': 'Kurumları Yönet',
      'fr': 'Gérer les établissements',
    },
    'adminInstitutionsDesc': {
      'ku': 'سەیرکردن و دەستکاری دامەزراوەکان',
      'ar': 'عرض وتعديل المؤسسات',
      'en': 'View and edit institutions',
 
      'tr': 'Kurumları görüntüle ve düzenle',
      'fr': 'Afficher et modifier les établissements',
    },
    'totalPosts': {
      'ku': 'کۆی پۆستەکان',
      'ar': 'إجمالي المنشورات',
      'en': 'Total Posts',
 
      'tr': 'Toplam Gönderiler',
      'fr': 'Total des publications',
    },
    'pending': {
      'ku': 'چاوەڕوان',
      'ar': 'معلق',
      'en': 'Pending',
 
      'tr': 'Bekliyor',
      'fr': 'En attente',
    },
    'approved': {
      'ku': 'پەسەندکراو',
      'ar': 'موافق عليه',
      'en': 'Approved',
 
      'tr': 'Onaylandı',
      'fr': 'Approuvé',
    },
    'institutionName2': {
      'ku': 'ناوی دامەزراوە',
      'ar': 'اسم المؤسسة',
      'en': 'Institution',
 
      'tr': 'Kurum',
      'fr': 'Établissement',
    },
    'like': {
      'ku': 'پەسەند',
      'ar': 'إعجاب',
      'en': 'Like',
 
      'tr': 'Beğen',
      'fr': 'J\'aime',
    },
    'comment': {
      'ku': 'کۆمێنت',
      'ar': 'تعليق',
      'en': 'Comment',
 
      'tr': 'Yorum',
      'fr': 'Commentaire',
    },
    'shareLabel': {
      'ku': 'هاوبەش',
      'ar': 'مشاركة',
      'en': 'Share',
 
      'tr': 'Paylaş',
      'fr': 'Partager',
    },

    // ─── Admin: Institutions ───
    'adminInstitutionsTab': {
      'ku': 'دامەزراوەکان',
      'ar': 'المؤسسات',
      'en': 'Institutions',
 
      'tr': 'Kurumlar',
      'fr': 'Établissements',
    },
    'approveInstitution': {
      'ku': 'پەسەندکردن',
      'ar': 'موافقة',
      'en': 'Approve',
 
      'tr': 'Onayla',
      'fr': 'Approuver',
    },
    'rejectInstitution': {
      'ku': 'ڕەتکردنەوە',
      'ar': 'رفض',
      'en': 'Reject',
 
      'tr': 'Reddet',
      'fr': 'Rejeter',
    },
    'institutionApproved': {
      'ku': 'دامەزراوەکە پەسەندکرا',
      'ar': 'تمت الموافقة على المؤسسة',
      'en': 'Institution approved',
 
      'tr': 'Kurum onaylandı',
      'fr': 'Établissement approuvé',
    },
    'institutionRejected': {
      'ku': 'دامەزراوەکە ڕەتکرایەوە',
      'ar': 'تم رفض المؤسسة',
      'en': 'Institution rejected',
 
      'tr': 'Kurum reddedildi',
      'fr': 'Établissement rejeté',
    },
    'totalInstitutions': {
      'ku': 'کۆی دامەزراوەکان',
      'ar': 'إجمالي المؤسسات',
      'en': 'Total',
 
      'tr': 'Toplam',
      'fr': 'Total',
    },
    'noInstitutions': {
      'ku': 'هیچ دامەزراوەیەک نەدۆزرایەوە',
      'ar': 'لا توجد مؤسسات',
      'en': 'No institutions found',
 
      'tr': 'Kurum bulunamadı',
      'fr': 'Aucun établissement trouvé',
    },

    // ─── Admin: Reports ───
    'adminReportsTab': {
      'ku': 'ڕاپۆرتەکان',
      'ar': 'التقارير',
      'en': 'Reports',
 
      'tr': 'Raporlar',
      'fr': 'Rapports',
    },
    'totalReports': {
      'ku': 'کۆی ڕاپۆرتەکان',
      'ar': 'إجمالي التقارير',
      'en': 'Total',
 
      'tr': 'Toplam',
      'fr': 'Total',
    },
    'markReviewed': {
      'ku': 'پشکنراو',
      'ar': 'تمت المراجعة',
      'en': 'Mark Reviewed',
 
      'tr': 'İncelendi',
      'fr': 'Marqué comme examiné',
    },
    'markDismissed': {
      'ku': 'ڕەتکردنەوە',
      'ar': 'رفض',
      'en': 'Dismiss',
 
      'tr': 'Reddet',
      'fr': 'Rejeter',
    },
    'reportReviewed': {
      'ku': 'ڕاپۆرتەکە پشکنرا',
      'ar': 'تمت مراجعة التقرير',
      'en': 'Report reviewed',
 
      'tr': 'Rapor incelendi',
      'fr': 'Rapport examiné',
    },
    'reportDismissed': {
      'ku': 'ڕاپۆرتەکە ڕەتکرایەوە',
      'ar': 'تم رفض التقرير',
      'en': 'Report dismissed',
 
      'tr': 'Rapor reddedildi',
      'fr': 'Rapport rejeté',
    },
    'noReports': {
      'ku': 'هیچ ڕاپۆرتێک نەدۆزرایەوە',
      'ar': 'لا توجد تقارير',
      'en': 'No reports found',
 
      'tr': 'Rapor bulunamadı',
      'fr': 'Aucun rapport trouvé',
    },
    'dismissed': {
      'ku': 'ڕەتکراو',
      'ar': 'مرفوض',
      'en': 'Dismissed',
 
      'tr': 'Reddedildi',
      'fr': 'Rejeté',
    },
    'reviewed': {
      'ku': 'پشکنراو',
      'ar': 'تمت مراجعته',
      'en': 'Reviewed',
 
      'tr': 'İncelendi',
      'fr': 'Examiné',
    },

    // ─── Admin: CVs ───
    'adminCvsTab': {
      'ku': 'CVکان',
      'ar': 'السير الذاتية',
      'en': 'CVs',
 
      'tr': 'CV\'ler',
      'fr': 'CV',
    },
    'totalCvs': {
      'ku': 'کۆی CVکان',
      'ar': 'إجمالي السير الذاتية',
      'en': 'Total CVs',
 
      'tr': 'Toplam CV',
      'fr': 'Total des CV',
    },
    'markCvReviewed': {
      'ku': 'پشکنراو',
      'ar': 'تمت المراجعة',
      'en': 'Mark Reviewed',
 
      'tr': 'İncelendi',
      'fr': 'Marqué comme examiné',
    },
    'markCvPending': {
      'ku': 'چاوەڕوان',
      'ar': 'معلق',
      'en': 'Mark Pending',
 
      'tr': 'Bekliyor',
      'fr': 'En attente',
    },
    'cvReviewed': {
      'ku': 'CV پشکنرا',
      'ar': 'تمت مراجعة السيرة الذاتية',
      'en': 'CV reviewed',
 
      'tr': 'CV incelendi',
      'fr': 'CV examiné',
    },
    'cvPending': {
      'ku': 'CV گەڕایەوە بۆ چاوەڕوانکردن',
      'ar': 'عادت السيرة الذاتية للانتظار',
      'en': 'CV set to pending',
 
      'tr': 'CV beklemeye alındı',
      'fr': 'CV mis en attente',
    },
    'noCvs': {
      'ku': 'هیچ CVیەک نەدۆزرایەوە',
      'ar': 'لا توجد سير ذاتية',
      'en': 'No CVs found',
 
      'tr': 'CV bulunamadı',
      'fr': 'Aucun CV trouvé',
    },
    'cvField': {
      'ku': 'بواری پسپۆڕی',
      'ar': 'مجال التخصص',
      'en': 'Field',
 
      'tr': 'Uzmanlık Alanı',
      'fr': 'Domaine de spécialité',
    },
    'cvEducation': {
      'ku': 'ئاستی خوێندن',
      'ar': 'مستوى التعليم',
      'en': 'Education',
 
      'tr': 'Eğitim Seviyesi',
      'fr': 'Niveau d\'éducation',
    },

    // ─── Offline / Connectivity ───
    'noInternet': {
      'ku': 'ئینتەرنەت نییە',
      'ar': 'لا يوجد اتصال بالإنترنت',
      'en': 'No Internet Connection',
 
      'tr': 'İnternet Bağlantısı Yok',
      'fr': 'Pas de connexion Internet',
    },
    'noInternetDesc': {
      'ku': 'داتای کەش نیشاندەدرێت. پەیوەندیت بپشکنە.',
      'ar': 'يتم عرض البيانات المخزنة. تحقق من اتصالك.',
      'en': 'Showing cached data. Check your connection.',
 
      'tr': 'Önbelleğe alınmış veriler gösteriliyor. Bağlantınızı kontrol edin.',
      'fr': 'Affichage des données en cache. Vérifiez votre connexion.',
    },
  };
}
