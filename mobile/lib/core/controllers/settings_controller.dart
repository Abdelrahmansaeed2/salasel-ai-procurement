import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsController extends GetxController {
  final SharedPreferences _prefs;
  
  static const String _langKey = 'app_lang';

  SettingsController(this._prefs);

  RxString currentLanguage = 'ar'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    final savedLang = _prefs.getString(_langKey) ?? 'ar';
    currentLanguage.value = savedLang;
  }

  void toggleLanguage() {
    if (currentLanguage.value == 'ar') {
      _changeLanguage('en', 'US');
    } else {
      _changeLanguage('ar', 'AE');
    }
  }

  void _changeLanguage(String langCode, String countryCode) {
    currentLanguage.value = langCode;
    _prefs.setString(_langKey, langCode);
    
    final locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
    
    
    Get.changeTheme(AppTheme.getTheme(langCode));
  }
}
