import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/auth_theme.dart';

class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AuthTextStyles.fieldLabel,
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AuthColors.fieldBackground,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AuthColors.fieldBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AuthTextStyles.fieldValue,
            cursorColor: AuthColors.primary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AuthTextStyles.fieldValue,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
