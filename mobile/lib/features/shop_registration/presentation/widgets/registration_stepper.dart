import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationStepper extends StatelessWidget {
  const RegistrationStepper({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['معلومات المتجر', 'بيانات العمل', 'التحقق'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 44.w,
                right: 44.w,
                child: SizedBox(
                  height: 4.h,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: List.generate(_labels.length - 1, (i) {
                      final isSegmentActive = currentStep > i + 1;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          color: isSegmentActive ? ShopRegColors.primary : ShopRegColors.trackInactive,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_labels.length, (i) {
                  final stepNumber = i + 1;
                  final isActive = stepNumber == currentStep;
                  final isDone = stepNumber < currentStep;
                  final highlighted = isActive || isDone;
                  return SizedBox(
                    width: 88.w,
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: highlighted ? ShopRegColors.primary : ShopRegColors.stepInactiveBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$stepNumber',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: highlighted ? Colors.white : ShopRegColors.textBody,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_labels.length, (i) {
              final stepNumber = i + 1;
              final isActive = stepNumber == currentStep;
              return SizedBox(
                width: 88.w,
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? ShopRegColors.primary : ShopRegColors.textBody,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
