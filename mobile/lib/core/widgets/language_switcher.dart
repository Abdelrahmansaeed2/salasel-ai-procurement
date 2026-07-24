import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_colors.dart';

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
          size: 20,
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
