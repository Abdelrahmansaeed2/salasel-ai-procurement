import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find();

    return Obx(() {
      final isAr = controller.currentLanguage.value == 'ar';
      return TextButton.icon(
        onPressed: controller.toggleLanguage,
        icon: Icon(
          Icons.language,
          color: AppColors.primary,
          size: 20.w,
        ),
        label: Text(
          isAr ? 'English' : 'عربي',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}
