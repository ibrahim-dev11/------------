import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ku');

  Locale get locale => _locale;
  bool get isRTL => _locale.languageCode == 'ku' || _locale.languageCode == 'ar';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.langKey) ?? AppConstants.defaultLang;
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> setLocale(String lang) async {
    if (!AppConstants.languages.containsKey(lang)) return;
    _locale = Locale(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.langKey, lang);
    notifyListeners();
  }
}
