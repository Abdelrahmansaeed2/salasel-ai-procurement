import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AuthColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color heading = Color(0xFF0F172B);
  static const Color subtitle = Color(0xFF62748E);
  static const Color fieldLabel = Color(0xFF45556C);
  static const Color fieldBorder = Color(0x80E2E8F0);
  static const Color fieldBackground = Color(0x80F8FAFC);
  static const Color fieldValue = Color(0x800F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color disabledButton = Color(0xFFCBD5E1);
  static const Color trustLabel = Color(0xFF62748E);
  static const Color trustDivider = Color(0xFFF1F5F9);
  static const Color footerText = Color(0xFF90A1B9);
  static const Color footerDot = Color(0xFFCAD5E2);
  static const Color errorText = Color(0xFFBA1A1A);
}

abstract final class AuthTextStyles {
  static TextStyle get heading => GoogleFonts.cairo(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: AuthColors.heading,
        height: (32.5 / 26).h,
      );

  static TextStyle get subtitle => GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AuthColors.subtitle,
        height: (22.75 / 14).h,
      );

  static TextStyle get fieldLabel => GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AuthColors.fieldLabel,
        height: (19.5 / 13).h,
      );

  static TextStyle get fieldValue => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AuthColors.fieldValue,
      );

  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get switchPrompt => GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AuthColors.subtitle,
      );

  static TextStyle get switchLink => GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AuthColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AuthColors.primary,
      );

  static TextStyle get trustLabel => GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AuthColors.trustLabel,
        height: (15.125 / 11).h,
      );

  static TextStyle get footerText => GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AuthColors.footerText,
        height: (16.5 / 11).h,
      );

  static TextStyle get footerLink => GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AuthColors.primary,
        height: (16.5 / 11).h,
        decoration: TextDecoration.underline,
        decorationColor: AuthColors.primary,
      );

  static TextStyle get footerDot => GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AuthColors.footerDot,
        height: (16.5 / 11).h,
      );

  static TextStyle get errorText => GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AuthColors.errorText,
      );
}
