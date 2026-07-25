
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notifications/presentation/screens/notifications_permission_screen.dart';

class MicPermissionScreen extends StatelessWidget {
  const MicPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: AppColors.disabled),
                            SizedBox(height: 8),
                            Text(
                              'أضف صورة\nassets/images/mic_permission_illustration.png', 
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'اسمح بالوصول إلى الميكروفون',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'سلاسل تستخدم الميكروفون فقط عند تفعيلك للطلب الصوتي — ولن يتم تسجيل أي شيء في الخلفية.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle,
              ),
              const SizedBox(height: 32),
              
              // Features List
              _buildFeatureItem(
                icon: Icons.mic_none_outlined,
                text: 'اطلب بضاعتك بالصوت بدون كتابة حرف واحد',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                icon: Icons.smart_toy_outlined,
                text: 'الذكاء الاصطناعي يحوّل كلامك إلى طلب فوري',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                icon: Icons.lock_outline,
                text: 'صوتك لا يُحفظ ولا يُشارك مع أي طرف ثالث',
              ),
              
              const Spacer(flex: 1),
              
              // Allow Button
              ElevatedButton(
                onPressed: () {
                  // الانتقال إلى شاشة التنبيهات
                  Get.to(() => const NotificationsPermissionScreen());
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
                    const Icon(Icons.mic, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'السماح بالوصول',
                      style: AppTextStyles.primaryButton,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Not Now Button
              TextButton(
                onPressed: () {
                  Get.back();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
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
