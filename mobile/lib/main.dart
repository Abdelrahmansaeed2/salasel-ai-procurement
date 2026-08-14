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
import 'features/splash/presentation/screens/splash_screen.dart';
import 'core/network/api_client.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/shop_registration/presentation/screens/registration_submitted_screen.dart';
import 'features/stores/presentation/screens/welcomepage_screen.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_51U4G6zDRX6tSvbDOsuqtf0kTtSmzHXAOfQQ7g7hiEu4YijnNPmIbjOvklSQsBwlqQXHxycbHTy09GBH1smNB6mZt00sxmDSvV9'; // standard test key
  
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
      onTimeout: () async {
        final apiClient = ApiClient();
        final token = await apiClient.getToken();

        if (token != null && token.isNotEmpty) {
          try {
            // Fetch live user status to get isSetupCompleted
            final authResponse = await apiClient.dio.get('/auth/me');
            if (authResponse.statusCode == 200) {
              final isSetupCompleted = authResponse.data['isSetupCompleted'] == true;

              if (isSetupCompleted) {
                Get.offAll(() => const HomeScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 400));
              } else {
                // Setup is not completed. Check if they submitted a shop that is pending approval
                try {
                  final shopsResponse = await apiClient.dio.get('/merchants/me/shops');
                  final List shops = shopsResponse.data ?? [];

                  if (shops.isNotEmpty) {
                    // They have a shop but setup isn't complete -> Pending Approval
                    Get.offAll(() => const RegistrationSubmittedScreen(),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 400));
                  } else {
                    // No shop submitted yet -> Stores Welcome Screen
                    Get.offAll(() => const StoresScreen(),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 400));
                  }
                } catch (e) {
                  // If fetching shops fails, they likely don't have a shop yet
                  Get.offAll(() => const StoresScreen(),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 400));
                }
              }
            } else {
              Get.offAll(() => const LoginScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 400));
            }
          } catch (e) {
             Get.offAll(() => const LoginScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 400));
          }
        } else {
          Get.offAll(() => const LoginScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 400));
        }
      },
    );
  }
}
