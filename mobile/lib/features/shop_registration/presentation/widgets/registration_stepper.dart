import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';

class RegistrationStepper extends StatelessWidget {
  const RegistrationStepper({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['معلومات المتجر', 'بيانات العمل', 'التحقق'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 44,
                right: 44,
                child: SizedBox(
                  height: 4,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: List.generate(_labels.length - 1, (i) {
                      final isSegmentActive = currentStep > i + 1;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
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
                    width: 88,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: highlighted ? ShopRegColors.primary : ShopRegColors.stepInactiveBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$stepNumber',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
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
          const SizedBox(height: 8),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_labels.length, (i) {
              final stepNumber = i + 1;
              final isActive = stepNumber == currentStep;
              return SizedBox(
                width: 88,
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
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
