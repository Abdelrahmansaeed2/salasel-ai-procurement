import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/otp_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    
    final OtpController controller = Get.put(OtpController(phoneNumber: phoneNumber));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32.h),
                const _ShieldIllustration(),
                SizedBox(height: 36.h),
                Text(
                  'أدخل رمز التحقق',
                  style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'تم إرسال رمز مكون من 6 أرقام إلى هاتفك',
                  style: AppTextStyles.welcomeSubtitle.copyWith(fontSize: 13.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                const _OtpBoxesRow(),
                SizedBox(height: 24.h),
                const _TimerResendRow(),
                SizedBox(height: 32.h),
                Obx(() => _VerifyButton(
                      enabled: controller.isComplete.value,
                      onPressed: controller.isComplete.value ? controller.submitOtp : null,
                    )),
                SizedBox(height: 24.h),
                const _E2EFooter(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldIllustration extends StatelessWidget {
  const _ShieldIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.w,
      height: 220.h,
      decoration: BoxDecoration(
        color: Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/otp_shield.png',
          width: 180.w,
          height: 180.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _OtpBoxesRow extends StatelessWidget {
  const _OtpBoxesRow();

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(OtpController.otpLength, (i) {
        final index = OtpController.otpLength - 1 - i;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _OtpBox(index: index),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();
    
    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: (e) => controller.onKeyEvent(e, index),
      child: Obx(() {
        final isFocused = controller.focusStates[index].value;
        final textController = controller.controllers[index];
        final bool filled = textController.text.isNotEmpty;

        return AnimatedContainer(
          duration: Duration(milliseconds: 150),
          width: 46.w,
          height: 54.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? AppColors.primary
                  : filled
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.border,
              width: isFocused ? 2.0 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: TextField(
            controller: textController,
            focusNode: controller.focusNodes[index],
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: AppTextStyles.fieldValue.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => controller.onDigitChanged(v, index),
          ),
        );
      }),
    );
  }
}

class _TimerResendRow extends StatelessWidget {
  const _TimerResendRow();

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();

    return Obx(() {
      final secondsLeft = controller.secondsLeft.value;
      final canResend = controller.canResend.value;
      final timerText = '0:${secondsLeft.toString().padLeft(2, '0')}';

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, size: 16.w, color: Color(0xFF475569)),
              SizedBox(width: 6.w),
              Text(
                timerText,
                style: AppTextStyles.fieldValue.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: canResend ? controller.onResend : null,
                child: Text(
                  'إعادة إرسال الرمز',
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: canResend ? AppColors.primary : Color(0xFFCBD5E1),
                    decoration: canResend ? TextDecoration.underline : null,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(width: 1.w, height: 14.h, color: Color(0xFFCBD5E1)),
              ),
              GestureDetector(
                onTap: controller.changeNumber,
                child: Text(
                  'تغيير الرقم',
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.enabled, this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: double.infinity,
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
          onTap: onPressed,
          child: Center(
            child: Text(
              'تحقق',
              style: enabled ? AppTextStyles.primaryButton : AppTextStyles.primaryButtonDisabled,
            ),
          ),
        ),
      ),
    );
  }
}

class _E2EFooter extends StatelessWidget {
  const _E2EFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 14.w, color: Color(0xFF94A3B8)),
        SizedBox(width: 6.w),
        Text(
          'تشفير نهاية إلى نهاية (End-to-End)',
          style: AppTextStyles.footerBody.copyWith(color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
