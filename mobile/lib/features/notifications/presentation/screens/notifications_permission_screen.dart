

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../permissions/presentation/screens/setup_complete_screen.dart';

class NotificationsPermissionScreen extends StatelessWidget {
  const NotificationsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'تنبيهات',
          style: AppTextStyles.welcomeTitle.copyWith(
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              
              // Icon Circle
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'تحديثات الطلبات الفورية',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'ابق على اطلاع دائم بحالة طلباتك، من قبول المورد وحتى وصول الشحنة إلى باب متجرك.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle.copyWith(height: 1.6),
              ),
              
              const Spacer(flex: 2),
              
              // Enable Button
              ElevatedButton(
                onPressed: () async {
                  
                  var status = await Permission.notification.request();
                  if (status.isGranted) {
                    
                    Get.to(() => const SetupCompleteScreen());
                  } else {
                    
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تفعيل التنبيهات',
                      style: AppTextStyles.primaryButton,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_back_ios, size: 16), // Points left (Forward in RTL)
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Later Button
              OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لاحقاً',
                      style: AppTextStyles.fieldValue.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
