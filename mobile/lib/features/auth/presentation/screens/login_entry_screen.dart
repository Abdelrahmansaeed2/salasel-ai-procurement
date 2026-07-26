import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/login_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48.h),
                const _SalaselLogo(),
                SizedBox(height: 36.h),
                const _WelcomeSection(),
                SizedBox(height: 32.h),
                _AuthFieldsSection(controller: controller),
                Obx(() {
                  final error = controller.errorMessage.value;
                  if (error.isEmpty) return SizedBox(height: 24.h);
                  return Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFFBA1A1A),
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                Obx(() => _ContinueButton(
                      enabled: controller.hasText.value,
                      onPressed: controller.hasText.value
                          ? controller.submitLogin
                          : null,
                    )),
                SizedBox(height: 20.h),
                const _OrDivider(),
                SizedBox(height: 20.h),
                const _WhatsAppButton(),
                SizedBox(height: 48.h),
                const _FeatureRow(),
                SizedBox(height: 32.h),
                const _FooterTerms(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SalaselLogo extends StatelessWidget {
  const _SalaselLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/salasel_logo.png',
        width: 140.w,
        height: 94.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('👋', style: TextStyle(fontSize: 26.sp)),
              SizedBox(width: 8.w),
              Text(
                'أهلاً بك',
                style: AppTextStyles.welcomeTitle,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'أدخل بريدك الإلكتروني وكلمة المرور لتسجيل الدخول',
          style: AppTextStyles.welcomeSubtitle,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _AuthFieldsSection extends StatelessWidget {
  const _AuthFieldsSection({required this.controller});
  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'البريد الإلكتروني',
          style: AppTextStyles.fieldLabel,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 10.h),
        Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.0.w),
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller.emailController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'example@domain.com',
              hintStyle: AppTextStyles.fieldHint.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 15.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              isDense: true,
            ),
            style: AppTextStyles.fieldValue.copyWith(fontSize: 16.sp),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'كلمة المرور',
          style: AppTextStyles.fieldLabel,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 10.h),
        Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.0.w),
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller.passwordController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '********',
              hintStyle: AppTextStyles.fieldHint.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 15.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              isDense: true,
            ),
            style: AppTextStyles.fieldValue.copyWith(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 54.h,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.disabled,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              'متابعة',
              style: enabled
                  ? AppTextStyles.primaryButton
                  : AppTextStyles.primaryButtonDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'أو سجل دخولك عبر',
            style: AppTextStyles.dividerLabel,
            textDirection: TextDirection.rtl,
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1.0.w),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {},
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تسجيل عبر واتساب',
                  style: AppTextStyles.whatsappButton.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10.w),
                SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  static const _features = [
    _FeatureItem(icon: Icons.local_shipping_outlined, label: 'شبكة موردين\nسريعة'),
    _FeatureItem(icon: Icons.add_circle_outline_rounded, label: 'طلب بالذكاء\nالاصطناعي'),
    _FeatureItem(icon: Icons.verified_user_outlined, label: 'تسجيل آمن'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _features.map((f) => _FeatureCard(item: f)).toList(),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 22.w),
          ),
          SizedBox(height: 8.h),
          Text(
            item.label,
            style: AppTextStyles.featureLabel,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _FooterTerms extends StatelessWidget {
  const _FooterTerms();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'بالمتابعة، أنت توافق على',
          style: AppTextStyles.footerBody,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 6.h),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'سياسة الخصوصية',
                  style: AppTextStyles.footerLink.copyWith(decoration: TextDecoration.underline),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text('و', style: AppTextStyles.footerBody),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'شروط الاستخدام',
                  style: AppTextStyles.footerLink.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
