
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notifications/presentation/screens/notifications_permission_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MicPermissionScreen extends StatelessWidget {
  const MicPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 20.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration Placeholder
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/images/mic_permission_illustration.png',
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64.w, color: AppColors.disabled),
                            SizedBox(height: 8.h),
                            Text(
                              'أضف صورة\nassets/images/mic_permission_illustration.png', 
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              
              // Title
              Text(
                'اسمح بالوصول إلى الميكروفون',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22.sp),
              ),
              SizedBox(height: 12.h),
              
              // Subtitle
              Text(
                'سلاسل تستخدم الميكروفون فقط عند تفعيلك للطلب الصوتي — ولن يتم تسجيل أي شيء في الخلفية.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle,
              ),
              SizedBox(height: 32.h),
              
              // Features List
              _buildFeatureItem(
                icon: Icons.mic_none_outlined,
                text: 'اطلب بضاعتك بالصوت بدون كتابة حرف واحد',
              ),
              SizedBox(height: 20.h),
              _buildFeatureItem(
                icon: Icons.smart_toy_outlined,
                text: 'الذكاء الاصطناعي يحوّل كلامك إلى طلب فوري',
              ),
              SizedBox(height: 20.h),
              _buildFeatureItem(
                icon: Icons.lock_outline,
                text: 'صوتك لا يُحفظ ولا يُشارك مع أي طرف ثالث',
              ),
              
              Spacer(flex: 1),
              
              // Allow Button
              ElevatedButton(
                onPressed: () {
                  // الانتقال إلى شاشة التنبيهات
                  Get.to(() => NotificationsPermissionScreen());
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
                    Icon(Icons.mic, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'السماح بالوصول',
                      style: AppTextStyles.primaryButton,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              
              // Not Now Button
              TextButton(
                onPressed: () {
                  Get.back();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'ليس الآن',
                  style: AppTextStyles.fieldValue.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 22.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.fieldValue.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
