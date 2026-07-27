import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';
import '../theme/auth_theme.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_labeled_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_trust_badges.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: AuthColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                const AuthHeader(subtitle: 'نرجو منك إدخال بياناتك لإنشاء حساب'),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AuthColors.background,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthLabeledField(
                        label: 'الاسم بالكامل',
                        controller: controller.nameController,
                        hint: 'الاسم',
                      ),
                      SizedBox(height: 20.h),
                      AuthLabeledField(
                        label: 'البريد الإلكتروني',
                        controller: controller.emailController,
                        hint: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.h),
                      AuthLabeledField(
                        label: 'الرقم السري',
                        controller: controller.passwordController,
                        hint: '..............',
                        obscureText: true,
                      ),
                      SizedBox(height: 20.h),
                      Obx(() {
                        final error = controller.errorMessage.value;
                        if (error.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AuthTextStyles.errorText,
                          ),
                        );
                      }),
                      Obx(
                        () => AuthPrimaryButton(
                          label: 'إنشاء حساب',
                          enabled: controller.hasText.value,
                          loading: controller.isLoading.value,
                          onPressed: controller.submitRegister,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: AuthSwitchPrompt(
                          prompt: 'هل لديك حساب بالفعل؟',
                          linkLabel: 'سجل الدخول',
                          onTap: controller.goToLogin,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      const AuthTrustBadges(),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                AuthFooterTerms(
                  onPrivacyTap: () {},
                  onTermsTap: () {},
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
