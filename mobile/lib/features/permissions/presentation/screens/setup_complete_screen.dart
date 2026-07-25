import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/screens/home_screen.dart';

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
          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'اكتمل الإعداد',
          style: AppTextStyles.welcomeTitle.copyWith(
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.whatsapp, size: 16),
                const SizedBox(width: 4),
                Text(
                  'تم بنجاح',
                  style: AppTextStyles.fieldValue.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: AppColors.disabled),
                            SizedBox(height: 8),
                            Text(
                              'أضف صورة\nassets/images/setup_complete_illustration.png', 
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
              const SizedBox(height: 24),
              
              // Title
              Text(
                'أنت جاهز للبدء!',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'تم تفعيل جميع الصلاحيات اللازمة لتجربة توريد ذكية وسلسة. يمكنك الآن البدء في إدارة متجرك بكل سهولة.',
                textAlign: TextAlign.center,
                style: AppTextStyles.welcomeSubtitle.copyWith(height: 1.6),
              ),
              const SizedBox(height: 32),
              
              // Status Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.notifications_none,
                      title: 'التنبيهات مفعلة',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.location_on_outlined,
                      title: 'الموقع مفعل',
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
              
              // Enter Store Button
              ElevatedButton(
                onPressed: () {
                  Get.offAll(
                    () => const HomeScreen(),
                    transition: Transition.fadeIn,
                  );
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
                    const Icon(Icons.storefront, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'الدخول للمتجر',
                      style: AppTextStyles.primaryButton,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Footer Text
              Text(
                'سلاسل © 2024 - منصة التوريد الذكية',
                textAlign: TextAlign.center,
                style: AppTextStyles.footerBody.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.fieldValue.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
