import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../shop_registration/presentation/screens/register_shop_screen.dart';
import '../controllers/welcomepage_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomePageController());
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  'مرحبًا ${controller.userName.value}',
                  style: AppTextStyles.welcomeTitle.copyWith(fontSize: 24.sp),
                )),
                SizedBox(height: 4.h),
                Text(
                  'اختر متجرك للمتابعة أو قم بإنشاء متجر جديد.',
                  style: AppTextStyles.welcomeSubtitle.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Text(
                      'متاجرك المسجلة',
                      style: AppTextStyles.fieldValue.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Obx(() => Text(
                        '${controller.shops.length} متاجر',
                        style: AppTextStyles.fieldValue.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: controller.shops.map((shop) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _StoreCard(
                        title: shop.name,
                        category: shop.category,
                        location: shop.city,
                        lastActive: 'منذ التسجيل',
                        isActive: shop.isVerified,
                        icon: Icons.storefront_outlined,
                      ),
                    )).toList(),
                  );
                }),
                const _AddStoreCard(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          isSetupMode: true,
          onTap: controller.setIndex,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 80,
      leading: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Image.asset(
          'assets/images/salasel_logo.png',
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded),
          color: AppColors.textPrimary,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.menu_rounded),
          color: AppColors.textPrimary,
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBottomNav() {
    final WelcomePageController controller = Get.find();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: Offset(0, -4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'حسابي',
                  isSelected: controller.currentIndex.value == 3,
                  onTap: () => controller.setIndex(3),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'الطلبات',
                  badgeCount: 4,
                  isSelected: controller.currentIndex.value == 2,
                  onTap: () => controller.setIndex(2),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'المخزون',
                  badgeCount: 7,
                  isSelected: controller.currentIndex.value == 1,
                  onTap: () => controller.setIndex(1),
                ),
                _NavItem(
                  icon: Icons.home_outlined,
                  label: 'الرئيسية',
                  isSelected: controller.currentIndex.value == 0,
                  onTap: () => controller.setIndex(0),
                ),
              ],
            )),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.title,
    required this.category,
    required this.location,
    required this.lastActive,
    required this.isActive,
    required this.icon,
  });

  final String title;
  final String category;
  final String location;
  final String lastActive;
  final bool isActive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Color(0xFF2563EB), size: 24.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.fieldValue.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        category,
                        style: AppTextStyles.fieldValue.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'نشط',
                          style: AppTextStyles.fieldValue.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1.h, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16.w, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  location,
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacer(),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'آخر نشاط: '),
                      TextSpan(
                        text: lastActive,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
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

class _AddStoreCard extends StatelessWidget {
  const _AddStoreCard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: Color(0xFFCBD5E1)),
      child: InkWell(
        onTap: () => Get.to(
          () => RegisterShopScreen(),
          transition: Transition.cupertino,
          duration: Duration(milliseconds: 350),
        ),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 28.w, color: AppColors.textPrimary),
              ),
              SizedBox(height: 16.h),
              Text(
                'تسجيل متجر جديد',
                style: AppTextStyles.fieldValue.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ابدأ بإنشاء عمل جديد وابدأ الطلب عبر الذكاء\nالاصطناعي.',
                textAlign: TextAlign.center,
                style: AppTextStyles.fieldValue.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.5.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Color(0xFF2563EB) : Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: 32.w,
                height: 3.h,
                margin: EdgeInsets.only(bottom: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              )
            else
              SizedBox(height: 9.h),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24.w),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.h,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.fieldValue.copyWith(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(16.r),
    );
    path.addRRect(rrect);

    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    var distance = 0.0;
    
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
