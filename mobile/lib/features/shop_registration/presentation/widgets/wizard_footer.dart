import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WizardFooter extends StatelessWidget {
  const WizardFooter({
    super.key,
    required this.continueLabel,
    required this.onContinue,
    this.showBack = false,
    this.onBack,
    this.continueEnabled = true,
    this.continueIcon = ShopRegIcons.forwardArrowButton,
  });

  final String continueLabel;
  final VoidCallback onContinue;
  final bool showBack;
  final VoidCallback? onBack;
  final bool continueEnabled;
  final String continueIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ShopRegColors.inputBorderLight)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _ContinueButton(
              label: continueLabel,
              icon: continueIcon,
              enabled: continueEnabled,
              onPressed: continueEnabled ? onContinue : null,
            ),
          ),
          if (showBack) ...[
            SizedBox(width: 8.w),
            _BackButton(onPressed: onBack),
          ],
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.icon,
    required this.enabled,
    this.onPressed,
  });

  final String label;
  final String icon;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? ShopRegColors.primaryAction : ShopRegColors.primaryAction.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.primaryActionText,
                ),
              ),
              SizedBox(width: 12.w),
              FigmaIcon(icon, size: 16.w, color: ShopRegColors.primaryActionText),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.r),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(color: ShopRegColors.backButtonBorder, width: 0.8.w),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'رجوع',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.textMuted,
                ),
              ),
              SizedBox(width: 8.w),
              FigmaIcon(ShopRegIcons.backChevronSmall, size: 14.w, color: ShopRegColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
