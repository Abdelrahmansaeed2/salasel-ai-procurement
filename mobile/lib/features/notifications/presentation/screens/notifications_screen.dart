import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../orders/presentation/screens/delivery_tracking_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../voice_order/presentation/screens/voice_recording_screen.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NotificationsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilterChips(c),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionHeader(label: 'اليوم'),
                            SizedBox(height: 16.h),
                            _VoiceFeatureCard(
                              onStartTap: () => Get.to(() => const VoiceRecordingScreen()),
                            ),
                            SizedBox(height: 16.h),
                            _NotificationCard(
                              iconBg: const Color(0x33BC4800),
                              iconColor: const Color(0xFFBC4800),
                              iconPath:
                                  'M2 20C1.45 20 0.979167 19.8042 0.5875 19.4125C0.195833 19.0208 0 18.55 0 18V6C0 5.45 0.195833 4.97917 0.5875 4.5875C0.979167 4.19583 1.45 4 2 4H4C4 2.9 4.39167 1.95833 5.175 1.175C5.95833 0.391667 6.9 0 8 0C9.1 0 10.0417 0.391667 10.825 1.175C11.6083 1.95833 12 2.9 12 4H14C14.55 4 15.0208 4.19583 15.4125 4.5875C15.8042 4.97917 16 5.45 16 6V18C16 18.55 15.8042 19.0208 15.4125 19.4125C15.0208 19.8042 14.55 20 14 20H2ZM6 4H10C10 3.45 9.80417 2.97917 9.4125 2.5875C9.02083 2.19583 8.55 2 8 2C7.45 2 6.97917 2.19583 6.5875 2.5875C6.19583 2.97917 6 3.45 6 4ZM11 9C11.2833 9 11.5208 8.90417 11.7125 8.7125C11.9042 8.52083 12 8.28333 12 8V6H10V8C10 8.28333 10.0958 8.52083 10.2875 8.7125C10.4792 8.90417 10.7167 9 11 9ZM5 9C5.28333 9 5.52083 8.90417 5.7125 8.7125C5.90417 8.52083 6 8.28333 6 8V6H4V8C4 8.28333 4.09583 8.52083 4.2875 8.7125C4.47917 8.90417 4.71667 9 5 9Z',
                              iconWidth: 16,
                              iconHeight: 20,
                              title: 'تم قبول طلبك رقم #8842',
                              description:
                                  "المورد 'النيل للأغذية' قبل طلبك. جاري التحضير.",
                              buttonLabel: 'تتبع الطلب',
                              radius: 8,
                              onButtonTap: () => Get.to(
                                () => const DeliveryTrackingScreen(orderId: '#8842'),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            _SectionHeader(label: 'أمس'),
                            SizedBox(height: 16.h),
                            _NotificationCard(
                              iconBg: const Color(0xFFFFDAD6),
                              iconColor: const Color(0xFFBA1A1A),
                              iconPath:
                                  'M3 20C2.45 20 1.97917 19.8042 1.5875 19.4125C1.19583 19.0208 1 18.55 1 18V6.725C0.7 6.54167 0.458333 6.30417 0.275 6.0125C0.0916667 5.72083 0 5.38333 0 5V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V5C20 5.38333 19.9083 5.72083 19.725 6.0125C19.5417 6.30417 19.3 6.54167 19 6.725V18C19 18.55 18.8042 19.0208 18.4125 19.4125C18.0208 19.8042 17.55 20 17 20H3ZM2 5H18V2H2V5ZM7 12H13V10H7V12Z',
                              iconWidth: 20,
                              iconHeight: 20,
                              title: 'تنبيه: مخزون منخفض',
                              description:
                                  'حليب المراعي (1 لتر) وصل إلى الحد الأدنى (5 كراتين).',
                              buttonLabel: 'إعادة طلب',
                              radius: 8,
                              onButtonTap: () => Get.to(() => const InventoryScreen()),
                            ),
                            SizedBox(height: 16.h),
                            _NotificationCard(
                              iconBg: const Color(0xFFDBE1FF),
                              iconColor: const Color(0xFF004AC6),
                              iconPath:
                                  'M5 16C4.16667 16 3.45833 15.7083 2.875 15.125C2.29167 14.5417 2 13.8333 2 13H0V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H16V4H19L22 8V13H20C20 13.8333 19.7083 14.5417 19.125 15.125C18.5417 15.7083 17.8333 16 17 16C16.1667 16 15.4583 15.7083 14.875 15.125C14.2917 14.5417 14 13.8333 14 13H8C8 13.8333 7.70833 14.5417 7.125 15.125C6.54167 15.7083 5.83333 16 5 16ZM5 14C5.28333 14 5.52083 13.9042 5.7125 13.7125C5.90417 13.5208 6 13.2833 6 13C6 12.7167 5.90417 12.4792 5.7125 12.2875C5.52083 12.0958 5.28333 12 5 12C4.71667 12 4.47917 12.0958 4.2875 12.2875C4.09583 12.4792 4 12.7167 4 13C4 13.2833 4.09583 13.5208 4.2875 13.7125C4.47917 13.9042 4.71667 14 5 14ZM17 14C17.2833 14 17.5208 13.9042 17.7125 13.7125C17.9042 13.5208 18 13.2833 18 13C18 12.7167 17.9042 12.4792 17.7125 12.2875C17.5208 12.0958 17.2833 12 17 12C16.7167 12 16.4792 12.0958 16.2875 12.2875C16.0958 12.4792 16 12.7167 16 13C16 13.2833 16.0958 13.5208 16.2875 13.7125C16.4792 13.9042 16.7167 14 17 14ZM16 9H20.25L18 6H16V9Z',
                              iconWidth: 22,
                              iconHeight: 16,
                              title: 'الشحنة في الطريق',
                              description:
                                  'المندوب يقترب من موقعك، سيصل خلال 15 دقيقة.',
                              buttonLabel: 'عرض الخريطة',
                              radius: 8,
                              onButtonTap: () => Get.to(
                                () => const DeliveryTrackingScreen(orderId: '#8842'),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            _SectionHeader(label: 'هذا الأسبوع'),
                            SizedBox(height: 16.h),
                            _NotificationCard(
                              iconBg: const Color(0xFFE8F5E9),
                              iconColor: const Color(0xFF2E7D32),
                              iconPath:
                                  'M7.6 21L5.7 17.8L2.1 17L2.45 13.3L0 10.5L2.45 7.7L2.1 4L5.7 3.2L7.6 0L11 1.45L14.4 0L16.3 3.2L19.9 4L19.55 7.7L22 10.5L19.55 13.3L19.9 17L16.3 17.8L14.4 21L11 19.55L7.6 21ZM9.95 14.05L15.6 8.4L14.2 6.95L9.95 11.2L7.8 9.1L6.4 10.5L9.95 14.05Z',
                              iconWidth: 22,
                              iconHeight: 21,
                              title: 'تم توثيق المنشأة بنجاح',
                              description:
                                  'يمكنك الآن الوصول إلى كافة ميزات المنصة.',
                              buttonLabel: 'الملف الشخصي',
                              radius: 20,
                              onButtonTap: () => Get.to(() => const ProfileScreen()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNavBar(
            currentIndex: c.bottomNavIndex.value,
            onTap: c.changeTab,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              _HeaderIconButton(
                width: 22,
                height: 13,
                path:
                    'M5.65 12.025L0 6.375L1.425 4.975L5.675 9.225L7.075 10.625L5.65 12.025ZM11.3 12.025L5.65 6.375L7.05 4.95L11.3 9.2L20.5 0L21.9 1.425L11.3 12.025ZM11.3 6.375L9.875 4.975L14.825 0.025L16.25 1.425L11.3 6.375Z',
                onTap: () {},
              ),
              SizedBox(width: 8.w),
              _HeaderIconButton(
                width: 18,
                height: 18,
                path:
                    'M8 18V12H10V14H18V16H10V18H8ZM0 16V14H6V16H0ZM4 12V10H0V8H4V6H6V12H4ZM8 10V8H18V10H8ZM12 6V0H14V2H18V4H14V6H12ZM0 4V2H10V4H0Z',
                onTap: () {},
              ),
            ],
          ),
          const Spacer(),
          Text(
            'الإشعارات',
            style: TextStyle(
              color: const Color(0xFF191B23),
              fontFamily: 'Cairo',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 24,
            ),
          ),
          SizedBox(width: 8.w),
          _HeaderIconButton(
            width: 16,
            height: 16,
            path:
                'M12.175 9H0V7H12.175L6.575 1.4L8 0L16 8L8 16L6.575 14.6L12.175 9Z',
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(NotificationsController c) {
    return SizedBox(
      height: 36.h,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: c.filters.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final f = c.filters[i];
            final selected = c.selectedFilter.value == f;
            return GestureDetector(
              onTap: () => c.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF004AC6)
                      : const Color(0xFFECEEF0),
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF434655),
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final double width;
  final double height;
  final String path;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.width,
    required this.height,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 14.h),
        child: SvgPicture.string(
          '<svg width="$width" height="$height" viewBox="0 0 $width $height" fill="none" xmlns="http://www.w3.org/2000/svg">'
          '<path d="$path" fill="#434655"/></svg>',
          width: width.w,
          height: height.h,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: const Color(0xFF505F76),
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
        ),
      ),
    );
  }
}

class _VoiceFeatureCard extends StatelessWidget {
  final VoidCallback onStartTap;

  const _VoiceFeatureCard({required this.onStartTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD0E1FB),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.string(
                  '<svg width="22" height="19" viewBox="0 0 22 19" fill="none" xmlns="http://www.w3.org/2000/svg">'
                  '<path d="M3 13C2.16667 13 1.45833 12.7083 0.875 12.125C0.291667 11.5417 0 10.8333 0 10C0 9.16667 0.291667 8.45833 0.875 7.875C1.45833 7.29167 2.16667 7 3 7V5C3 4.45 3.19583 3.97917 3.5875 3.5875C3.97917 3.19583 4.45 3 5 3H8C8 2.16667 8.29167 1.45833 8.875 0.875C9.45833 0.291667 10.1667 0 11 0C11.8333 0 12.5417 0.291667 13.125 0.875C13.7083 1.45833 14 2.16667 14 3H17C17.55 3 18.0208 3.19583 18.4125 3.5875C18.8042 3.97917 19 4.45 19 5V7C19.8333 7 20.5417 7.29167 21.125 7.875C21.7083 8.45833 22 9.16667 22 10C22 10.8333 21.7083 11.5417 21.125 12.125C20.5417 12.7083 19.8333 13 19 13V17C19 17.55 18.8042 18.0208 18.4125 18.4125C18.0208 18.8042 17.55 19 17 19H5C4.45 19 3.97917 18.8042 3.5875 18.4125C3.19583 18.0208 3 17.55 3 17V13ZM8 11C8.41667 11 8.77083 10.8542 9.0625 10.5625C9.35417 10.2708 9.5 9.91667 9.5 9.5C9.5 9.08333 9.35417 8.72917 9.0625 8.4375C8.77083 8.14583 8.41667 8 8 8C7.58333 8 7.22917 8.14583 6.9375 8.4375C6.64583 8.72917 6.5 9.08333 6.5 9.5C6.5 9.91667 6.64583 10.2708 6.9375 10.5625C7.22917 10.8542 7.58333 11 8 11ZM14 11C14.4167 11 14.7708 10.8542 15.0625 10.5625C15.3542 10.2708 15.5 9.91667 15.5 9.5C15.5 9.08333 15.3542 8.72917 15.0625 8.4375C14.7708 8.14583 14.4167 8 14 8C13.5833 8 13.2292 8.14583 12.9375 8.4375C12.6458 8.72917 12.5 9.08333 12.5 9.5C12.5 9.91667 12.6458 10.2708 12.9375 10.5625C13.2292 10.8542 13.5833 11 14 11ZM7 15H15V13H7V15Z" fill="#004AC6"/></svg>',
                  width: 22.w,
                  height: 19.h,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'تم فتح ميزة الطلب الصوتي',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF191C1E),
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'تم التحقق من سجلك التجاري، يمكنك الآن البدء بالطلب الصوتي.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF434655),
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 22.75 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: onStartTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'ابدأ الآن',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final String iconPath;
  final double iconWidth;
  final double iconHeight;
  final String title;
  final String description;
  final String buttonLabel;
  final double radius;
  final VoidCallback? onButtonTap;

  const _NotificationCard({
    required this.iconBg,
    required this.iconColor,
    required this.iconPath,
    required this.iconWidth,
    required this.iconHeight,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.radius,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: SvgPicture.string(
                  '<svg width="$iconWidth" height="$iconHeight" viewBox="0 0 $iconWidth $iconHeight" fill="none" xmlns="http://www.w3.org/2000/svg">'
                  '<path d="$iconPath" fill="${_hex(iconColor)}"/></svg>',
                  width: iconWidth.w,
                  height: iconHeight.h,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF191C1E),
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      description,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF434655),
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 22.75 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: OutlinedButton(
              onPressed: onButtonTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F4F6),
                side: const BorderSide(color: Color(0xFFDBE1FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: const Color(0xFF004AC6),
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
