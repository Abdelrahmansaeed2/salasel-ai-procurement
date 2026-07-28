import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({super.key});

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
          'اكتمل الإعداد',
          style: AppTextStyles.welcomeTitle.copyWith(
            fontSize: 18.sp,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.whatsapp, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  'تم بنجاح',
                  style: AppTextStyles.fieldValue.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration placeholder
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/images/setup_complete_illustration.png',
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
                              'أضف صورة\nassets/images/setup_complete_illustration.png', 
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
              SizedBox(height: 24.h),
              
              // Title
              Text(
                'أنت جاهز للبدء!',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22.sp),
              ),
              SizedBox(height: 12.h),
              
              // Subtitle
              Text(
                'تم تفعيل جميع الصلاحيات اللازمة لتجربة توريد ذكية وسلسة. يمكنك الآن البدء في إدارة متجرك بكل سهولة.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle.copyWith(height: 1.6.h),
              ),
              SizedBox(height: 32.h),
              
              // Status Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.notifications_none,
                      title: 'التنبيهات مفعلة',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.location_on_outlined,
                      title: 'الموقع مفعل',
                    ),
                  ),
                ],
              ),
              
              Spacer(flex: 1),
              
              // Enter Store Button
              ElevatedButton(
                onPressed: () {
                  Get.offAll(
                    () => HomeScreen(),
                    transition: Transition.fadeIn,
                  );
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
                    Icon(Icons.storefront, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'الدخول للمتجر',
                      style: AppTextStyles.primaryButton,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              
              // Footer Text
              Text(
                'سلاسل © 2024 - منصة التوريد الذكية',
                textAlign: TextAlign.center,
                style: AppTextStyles.footerBody.copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required String title}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTextStyles.fieldValue.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
