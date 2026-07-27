import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/auth_theme.dart';

class AuthFooterTerms extends StatelessWidget {
  const AuthFooterTerms({
    super.key,
    required this.onPrivacyTap,
    required this.onTermsTap,
  });

  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'بالمتابعة، أنت توافق على',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AuthTextStyles.footerText,
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTermsTap,
                child: Text('شروط الاستخدام', style: AuthTextStyles.footerLink),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('·', style: AuthTextStyles.footerDot),
              ),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text('سياسة الخصوصية', style: AuthTextStyles.footerLink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
