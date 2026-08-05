import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../theme/order_colors.dart';

class _Icons {
  static const backArrow =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M12.175 9H0V7H12.175L6.575 1.4L8 0L16 8L8 16L6.575 14.6L12.175 9Z" fill="#333333"/></svg>';
}

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderId;

  const DeliveryTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMapPlaceholder(),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          _buildDriverCard(),
                          SizedBox(height: 24.h),
                          _buildTimeline(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xCCFAF8FF),
        boxShadow: [
          const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            const Spacer(),
            Text(
              'تتبع الطلب',
              style: TextStyle(
                color: OrderColors.textDark,
                fontFamily: 'Cairo',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                height: 1.25.h,
              ),
            ),
            SizedBox(width: 12.w),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999.r),
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: const Icon(Icons.arrow_forward_ios, size: 20, color: OrderColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 250.h,
      width: double.infinity,
      color: OrderColors.transcriptBg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.map, size: 64.w, color: OrderColors.sectionLabel),
          Positioned(
            bottom: 16.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: const Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: OrderColors.primary, size: 16.w),
                  SizedBox(width: 8.w),
                  Text(
                    'يصل خلال ١٥ دقيقة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: OrderColors.textTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: OrderColors.cardBorder),
        boxShadow: [
          const BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: OrderColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: OrderColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أحمد السائق',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: OrderColors.textTitle,
                  ),
                ),
                Text(
                  'شاحنة مبردة - ب د ع 4321',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: OrderColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(999.r),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: OrderColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone, color: OrderColors.primary, size: 20.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: OrderColors.cardBorder),
        boxShadow: [
          const BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: OrderColors.textTitle,
            ),
          ),
          SizedBox(height: 16.h),
          _buildTimelineStep(label: 'تم استلام الطلب', time: '10:00 ص', isCompleted: true, isLast: false),
          _buildTimelineStep(label: 'تم التجهيز في المستودع', time: '11:30 ص', isCompleted: true, isLast: false),
          _buildTimelineStep(label: 'خرج للتوصيل', time: '12:15 م', isCompleted: true, isLast: false, isActive: true),
          _buildTimelineStep(label: 'تم التسليم', time: '--:--', isCompleted: false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String label,
    required String time,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: isCompleted ? OrderColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? OrderColors.primary : OrderColors.cardBorder,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 12.w, color: Colors.white)
                  : (isActive ? Center(child: Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: OrderColors.primary, shape: BoxShape.circle))) : null),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 32.h,
                color: isCompleted ? OrderColors.primary : OrderColors.divider,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? OrderColors.primary : (isCompleted ? OrderColors.textTitle : OrderColors.textFaint),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: OrderColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Get.snackbar(
            'تم تأكيد الاستلام',
            'شكراً لتعاملك معنا. تمت إضافة النقاط لحسابك.',
            backgroundColor: OrderColors.successBg,
            colorText: OrderColors.success,
            margin: EdgeInsets.all(16.w),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAll(() => const HomeScreen());
          });
        },
        child: Container(
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrderColors.success,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'تأكيد استلام الطلب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}
