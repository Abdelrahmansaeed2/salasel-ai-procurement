import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/controllers/settings_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/orders/presentation/screens/checkout_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  final prefs = await SharedPreferences.getInstance();
  Get.put(SettingsController(prefs));

  runApp(SalaselApp());
}

class SalaselApp extends StatelessWidget {
  const SalaselApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    final langCode = settingsController.currentLanguage.value;
    final locale = langCode == 'en' ? Locale('en', 'US') : Locale('ar', 'AE');

    return ScreenUtilInit(
      designSize: Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'سلاسل',
          debugShowCheckedModeBanner: false,
          
          translations: AppTranslations(),
          locale: locale,
          fallbackLocale: Locale('ar', 'AE'),

          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ar', 'AE'),
            Locale('en', 'US'),
          ],

          theme: AppTheme.getTheme(langCode),
          home: child,
        );
      },
      child: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      displayDuration: Duration(seconds: 3),
      onTimeout: () {
        // Changed temporarily to show the CheckoutScreen directly for testing
               Get.off(() => LoginScreen(),
            transition: Transition.fadeIn,
            duration: Duration(milliseconds: 400));
      },
    );
  }
}
