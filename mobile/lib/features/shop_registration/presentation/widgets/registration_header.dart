import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/shop_registration_colors.dart';
import '../theme/shop_registration_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationHeader extends StatelessWidget implements PreferredSizeWidget {
  const RegistrationHeader({
    super.key,
    required this.title,
    this.titleWeight = FontWeight.w500,
    this.backgroundColor = Colors.white,
    this.onBack,
  });

  final String title;
  final FontWeight titleWeight;
  final Color backgroundColor;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: FigmaIcon(ShopRegIcons.help, color: ShopRegColors.primary, size: 20.w),
              ),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: titleWeight,
                      color: ShopRegColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: FigmaIcon(ShopRegIcons.headerChevron, color: ShopRegColors.primary, size: 16.w),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
