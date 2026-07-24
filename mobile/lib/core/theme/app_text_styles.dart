import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {

  static TextStyle _baseFont({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final isAr = Get.locale?.languageCode != 'en';
    if (isAr) {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }
  }

  static TextStyle get welcomeTitle => _baseFont(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get welcomeSubtitle => _baseFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get fieldLabel => _baseFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get fieldHint => _baseFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  static TextStyle get fieldValue => _baseFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get primaryButton => _baseFont(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.3,
      );

  static TextStyle get primaryButtonDisabled => _baseFont(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.disabledText,
        height: 1.3,
      );

  static TextStyle get whatsappButton => _baseFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.whatsapp,
        height: 1.3,
      );

  static TextStyle get dividerLabel => _baseFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get featureLabel => _baseFont(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get footerBody => _baseFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get footerLink => _baseFont(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.link,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.link,
      );

  static TextStyle get dialCode => _baseFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
