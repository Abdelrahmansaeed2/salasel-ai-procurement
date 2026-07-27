import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            alignment: Alignment.center,
            child: FigmaIcon(ShopRegIcons.sparkle, color: ShopRegColors.primary, size: 22.w),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نصيحة سلاسل الذكية',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: ShopRegColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    height: 1.6.h,
                    color: ShopRegColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
