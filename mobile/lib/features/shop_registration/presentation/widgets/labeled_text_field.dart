import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixText,
    this.showInfoIcon = false,
  });

  final String label;
  final String hint;
  final String? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final String? prefixText;
  final bool showInfoIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: ShopRegColors.textBody,
              ),
            ),
            if (showInfoIcon) ...[
              SizedBox(width: 6.w),
              FigmaIcon(ShopRegIcons.help, size: 16.w, color: ShopRegColors.textBody.withValues(alpha: 0.4)),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          keyboardType: keyboardType,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            color: enabled ? ShopRegColors.textDark : ShopRegColors.iconMuted.withValues(alpha: 0.5),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: enabled ? ShopRegColors.textHint : ShopRegColors.iconMuted.withValues(alpha: 0.5),
            ),
            prefixIcon: (icon != null || prefixText != null)
                ? Padding(
                    padding: EdgeInsets.only(right: 4.w, left: 4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) FigmaIcon(icon!, size: 20.w, color: ShopRegColors.iconMuted),
                        if (prefixText != null) ...[
                          SizedBox(width: 8.w),
                          Text(
                            prefixText!,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: ShopRegColors.textBody,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
            filled: true,
            fillColor: ShopRegColors.inputFill,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ShopRegColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ShopRegColors.inputBorder),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ShopRegColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ShopRegColors.primaryAction, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}
