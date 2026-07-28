import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/auth_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/salasel_logo.png',
          width: 141.w,
          height: 94.6.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Text(
                'أهلاً بك 👋',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AuthTextStyles.heading,
              ),
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AuthTextStyles.subtitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
