

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../permissions/presentation/screens/setup_complete_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          icon: Icon(Icons.arrow_forward, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'تنبيهات',
          style: AppTextStyles.welcomeTitle.copyWith(
            fontSize: 18.sp,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 20.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 1),
              
              // Icon Circle
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                    size: 40.w,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              
              // Title
              Text(
                'تحديثات الطلبات الفورية',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22.sp),
              ),
              SizedBox(height: 16.h),
              
              // Subtitle
              Text(
                'ابق على اطلاع دائم بحالة طلباتك، من قبول المورد وحتى وصول الشحنة إلى باب متجرك.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle.copyWith(height: 1.6.h),
              ),
              
              Spacer(flex: 2),
              
              // Enable Button
              ElevatedButton(
                onPressed: () async {
                  
                  var status = await Permission.notification.request();
                  if (status.isGranted) {
                    
                    Get.to(() => SetupCompleteScreen());
                  } else {
                    
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_back_ios, size: 16.w), // Points left (Forward in RTL)
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              
              // Later Button
              OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_back_ios, size: 16.w, color: AppColors.textSecondary),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
