import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/auth_theme.dart';

class AuthTrustBadges extends StatelessWidget {
  const AuthTrustBadges({super.key});

  static const _badges = [
    _TrustBadgeData(
      iconAsset: 'assets/icons/trust_shield_icon.svg',
      label: 'تسجيل آمن',
    ),
    _TrustBadgeData(
      iconAsset: 'assets/icons/trust_ai_icon.svg',
      label: 'طلب بالذكاء الاصطناعي',
    ),
    _TrustBadgeData(
      iconAsset: 'assets/icons/trust_delivery_icon.svg',
      label: 'شبكة موردين سريعة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < _badges.length; i++) {
      children.add(Expanded(child: _TrustBadge(data: _badges[i])));
      if (i != _badges.length - 1) {
        children.add(
          SizedBox(
            height: 40.h,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AuthColors.trustDivider,
            ),
          ),
        );
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _TrustBadgeData {
  const _TrustBadgeData({required this.iconAsset, required this.label});
  final String iconAsset;
  final String label;
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.data});
  final _TrustBadgeData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40.w,
          height: 40.h,
          child: Center(
            child: SvgPicture.asset(data.iconAsset, width: 24.w, height: 24.h),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          data.label,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AuthTextStyles.trustLabel,
        ),
      ],
    );
  }
}
