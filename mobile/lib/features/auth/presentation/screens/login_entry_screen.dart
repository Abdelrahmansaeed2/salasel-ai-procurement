import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/login_controller.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const _SalaselLogo(),
                const SizedBox(height: 36),
                const _WelcomeSection(),
                const SizedBox(height: 32),
                _AuthFieldsSection(controller: controller),
                Obx(() {
                  final error = controller.errorMessage.value;
                  if (error.isEmpty) return const SizedBox(height: 24);
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Color(0xFFBA1A1A),
                        fontFamily: 'Cairo',
                        fontSize: 13,
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
                const SizedBox(height: 20),
                const _OrDivider(),
                const SizedBox(height: 20),
                const _WhatsAppButton(),
                const SizedBox(height: 48),
                const _FeatureRow(),
                const SizedBox(height: 32),
                const _FooterTerms(),
                const SizedBox(height: 24),
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
        width: 140,
        height: 94,
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
              const Text('👋', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'أهلاً بك',
                style: AppTextStyles.welcomeTitle,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 10),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.0),
            borderRadius: BorderRadius.circular(12),
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
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
            style: AppTextStyles.fieldValue.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'كلمة المرور',
          style: AppTextStyles.fieldLabel,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.0),
            borderRadius: BorderRadius.circular(12),
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
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
            style: AppTextStyles.fieldValue.copyWith(fontSize: 16),
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
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.disabled,
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو سجل دخولك عبر',
            style: AppTextStyles.dividerLabel,
            textDirection: TextDirection.rtl,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 10),
                SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  width: 24,
                  height: 24,
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
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
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
        const SizedBox(height: 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
