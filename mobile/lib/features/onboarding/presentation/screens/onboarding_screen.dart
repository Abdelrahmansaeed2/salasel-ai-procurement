import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../controllers/onboarding_controller.dart';

const String _kLogoUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/c0e3b351321fdab13103f562fe29b6cd429c3f43?width=140';
const String _kMicIllustrationUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/af82df7308648091fda184e7258d243ce2401bf1?width=568';
const String _kAiIllustrationUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/1a111da79d38ce87bad02bf48cc053b95e170b05?width=684';

const String _kCloseIconSvg =
    '<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1.33 13.3L0 11.97L5.32 6.65L0 1.33L1.33 0L6.65 5.32L11.97 0L13.3 1.33L7.98 6.65L13.3 11.97L11.97 13.3L6.65 7.98L1.33 13.3Z" fill="#004AC6"/></svg>';

const Color _kSubtitle = Color(0xFF505F76);
const Color _kInactiveDot = Color(0x4DC3C6D7);
const Color _kActiveDot = Color(0xFF004AC6);
const Color _kPrimaryBlue = Color(0xFF2563EB);

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _OnboardingTopBar(controller: controller),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _VoiceOrderingPage(controller: controller),
                  _AiIntelligencePage(controller: controller),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            if (index != 0) Get.snackbar('قريباً', 'هذه الميزة قيد التطوير حالياً');
          },
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  final OnboardingController controller;
  const _OnboardingTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64.h + topInset,
          padding: EdgeInsets.only(top: topInset, left: 20.w, right: 20.w),
          color: Colors.white.withValues(alpha: 0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedPressable(
                onTap: controller.skip,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Skip',
                    style: TextStyle(color: const Color(0xFF434655), fontFamily: 'Inter', fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.43.h),
                  ),
                ),
              ),
              CachedNetworkImage(imageUrl: _kLogoUrl, width: 70.w, height: 47.h),
              AnimatedPressable(
                onTap: controller.skip,
                borderRadius: BorderRadius.circular(9999.r),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.string(_kCloseIconSvg, width: 14.w, height: 14.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int index;
  const _ProgressDots({required this.index});

  @override
  Widget build(BuildContext context) {
    // Figma's dots progress right-to-left (matching Arabic reading
    // direction): page 0 lights up the rightmost dot, the last page lights
    // up the leftmost one. Since this Row renders left-to-right, mirror the
    // active index.
    final activeDotIndex = OnboardingController.totalPages - 1 - index;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(OnboardingController.totalPages, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: i == activeDotIndex ? _kActiveDot : _kInactiveDot, shape: BoxShape.circle),
        );
      }),
    );
  }
}

class _VoiceOrderingPage extends StatelessWidget {
  final OnboardingController controller;
  const _VoiceOrderingPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 51.h, 24.w, 24.h),
      child: Column(
        children: [
          AnimatedEntrance(
            child: SizedBox(
              width: double.infinity,
              height: 379.h,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  CachedNetworkImage(imageUrl: _kMicIllustrationUrl, width: 284.w, height: 379.h, fit: BoxFit.contain),
                  Positioned(
                    bottom: 10.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 297.5.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: const Color(0xFF14B8A6)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 25, offset: const Offset(0, 20))],
                              ),
                              child: Text(
                                '"محتاج ٢٠ كرتونة لبن، ١٠ أكياس سكر و ٥ كراتين شاي"',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: const Color(0xFF434655), fontFamily: 'Cairo', fontSize: 16.sp, height: 1.63.h),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25.h),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 80),
            child: Column(
              children: [
                Text(
                  'اطلب باستخدام صوتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF191B23), fontFamily: 'Cairo', fontSize: 18.sp, fontWeight: FontWeight.w800, height: 1.33.h, letterSpacing: -0.4),
                ),
                SizedBox(height: 8.h),
                Text(
                  'بساطة اضغط على الميكروفون وأخبر "أمية" بما\nيحتاجه متجرك. تحدث بشكل طبيعي بالعامية\nالمصرية وسيفهم ذكاؤنا الاصطناعي طلبك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kSubtitle, fontFamily: 'Cairo', fontSize: 16.sp, height: 1.5.h),
                ),
              ],
            ),
          ),
          SizedBox(height: 33.h),
          _ProgressDots(index: 0),
          SizedBox(height: 34.h),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 160),
            child: Column(
              children: [
                AnimatedPressable(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: controller.next,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _kPrimaryBlue, borderRadius: BorderRadius.circular(8.r)),
                    child: Text('التالي', style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.5.h)),
                  ),
                ),
                SizedBox(height: 16.h),
                AnimatedPressable(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: controller.skip,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    alignment: Alignment.center,
                    child: Text('تخطي', style: TextStyle(color: _kSubtitle, fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.5.h)),
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

class _AiIntelligencePage extends StatelessWidget {
  final OnboardingController controller;
  const _AiIntelligencePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 24.h),
      child: Column(
        children: [
          AnimatedEntrance(
            child: CachedNetworkImage(
              imageUrl: _kAiIllustrationUrl,
              width: double.infinity,
              height: 297.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 50.h),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 80),
            child: Column(
              children: [
                Text(
                  'الذكاء الاصطناعي يقوم بالعمل\nالشاق',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF191C1E), fontFamily: 'Cairo', fontSize: 18.sp, fontWeight: FontWeight.w800, height: 1.67.h),
                ),
                SizedBox(height: 8.h),
                Text(
                  'يفهم ذكاؤنا الاصطناعي طلبك، ويحدد المنتجات، ويختار أفضل الموردين، ويجهز طلبك تلقائياً. أنت فقط تراجع وتؤكد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kSubtitle, fontFamily: 'Cairo', fontSize: 16.sp, height: 1.5.h),
                ),
              ],
            ),
          ),
          SizedBox(height: 33.h),
          _ProgressDots(index: 1),
          SizedBox(height: 34.h),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 160),
            child: Column(
              children: [
                AnimatedPressable(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: controller.finish,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _kPrimaryBlue, borderRadius: BorderRadius.circular(8.r)),
                    child: Text('ابدأ الآن', style: TextStyle(color: const Color(0xFFEEEFFF), fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.5.h)),
                  ),
                ),
                SizedBox(height: 16.h),
                AnimatedPressable(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: controller.back,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    alignment: Alignment.center,
                    child: Text('رجوع', style: TextStyle(color: _kSubtitle, fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.5.h)),
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
