import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'hello': 'Hello',
          'language': 'Language',
          'switch_lang': 'عربي',
        },
        'ar_AE': {
          'hello': 'مرحباً',
          'language': 'اللغة',
          'switch_lang': 'English',
        },
      };
}
