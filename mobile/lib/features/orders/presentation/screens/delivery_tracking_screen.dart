import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_pressable.dart';
import '../theme/order_colors.dart';
import 'receipt_success_screen.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderId;

  const DeliveryTrackingScreen({
    super.key,
    this.orderId = 'SL-94821',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              _buildStatusHeader(),
              SizedBox(height: 24.h),
              _buildMapCard(),
              SizedBox(height: 32.h),
              _buildTimelineSection(),
              SizedBox(height: 32.h),
              _buildSuppliersSection(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9FAFC),
      elevation: 0,
      centerTitle: true,
      leading: AnimatedPressable(
        borderRadius: BorderRadius.circular(999.r),
        onTap: () => Get.back(),
        child: Icon(Icons.arrow_forward_rounded, color: OrderColors.textDark, size: 24.w),
      ),
      title: Column(
        children: [
          Text(
            'تتبع الطلب',
            style: TextStyle(color: OrderColors.textDark, fontSize: 18.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          Text(
            '#$orderId',
            style: TextStyle(color: OrderColors.textMuted, fontSize: 12.sp, fontFamily: 'Cairo'),
          ),
        ],
      ),
      actions: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(999.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(Icons.help_outline_rounded, color: OrderColors.textDark, size: 24.w),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: OrderColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.local_shipping, color: OrderColors.primary, size: 32.w),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'جاري التوصيل',
          style: TextStyle(color: OrderColors.textTitle, fontSize: 20.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'الوقت المقدر للوصول: ',
              style: TextStyle(color: OrderColors.textMuted, fontSize: 14.sp, fontFamily: 'Cairo'),
            ),
            Text(
              '14:30',
              style: TextStyle(color: OrderColors.primary, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 220.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Map Image Background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  'assets/images/map_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE2E8F0),
                    child: Center(child: Icon(Icons.map, size: 48, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            // Driver Pill Overlay
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: const BoxDecoration(
                        color: OrderColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'ع',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'عصام محمد',
                            style: TextStyle(color: OrderColors.textTitle, fontSize: 14.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                          ),
                          Text(
                            'Nissan Van • دقائق 10',
                            style: TextStyle(color: OrderColors.textMuted, fontSize: 12.sp, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: const BoxDecoration(
                        color: OrderColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.phone, color: OrderColors.primary, size: 18.w),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: const BoxDecoration(
                        color: OrderColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chat_bubble, color: Colors.white, size: 16.w),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 16.h),
          _buildTimelineStep(
            label: 'تم تأكيد الطلب',
            time: '09:15 ص',
            status: _StepStatus.completed,
            isFirst: true,
          ),
          _buildTimelineStep(
            label: 'تم التجهيز والتغليف',
            time: '11:30 ص',
            status: _StepStatus.completed,
          ),
          _buildTimelineStep(
            label: 'جاري التوصيل',
            time: 'الآن',
            status: _StepStatus.active,
          ),
          _buildTimelineStep(
            label: 'تم التسليم',
            time: '',
            status: _StepStatus.pending,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String label,
    required String time,
    required _StepStatus status,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color labelColor;
    Color timeColor = OrderColors.textMuted;
    
    switch (status) {
      case _StepStatus.completed:
        labelColor = OrderColors.textTitle;
        break;
      case _StepStatus.active:
        labelColor = OrderColors.primary;
        break;
      case _StepStatus.pending:
        labelColor = OrderColors.textFaint;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32.w,
            child: Column(
              children: [
                // Top line
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: isFirst ? Colors.transparent : (status == _StepStatus.pending ? const Color(0xFFE2E8F0) : OrderColors.primary),
                  ),
                ),
                // Icon
                _buildTimelineIcon(status),
                // Bottom line
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: isLast ? Colors.transparent : (status == _StepStatus.pending || status == _StepStatus.active ? const Color(0xFFE2E8F0) : OrderColors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        color: timeColor,
                        fontSize: 12.sp,
                        fontFamily: 'Cairo',
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

  Widget _buildTimelineIcon(_StepStatus status) {
    if (status == _StepStatus.completed) {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: const BoxDecoration(color: OrderColors.primary, shape: BoxShape.circle),
        child: Icon(Icons.check, color: Colors.white, size: 14.w),
      );
    } else if (status == _StepStatus.active) {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: OrderColors.primary, width: 2.w),
        ),
        child: Center(
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(color: OrderColors.primary, shape: BoxShape.circle),
          ),
        ),
      );
    } else {
      return Container(
        width: 16.w,
        height: 16.w,
        decoration: const BoxDecoration(
          color: Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildSuppliersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الموردين',
            style: TextStyle(color: OrderColors.textTitle, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 16.h),
          _buildSupplierCard(
            storeName: 'أغذية النيل',
            isActive: true,
            statusLabel: 'جاري التوصيل',
            driverName: 'عصام محمد',
            timeRemaining: '15 دقائق',
            hasTrackAction: true,
          ),
          SizedBox(height: 12.h),
          _buildSupplierCard(
            storeName: 'دلتا للتجارة',
            isActive: false,
            statusLabel: 'قيد التجهيز',
            timeRemaining: '45 دقيقة', 
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard({
    required String storeName,
    required bool isActive,
    required String statusLabel,
    String? driverName,
    required String timeRemaining,
    bool hasTrackAction = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrderColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.storefront_outlined, color: isActive ? OrderColors.primary : OrderColors.textMuted, size: 24.w),
                  SizedBox(width: 8.w),
                  Text(
                    storeName,
                    style: TextStyle(color: OrderColors.textTitle, fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? OrderColors.primarySoft : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: isActive ? OrderColors.primary : OrderColors.textMuted,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: OrderColors.divider, height: 1.h),
          SizedBox(height: 12.h),
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (driverName != null)
                      Text(
                        'المندوب: $driverName',
                        style: TextStyle(color: OrderColors.textMuted, fontSize: 12.sp, fontFamily: 'Cairo'),
                      ),
                    if (driverName != null) SizedBox(height: 4.h),
                    Text(
                      driverName != null ? 'الوقت المتبقي: $timeRemaining' : 'الوقت المقدر للوصول: $timeRemaining',
                      style: TextStyle(color: OrderColors.textMuted, fontSize: 12.sp, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
              if (hasTrackAction)
                Row(
                  children: [
                    Text(
                      'تتبع',
                      style: TextStyle(color: OrderColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_back, color: OrderColors.primary, size: 14.w),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buttons Section
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, -4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedPressable(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  Get.off(
                    () => ReceiptSuccessScreen(orderId: orderId),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 400),
                  );
                },
                child: Container(
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OrderColors.primaryDark,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تأكيد الاستلام',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.verified, color: Colors.white, size: 20.w), 
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              AnimatedPressable(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {},
                child: Container(
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: OrderColors.danger, width: 1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'بلغ عن مشكلة',
                    style: TextStyle(color: OrderColors.danger, fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar
        Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: OrderColors.cardBorder, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.person_outline, label: 'حسابي', isActive: true),
              _buildNavItem(icon: Icons.receipt_long_outlined, label: 'الطلبات', badge: '4'),
              _buildNavItem(icon: Icons.inventory_2_outlined, label: 'المخزون', badge: '7'),
              _buildNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false, String? badge}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: isActive ? OrderColors.primary : OrderColors.textMuted, size: 24.w),
              if (badge != null)
                Positioned(
                  top: -4.h,
                  right: -4.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive ? OrderColors.primary : OrderColors.textMuted,
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
          if (isActive)
             Container(
               margin: EdgeInsets.only(top: 4.h),
               width: 24.w,
               height: 2.h,
               decoration: BoxDecoration(
                 color: OrderColors.primary,
                 borderRadius: BorderRadius.circular(2.r),
               ),
             ),
        ],
      ),
    );
  }
}

enum _StepStatus { completed, active, pending }
