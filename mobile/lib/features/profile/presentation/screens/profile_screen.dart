import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/controllers/settings_controller.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../controllers/profile_controller.dart';

const _kTextPrimary = Color(0xFF191C1E);
const _kTextSecondary = Color(0xFF54647A);
const _kIconGray = Color(0xFF434655);
const _kIconBlue = Color(0xFF004AC6);
const _kAccentBlue = Color(0xFF2563EB);
const _kBorder = Color(0xFFC3C6D7);
const _kSurfaceGray = Color(0xFFECEEF0);
const _kSuccess = Color(0xFF10B981);
const _kWarningBorder = Color(0xFFF59E0B);
const _kWarningBg = Color(0xFFFEF3C7);
const _kWarningIcon = Color(0xFFD97706);
const _kDangerText = Color(0xFFBA1A1A);

Widget _pathIcon(
  String path, {
  required double vbW,
  required double vbH,
  required double w,
  required double h,
  required Color color,
}) {
  return SvgPicture.string(
    '<svg width="$vbW" height="$vbH" viewBox="0 0 $vbW $vbH" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="$path" fill="#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}"/></svg>',
    width: w,
    height: h,
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(ProfileController());
  }

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: c.storeName.value);
    final phoneController = TextEditingController(text: c.phoneNumber.value);
    final addressController = TextEditingController(text: c.storeAddress.value);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تعديل معلومات المنشأة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المتجر', border: OutlineInputBorder()),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            SizedBox(height: 16.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم التواصل', border: OutlineInputBorder()),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            SizedBox(height: 16.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _kAccentBlue),
                onPressed: () async {
                  Get.back();
                  final success = await c.updateProfile(
                    newShopName: nameController.text,
                    newPhone: phoneController.text,
                    newAddress: addressController.text,
                  );
                  if (success) {
                    Get.snackbar('نجاح', 'تم تحديث البيانات بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
                  } else {
                    Get.snackbar('خطأ', 'حدث خطأ أثناء التحديث', backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                child: Text('حفظ التعديلات', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: _buildHeader(),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 20.h),
            _ProfileSummary(),
            SizedBox(height: 24.h),
            _VoiceOrderStatusCard(),
            SizedBox(height: 24.h),
            _VerificationTimeline(steps: c.verificationSteps),
            SizedBox(height: 24.h),
            _BusinessInfoSection(onEdit: _showEditProfileModal),
            SizedBox(height: 24.h),
            _ContactSection(),
            SizedBox(height: 24.h),
            _AppSettingsSection(),
            SizedBox(height: 24.h),
            _HelpSupportSection(),
            SizedBox(height: 24.h),
            _DangerZone(),
            SizedBox(height: 34.h),
          ],
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

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      toolbarHeight: 64.h,
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leadingWidth: 40.w,
      leading: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: 40.w,
            height: 40.h,
            child: Center(
              child: _pathIcon(
                'M1.775 20L0 18.225L8.225 10L0 1.775L1.775 0L11.775 10L1.775 20Z',
                vbW: 12,
                vbH: 20,
                w: 12.w,
                h: 20.h,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'الملف التجاري',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Cairo',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBE1FF), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  child: Icon(Icons.person, size: 24.w, color: _kIconGray),
                ),
              ),
              SizedBox(width: 16.w),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: Center(
                    child: _pathIcon(
                      'M0 17V15H2V8C2 6.61667 2.41667 5.3875 3.25 4.3125C4.08333 3.2375 5.16667 2.53333 6.5 2.2V1.5C6.5 1.08333 6.64583 0.729167 6.9375 0.4375C7.22917 0.145833 7.58333 0 8 0C8.41667 0 8.77083 0.145833 9.0625 0.4375C9.35417 0.729167 9.5 1.08333 9.5 1.5V2.2C10.8333 2.53333 11.9167 3.2375 12.75 4.3125C13.5833 5.3875 14 6.61667 14 8V15H16V17H0ZM8 20C7.45 20 6.97917 19.8042 6.5875 19.4125C6.19583 19.0208 6 18.55 6 18H10C10 18.55 9.80417 19.0208 9.4125 19.4125C9.02083 19.8042 8.55 20 8 20Z',
                      vbW: 16,
                      vbH: 20,
                      w: 16.w,
                      h: 20.h,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return Obx(() => Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96.w,
              height: 96.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kSurfaceGray, width: 4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: Colors.white,
                child: Icon(Icons.store, size: 48.w, color: _kIconGray),
              ),
            ),
            Positioned(
              left: 7.w,
              bottom: 4.h,
              child: Container(
                width: 19.w,
                height: 19.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kSuccess,
                  border: Border.all(color: _kSurfaceGray, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pathIcon(
              'M6.33333 17.5L4.75 14.8333L1.75 14.1667L2.04167 11.0833L0 8.75L2.04167 6.41667L1.75 3.33333L4.75 2.66667L6.33333 0L9.16667 1.20833L12 0L13.5833 2.66667L16.5833 3.33333L16.2917 6.41667L18.3333 8.75L16.2917 11.0833L16.5833 14.1667L13.5833 14.8333L12 17.5L9.16667 16.2917L6.33333 17.5ZM8.29167 11.7083L13 7L11.8333 5.79167L8.29167 9.33333L6.5 7.58333L5.33333 8.75L8.29167 11.7083Z',
              vbW: 19,
              vbH: 18,
              w: 19.w,
              h: 18.h,
              color: _kAccentBlue,
            ),
            SizedBox(width: 8.w),
            Text(
              c.storeName.value,
              style: TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            c.storeLocation.value,
            style: TextStyle(
              color: _kTextSecondary,
              fontFamily: 'FreeSerif',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    ));
  }
}

class _VoiceOrderStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: _kAccentBlue,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -40.w,
            bottom: -40.h,
            child: Container(
              width: 160.w,
              height: 160.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64.w,
                height: 64.h,
                child: Center(
                  child: _pathIcon(
                    'M14.5 24C12.7738 24 11.3065 23.4167 10.0982 22.25C8.88988 21.0833 8.28571 19.6667 8.28571 18V6C8.28571 4.33333 8.88988 2.91667 10.0982 1.75C11.3065 0.583333 12.7738 0 14.5 0C16.2262 0 17.6935 0.583333 18.9018 1.75C20.1101 2.91667 20.7143 4.33333 20.7143 6V18C20.7143 19.6667 20.1101 21.0833 18.9018 22.25C17.6935 23.4167 16.2262 24 14.5 24ZM12.4286 38V31.85C8.8381 31.3833 5.86905 29.8333 3.52143 27.2C1.17381 24.5667 0 21.5 0 18H4.14286C4.14286 20.7667 5.15268 23.125 7.17232 25.075C9.19196 27.025 11.6345 28 14.5 28C17.3655 28 19.808 27.025 21.8277 25.075C23.8473 23.125 24.8571 20.7667 24.8571 18H29C29 21.5 27.8262 24.5667 25.4786 27.2C23.131 29.8333 20.1619 31.3833 16.5714 31.85V38H12.4286Z',
                    vbW: 29,
                    vbH: 38,
                    w: 29.w,
                    h: 38.h,
                    color: const Color(0xFFEEEFFF),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Text(
                        'الطلب الصوتي',
                        style: TextStyle(
                          color: const Color(0xFFEEEFFF),
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'قيد المراجعة',
                        style: TextStyle(
                          color: const Color(0xFFEEEFFF),
                          fontFamily: 'Cairo',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.33,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'سيتم التفعيل قريباً',
                            style: TextStyle(
                              color: const Color(0xFFEEEFFF),
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationTimeline extends StatelessWidget {
  final List<VerificationStep> steps;

  const _VerificationTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مراحل التحقق',
          style: TextStyle(
            color: _kTextPrimary,
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        for (int i = 0; i < steps.length; i++)
          _TimelineStepTile(
            step: steps[i],
            showLine: i != steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStepTile extends StatelessWidget {
  final VerificationStep step;
  final bool showLine;

  const _TimelineStepTile({required this.step, required this.showLine});

  Widget _circle() {
    switch (step.status) {
      case VerificationStepStatus.done:
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: _kIconBlue),
          child: Center(
            child: _pathIcon(
              'M3.325 7.01458L0 3.68958L0.83125 2.85833L3.325 5.35208L8.67708 0L9.50833 0.83125L3.325 7.01458Z',
              vbW: 10,
              vbH: 8,
              w: 10.w,
              h: 8.h,
              color: Colors.white,
            ),
          ),
        );
      case VerificationStepStatus.pending:
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kWarningBg,
            border: Border.all(color: _kWarningBorder, width: 2),
          ),
          child: Center(
            child: _pathIcon(
              'M2.91667 6.70833C3.15972 6.70833 3.36632 6.62326 3.53646 6.45312C3.7066 6.28299 3.79167 6.07639 3.79167 5.83333C3.79167 5.59028 3.7066 5.38368 3.53646 5.21354C3.36632 5.0434 3.15972 4.95833 2.91667 4.95833C2.67361 4.95833 2.46701 5.0434 2.29688 5.21354C2.12674 5.38368 2.04167 5.59028 2.04167 5.83333C2.04167 6.07639 2.12674 6.28299 2.29688 6.45312C2.46701 6.62326 2.67361 6.70833 2.91667 6.70833ZM5.83333 6.70833C6.07639 6.70833 6.28299 6.62326 6.45312 6.45312C6.62326 6.28299 6.70833 6.07639 6.70833 5.83333C6.70833 5.59028 6.62326 5.38368 6.45312 5.21354C6.28299 5.0434 6.07639 4.95833 5.83333 4.95833C5.59028 4.95833 5.38368 5.0434 5.21354 5.21354C5.0434 5.38368 4.95833 5.59028 4.95833 5.83333C4.95833 6.07639 5.0434 6.28299 5.21354 6.45312C5.38368 6.62326 5.59028 6.70833 5.83333 6.70833ZM8.75 6.70833C8.99306 6.70833 9.19965 6.62326 9.36979 6.45312C9.53993 6.28299 9.625 6.07639 9.625 5.83333C9.625 5.59028 9.53993 5.38368 9.36979 5.21354C9.19965 5.0434 8.99306 4.95833 8.75 4.95833C8.50694 4.95833 8.30035 5.0434 8.13021 5.21354C7.96007 5.38368 7.875 5.59028 7.875 5.83333C7.875 6.07639 7.96007 6.28299 8.13021 6.45312C8.30035 6.62326 8.50694 6.70833 8.75 6.70833ZM5.83333 11.6667C5.02639 11.6667 4.26806 11.5135 3.55833 11.2073C2.84861 10.901 2.23125 10.4854 1.70625 9.96042C1.18125 9.43542 0.765625 8.81806 0.459375 8.10833C0.153125 7.39861 0 6.64028 0 5.83333C0 5.02639 0.153125 4.26806 0.459375 3.55833C0.765625 2.84861 1.18125 2.23125 1.70625 1.70625C2.23125 1.18125 2.84861 0.765625 3.55833 0.459375C4.26806 0.153125 5.02639 0 5.83333 0C6.64028 0 7.39861 0.153125 8.10833 0.459375C8.81806 0.765625 9.43542 1.18125 9.96042 1.70625C10.4854 2.23125 10.901 2.84861 11.2073 3.55833C11.5135 4.26806 11.6667 5.02639 11.6667 5.83333C11.6667 6.64028 11.5135 7.39861 11.2073 8.10833C10.901 8.81806 10.4854 9.43542 9.96042 9.96042C9.43542 10.4854 8.81806 10.901 8.10833 11.2073C7.39861 11.5135 6.64028 11.6667 5.83333 11.6667ZM5.83333 10.5C7.13611 10.5 8.23958 10.0479 9.14375 9.14375C10.0479 8.23958 10.5 7.13611 10.5 5.83333C10.5 4.53056 10.0479 3.42708 9.14375 2.52292C8.23958 1.61875 7.13611 1.16667 5.83333 1.16667C4.53056 1.16667 3.42708 1.61875 2.52292 2.52292C1.61875 3.42708 1.16667 4.53056 1.16667 5.83333C1.16667 7.13611 1.61875 8.23958 2.52292 9.14375C3.42708 10.0479 4.53056 10.5 5.83333 10.5Z',
              vbW: 11.67,
              vbH: 11.67,
              w: 12.w,
              h: 12.h,
              color: _kWarningIcon,
            ),
          ),
        );
      case VerificationStepStatus.upcoming:
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: _kSurfaceGray),
          child: Center(
            child: _pathIcon(
              'M1.16667 11.0833C0.845833 11.0833 0.571181 10.9691 0.342708 10.7406C0.114236 10.5122 0 10.2375 0 9.91667V3.5C0 3.17917 0.114236 2.90451 0.342708 2.67604C0.571181 2.44757 0.845833 2.33333 1.16667 2.33333H3.5V1.16667C3.5 0.845833 3.61424 0.571181 3.84271 0.342708C4.07118 0.114236 4.34583 0 4.66667 0H7C7.32083 0 7.59549 0.114236 7.82396 0.342708C8.05243 0.571181 8.16667 0.845833 8.16667 1.16667V2.33333H10.5C10.8208 2.33333 11.0955 2.44757 11.324 2.67604C11.5524 2.90451 11.6667 3.17917 11.6667 3.5V9.91667C11.6667 10.2375 11.5524 10.5122 11.324 10.7406C11.0955 10.9691 10.8208 11.0833 10.5 11.0833H1.16667ZM4.66667 2.33333H7V1.16667H4.66667V2.33333ZM10.5 7.58333H7.58333V8.75H4.08333V7.58333H1.16667V9.91667H10.5V7.58333ZM5.25 7.58333H6.41667V6.41667H5.25V7.58333ZM1.16667 6.41667H4.08333V5.25H7.58333V6.41667H10.5V3.5H1.16667V6.41667Z',
              vbW: 11.67,
              vbH: 11.67,
              w: 12.w,
              h: 12.h,
              color: _kIconGray,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: step.status == VerificationStepStatus.upcoming ? 0.5 : 1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _circle(),
                if (showLine)
                  Expanded(
                    child: Container(width: 2, color: _kBorder),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: showLine ? 32.h : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      step.title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.43,
                      ),
                    ),
                    Text(
                      step.subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
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
}

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          color: _kTextPrimary,
          fontFamily: 'Cairo',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String iconPath;
  final double vbW;
  final double vbH;
  final bool showBorder;
  final bool valueIsLtr;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.iconPath,
    required this.vbW,
    required this.vbH,
    this.showBorder = true,
    this.valueIsLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: showBorder ? 12.h : 0),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            textDirection: valueIsLtr ? TextDirection.ltr : TextDirection.rtl,
            style: TextStyle(
              color: _kTextSecondary,
              fontFamily: valueIsLtr ? 'Inter' : 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _kTextPrimary,
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
              SizedBox(width: 12.w),
              _pathIcon(iconPath, vbW: vbW, vbH: vbH, w: vbW.w, h: vbH.h, color: _kIconBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessInfoSection extends StatelessWidget {
  final VoidCallback onEdit;
  const _BusinessInfoSection({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading('إعدادات المنشأة'),
        SizedBox(height: 16.h),
        Obx(() => Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              _InfoRow(
                label: 'اسم المتجر',
                value: c.storeName.value,
                iconPath:
                    'M19.0469 8.05V16C19.0469 16.55 18.8511 17.0208 18.4594 17.4125C18.0678 17.8042 17.5969 18 17.0469 18H3.04694C2.49694 18 2.02611 17.8042 1.63444 17.4125C1.24277 17.0208 1.04694 16.55 1.04694 16V8.05C0.663605 7.7 0.367772 7.25 0.159439 6.7C-0.0488946 6.15 -0.0530612 5.55 0.146939 4.9L1.19694 1.5C1.33027 1.06667 1.56777 0.708333 1.90944 0.425C2.25111 0.141667 2.64694 0 3.09694 0H16.9969C17.4469 0 17.8386 0.1375 18.1719 0.4125C18.5053 0.6875 18.7469 1.05 18.8969 1.5L19.9469 4.9C20.1469 5.55 20.1428 6.14167 19.9344 6.675C19.7261 7.20833 19.4303 7.66667 19.0469 8.05ZM12.2469 7C12.6969 7 13.0386 6.84583 13.2719 6.5375C13.5053 6.22917 13.5969 5.88333 13.5469 5.5L12.9969 2H11.0469V5.7C11.0469 6.05 11.1636 6.35417 11.3969 6.6125C11.6303 6.87083 11.9136 7 12.2469 7ZM7.74694 7C8.13027 7 8.44277 6.87083 8.68444 6.6125C8.92611 6.35417 9.04694 6.05 9.04694 5.7V2H7.09694L6.54694 5.5C6.48027 5.9 6.56777 6.25 6.80944 6.55C7.05111 6.85 7.36361 7 7.74694 7ZM3.29694 7C3.59694 7 3.85944 6.89167 4.08444 6.675C4.30944 6.45833 4.44694 6.18333 4.49694 5.85L5.04694 2H3.09694L2.09694 5.35C1.99694 5.68333 2.05111 6.04167 2.25944 6.425C2.46777 6.80833 2.81361 7 3.29694 7ZM16.7969 7C17.2803 7 17.6303 6.80833 17.8469 6.425C18.0636 6.04167 18.1136 5.68333 17.9969 5.35L16.9469 2H15.0469L15.5969 5.85C15.6469 6.18333 15.7844 6.45833 16.0094 6.675C16.2344 6.89167 16.4969 7 16.7969 7ZM3.04694 16H17.0469V8.95C16.9636 8.98333 16.9094 9 16.8844 9C16.8594 9 16.8303 9 16.7969 9C16.3469 9 15.9511 8.925 15.6094 8.775C15.2678 8.625 14.9303 8.38333 14.5969 8.05C14.2969 8.35 13.9553 8.58333 13.5719 8.75C13.1886 8.91667 12.7803 9 12.3469 9C11.8969 9 11.4761 8.91667 11.0844 8.75C10.6928 8.58333 10.3469 8.35 10.0469 8.05C9.76361 8.35 9.43444 8.58333 9.05944 8.75C8.68444 8.91667 8.28027 9 7.84694 9C7.36361 9 6.92611 8.91667 6.53444 8.75C6.14277 8.58333 5.79694 8.35 5.49694 8.05C5.14694 8.4 4.80111 8.64583 4.45944 8.7875C4.11777 8.92917 3.73027 9 3.29694 9C3.26361 9 3.22611 9 3.18444 9C3.14277 9 3.09694 8.98333 3.04694 8.95V16Z',
                vbW: 21,
                vbH: 18,
              ),
              SizedBox(height: 12.h),
              _InfoRow(
                label: 'التصنيف',
                value: c.storeCategory.value,
                iconPath:
                    'M3.5 9L9 0L14.5 9H3.5ZM14.5 20C13.25 20 12.1875 19.5625 11.3125 18.6875C10.4375 17.8125 10 16.75 10 15.5C10 14.25 10.4375 13.1875 11.3125 12.3125C12.1875 11.4375 13.25 11 14.5 11C15.75 11 16.8125 11.4375 17.6875 12.3125C18.5625 13.1875 19 14.25 19 15.5C19 16.75 18.5625 17.8125 17.6875 18.6875C16.8125 19.5625 15.75 20 14.5 20ZM0 19.5V11.5H8V19.5H0ZM14.5 18C15.2 18 15.7917 17.7583 16.275 17.275C16.7583 16.7917 17 16.2 17 15.5C17 14.8 16.7583 14.2083 16.275 13.725C15.7917 13.2417 15.2 13 14.5 13C13.8 13 13.2083 13.2417 12.725 13.725C12.2417 14.2083 12 14.8 12 15.5C12 16.2 12.2417 16.7917 12.725 17.275C13.2083 17.7583 13.8 18 14.5 18ZM2 17.5H6V13.5H2V17.5ZM7.05 7H10.95L9 3.85L7.05 7Z',
                vbW: 19,
                vbH: 20,
              ),
              SizedBox(height: 12.h),
              _InfoRow(
                label: 'رقم السجل التجاري',
                value: c.commercialRegisterNumber.value,
                valueIsLtr: true,
                showBorder: false,
                iconPath:
                    'M4 16H12V14H4V16ZM4 12H12V10H4V12ZM2 20C1.45 20 0.979167 19.8042 0.5875 19.4125C0.195833 19.0208 0 18.55 0 18V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H10L16 6V18C16 18.55 15.8042 19.0208 15.4125 19.4125C15.0208 19.8042 14.55 20 14 20H2ZM9 7V2H2V18H14V7H9ZM2 2V7V2V7V18V2Z',
                vbW: 16,
                vbH: 20,
              ),
            ],
          ),
        )),
        SizedBox(height: 16.h),
        _MapCard(onEdit: onEdit),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  final VoidCallback onEdit;
  const _MapCard({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 128.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Obx(() {
                  if (c.lat.value == 0.0 && c.lng.value == 0.0) {
                    return Container(
                      color: const Color(0xFFE5E7EB),
                      child: Center(
                        child: Icon(Icons.map, size: 48.w, color: _kIconGray),
                      ),
                    );
                  }
                  return FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(c.lat.value, c.lng.value),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(c.lat.value, c.lng.value),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    'تعديل',
                    style: TextStyle(
                      color: _kIconBlue,
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الموقع',
                      style: TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.43,
                      ),
                    ),
                    Obx(() => Text(
                      c.storeAddress.value,
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 8.h),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
                ),
                child: Text(
                  'معلومات التواصل',
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _ContactRow(
                value: c.phoneNumber.value,
                iconPath:
                    'M16.95 18C14.8667 18 12.8083 17.5458 10.775 16.6375C8.74167 15.7292 6.89167 14.4417 5.225 12.775C3.55833 11.1083 2.27083 9.25833 1.3625 7.225C0.454167 5.19167 0 3.13333 0 1.05C0 0.75 0.1 0.5 0.3 0.3C0.5 0.1 0.75 0 1.05 0H5.1C5.33333 0 5.54167 0.0791667 5.725 0.2375C5.90833 0.395833 6.01667 0.583333 6.05 0.8L6.7 4.3C6.73333 4.56667 6.725 4.79167 6.675 4.975C6.625 5.15833 6.53333 5.31667 6.4 5.45L3.975 7.9C4.30833 8.51667 4.70417 9.1125 5.1625 9.6875C5.62083 10.2625 6.125 10.8167 6.675 11.35C7.19167 11.8667 7.73333 12.3458 8.3 12.7875C8.86667 13.2292 9.46667 13.6333 10.1 14L12.45 11.65C12.6 11.5 12.7958 11.3875 13.0375 11.3125C13.2792 11.2375 13.5167 11.2167 13.75 11.25L17.2 11.95C17.4333 12.0167 17.625 12.1375 17.775 12.3125C17.925 12.4875 18 12.6833 18 12.9V16.95C18 17.25 17.9 17.5 17.7 17.7C17.5 17.9 17.25 18 16.95 18ZM3.025 6L4.675 4.35L4.25 2H2.025C2.10833 2.68333 2.225 3.35833 2.375 4.025C2.525 4.69167 2.74167 5.35 3.025 6ZM11.975 14.95C12.625 15.2333 13.2875 15.4583 13.9625 15.625C14.6375 15.7917 15.3167 15.9 16 15.95V13.75L13.65 13.275L11.975 14.95Z',
                vbW: 18,
                vbH: 18,
              ),
              SizedBox(height: 16.h),
              _ContactRow(
                value: c.email.value,
                iconPath:
                    'M2 16C1.45 16 0.979167 15.8042 0.5875 15.4125C0.195833 15.0208 0 14.55 0 14V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V14C20 14.55 19.8042 15.0208 19.4125 15.4125C19.0208 15.8042 18.55 16 18 16H2ZM10 9L2 4V14H18V4L10 9ZM10 7L18 2H2L10 7ZM2 4V2V4V14V4Z',
                vbW: 20,
                vbH: 16,
              ),
            ],
          )),
        ),
        SizedBox(height: 16.h),
        Obx(() => _BusinessHoursToggle(
              enabled: c.businessHoursEnabled.value,
              onTap: c.toggleBusinessHours,
            )),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String value;
  final String iconPath;
  final double vbW;
  final double vbH;

  const _ContactRow({
    required this.value,
    required this.iconPath,
    required this.vbW,
    required this.vbH,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _pathIcon(
          'M3.5 7L0 3.5L3.5 0L4.31667 0.816667L1.63333 3.5L4.31667 6.18333L3.5 7Z',
          vbW: 5,
          vbH: 7,
          w: 5.w,
          h: 7.h,
          color: _kIconGray,
        ),
        Row(
          children: [
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
            SizedBox(width: 12.w),
            _pathIcon(iconPath, vbW: vbW, vbH: vbH, w: vbW.w, h: vbH.h, color: _kIconBlue),
          ],
        ),
      ],
    );
  }
}

class _BusinessHoursToggle extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _BusinessHoursToggle({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44.w,
              height: 24.h,
              padding: EdgeInsets.all(2.w),
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: enabled ? _kIconBlue : _kBorder,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ساعات العمل',
                    style: TextStyle(
                      color: _kTextPrimary,
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    'متاح 24/7',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: _kTextSecondary,
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              _pathIcon(
                'M13.3 14.7L14.7 13.3L11 9.6V5H9V10.4L13.3 14.7ZM10 20C8.61667 20 7.31667 19.7375 6.1 19.2125C4.88333 18.6875 3.825 17.975 2.925 17.075C2.025 16.175 1.3125 15.1167 0.7875 13.9C0.2625 12.6833 0 11.3833 0 10C0 8.61667 0.2625 7.31667 0.7875 6.1C1.3125 4.88333 2.025 3.825 2.925 2.925C3.825 2.025 4.88333 1.3125 6.1 0.7875C7.31667 0.2625 8.61667 0 10 0C11.3833 0 12.6833 0.2625 13.9 0.7875C15.1167 1.3125 16.175 2.025 17.075 2.925C17.975 3.825 18.6875 4.88333 19.2125 6.1C19.7375 7.31667 20 8.61667 20 10C20 11.3833 19.7375 12.6833 19.2125 13.9C18.6875 15.1167 17.975 16.175 17.075 17.075C16.175 17.975 15.1167 18.6875 13.9 19.2125C12.6833 19.7375 11.3833 20 10 20ZM10 18C12.2167 18 14.1042 17.2208 15.6625 15.6625C17.2208 14.1042 18 12.2167 18 10C18 7.78333 17.2208 5.89583 15.6625 4.3375C14.1042 2.77917 12.2167 2 10 2C7.78333 2 5.89583 2.77917 4.3375 4.3375C2.77917 5.89583 2 7.78333 2 10C2 12.2167 2.77917 14.1042 4.3375 15.6625C5.89583 17.2208 7.78333 18 10 18Z',
                vbW: 20,
                vbH: 20,
                w: 20.w,
                h: 20.h,
                color: _kIconBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading('الإعدادات العامة'),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SettingsRow(
                label: 'الإشعارات',
                iconPath:
                    'M0 8.05C0 6.38333 0.370833 4.85417 1.1125 3.4625C1.85417 2.07083 2.85 0.916667 4.1 0L5.275 1.6C4.275 2.33333 3.47917 3.25833 2.8875 4.375C2.29583 5.49167 2 6.71667 2 8.05H0ZM18 8.05C18 6.71667 17.7042 5.49167 17.1125 4.375C16.5208 3.25833 15.725 2.33333 14.725 1.6L15.9 0C17.15 0.916667 18.1458 2.07083 18.8875 3.4625C19.6292 4.85417 20 6.38333 20 8.05H18ZM2 17.05V15.05H4V8.05C4 6.66667 4.41667 5.4375 5.25 4.3625C6.08333 3.2875 7.16667 2.58333 8.5 2.25V1.55C8.5 1.13333 8.64583 0.779167 8.9375 0.4875C9.22917 0.195833 9.58333 0.05 10 0.05C10.4167 0.05 10.7708 0.195833 11.0625 0.4875C11.3542 0.779167 11.5 1.13333 11.5 1.55V2.25C12.8333 2.58333 13.9167 3.2875 14.75 4.3625C15.5833 5.4375 16 6.66667 16 8.05V15.05H18V17.05H2ZM10 20.05C9.45 20.05 8.97917 19.8542 8.5875 19.4625C8.19583 19.0708 8 18.6 8 18.05H12C12 18.6 11.8042 19.0708 11.4125 19.4625C11.0208 19.8542 10.55 20.05 10 20.05ZM6 15.05H14V8.05C14 6.95 13.6083 6.00833 12.825 5.225C12.0417 4.44167 11.1 4.05 10 4.05C8.9 4.05 7.95833 4.44167 7.175 5.225C6.39167 6.00833 6 6.95 6 8.05V15.05Z',
                vbW: 20,
                vbH: 21,
                showBorder: false,
                onTap: () {},
              ),
              _SettingsRow(
                label: 'اللغة والمظهر',
                caption: 'العربية',
                iconPath:
                    'M10.0125 20C8.6375 20 7.34167 19.7375 6.125 19.2125C4.90833 18.6875 3.84583 17.9708 2.9375 17.0625C2.02917 16.1542 1.3125 15.0917 0.7875 13.875C0.2625 12.6583 0 11.3625 0 9.9875C0 8.6125 0.2625 7.32083 0.7875 6.1125C1.3125 4.90417 2.02917 3.84583 2.9375 2.9375C3.84583 2.02917 4.90833 1.3125 6.125 0.7875C7.34167 0.2625 8.6375 0 10.0125 0C11.3875 0 12.6792 0.2625 13.8875 0.7875C15.0958 1.3125 16.1542 2.02917 17.0625 2.9375C17.9708 3.84583 18.6875 4.90417 19.2125 6.1125C19.7375 7.32083 20 8.6125 20 9.9875C20 11.3625 19.7375 12.6583 19.2125 13.875C18.6875 15.0917 17.9708 16.1542 17.0625 17.0625C16.1542 17.9708 15.0958 18.6875 13.8875 19.2125C12.6792 19.7375 11.3875 20 10.0125 20ZM10 17.95C10.4333 17.35 10.8083 16.725 11.125 16.075C11.4417 15.425 11.7 14.7333 11.9 14H8.1C8.3 14.7333 8.55833 15.425 8.875 16.075C9.19167 16.725 9.56667 17.35 10 17.95ZM7.4 17.55C7.1 17 6.8375 16.4292 6.6125 15.8375C6.3875 15.2458 6.2 14.6333 6.05 14H3.1C3.58333 14.8333 4.1875 15.5583 4.9125 16.175C5.6375 16.7917 6.46667 17.25 7.4 17.55ZM12.6 17.55C13.5333 17.25 14.3625 16.7917 15.0875 16.175C15.8125 15.5583 16.4167 14.8333 16.9 14H13.95C13.8 14.6333 13.6125 15.2458 13.3875 15.8375C13.1625 16.4292 12.9 17 12.6 17.55ZM2.25 12H5.65C5.6 11.6667 5.5625 11.3375 5.5375 11.0125C5.5125 10.6875 5.5 10.35 5.5 10C5.5 9.65 5.5125 9.3125 5.5375 8.9875C5.5625 8.6625 5.6 8.33333 5.65 8H2.25C2.16667 8.33333 2.10417 8.6625 2.0625 8.9875C2.02083 9.3125 2 9.65 2 10C2 10.35 2.02083 10.6875 2.0625 11.0125C2.10417 11.3375 2.16667 11.6667 2.25 12ZM7.65 12H12.35C12.4 11.6667 12.4375 11.3375 12.4625 11.0125C12.4875 10.6875 12.5 10.35 12.5 10C12.5 9.65 12.4875 9.3125 12.4625 8.9875C12.4375 8.6625 12.4 8.33333 12.35 8H7.65C7.6 8.33333 7.5625 8.6625 7.5375 8.9875C7.5125 9.3125 7.5 9.65 7.5 10C7.5 10.35 7.5125 10.6875 7.5375 11.0125C7.5625 11.3375 7.6 11.6667 7.65 12ZM14.35 12H17.75C17.8333 11.6667 17.8958 11.3375 17.9375 11.0125C17.9792 10.6875 18 10.35 18 10C18 9.65 17.9792 9.3125 17.9375 8.9875C17.8958 8.6625 17.8333 8.33333 17.75 8H14.35C14.4 8.33333 14.4375 8.6625 14.4625 8.9875C14.4875 9.3125 14.5 9.65 14.5 10C14.5 10.35 14.4875 10.6875 14.4625 11.0125C14.4375 11.3375 14.4 11.6667 14.35 12ZM13.95 6H16.9C16.4167 5.16667 15.8125 4.44167 15.0875 3.825C14.3625 3.20833 13.5333 2.75 12.6 2.45C12.9 3 13.1625 3.57083 13.3875 4.1625C13.6125 4.75417 13.8 5.36667 13.95 6ZM8.1 6H11.9C11.7 5.26667 11.4417 4.575 11.125 3.925C10.8083 3.275 10.4333 2.65 10 2.05C9.56667 2.65 9.19167 3.275 8.875 3.925C8.55833 4.575 8.3 5.26667 8.1 6ZM3.1 6H6.05C6.2 5.36667 6.3875 4.75417 6.6125 4.1625C6.8375 3.57083 7.1 3 7.4 2.45C6.46667 2.75 5.6375 3.20833 4.9125 3.825C4.1875 4.44167 3.58333 5.16667 3.1 6Z',
                vbW: 20,
                vbH: 20,
                onTap: settings.toggleLanguage,
              ),
              _SettingsRow(
                label: 'الأمان والخصوصية',
                iconPath:
                    'M8 20C5.68333 19.4167 3.77083 18.0875 2.2625 16.0125C0.754167 13.9375 0 11.6333 0 9.1V3L8 0L16 3V9.1C16 11.6333 15.2458 13.9375 13.7375 16.0125C12.2292 18.0875 10.3167 19.4167 8 20ZM8 17.9C9.61667 17.4 10.9667 16.4125 12.05 14.9375C13.1333 13.4625 13.7667 11.8167 13.95 10H8V2.125L2 4.375V9.1C2 9.28333 2 9.43333 2 9.55C2 9.66667 2.01667 9.81667 2.05 10H8V17.9Z',
                vbW: 16,
                vbH: 20,
                onTap: () {},
              ),
              _SettingsRow(
                label: 'الأذونات',
                iconPath:
                    'M6 8C5.45 8 4.97917 7.80417 4.5875 7.4125C4.19583 7.02083 4 6.55 4 6C4 5.45 4.19583 4.97917 4.5875 4.5875C4.97917 4.19583 5.45 4 6 4C6.55 4 7.02083 4.19583 7.4125 4.5875C7.80417 4.97917 8 5.45 8 6C8 6.55 7.80417 7.02083 7.4125 7.4125C7.02083 7.80417 6.55 8 6 8ZM6 12C4.33333 12 2.91667 11.4167 1.75 10.25C0.583333 9.08333 0 7.66667 0 6C0 4.33333 0.583333 2.91667 1.75 1.75C2.91667 0.583333 4.33333 0 6 0C7.11667 0 8.12917 0.275 9.0375 0.825C9.94583 1.375 10.6667 2.1 11.2 3H20L23 6L18.5 10.5L16.5 9L14.5 10.5L12.375 9H11.2C10.6667 9.9 9.94583 10.625 9.0375 11.175C8.12917 11.725 7.11667 12 6 12ZM6 10C6.93333 10 7.75417 9.71667 8.4625 9.15C9.17083 8.58333 9.64167 7.86667 9.875 7H13L14.45 8.025L16.5 6.5L18.275 7.875L20.15 6L19.15 5H9.875C9.64167 4.13333 9.17083 3.41667 8.4625 2.85C7.75417 2.28333 6.93333 2 6 2C4.9 2 3.95833 2.39167 3.175 3.175C2.39167 3.95833 2 4.9 2 6C2 7.1 2.39167 8.04167 3.175 8.825C3.95833 9.60833 4.9 10 6 10Z',
                vbW: 23,
                vbH: 12,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? caption;
  final String iconPath;
  final double vbW;
  final double vbH;
  final bool showBorder;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.label,
    this.caption,
    required this.iconPath,
    required this.vbW,
    required this.vbH,
    this.showBorder = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: showBorder
            ? const BoxDecoration(
                border: Border(top: BorderSide(color: _kBorder, width: 1)),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pathIcon(
              'M6 12L0 6L6 0L7.4 1.4L2.8 6L7.4 10.6L6 12Z',
              vbW: 8,
              vbH: 12,
              w: 8.w,
              h: 12.h,
              color: _kIconGray,
            ),
            Row(
              children: [
                if (caption != null) ...[
                  Text(
                    caption!,
                    style: TextStyle(
                      color: _kTextSecondary,
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: _kSurfaceGray,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: _pathIcon(iconPath, vbW: vbW, vbH: vbH, w: vbW.w, h: vbH.h, color: _kIconGray),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpSupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 8.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
            ),
            child: Text(
              'الدعم الفني',
              style: TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _HelpButton(
                  label: 'الشروط',
                  iconPath:
                      'M8 20C5.68333 19.4167 3.77083 18.0875 2.2625 16.0125C0.754167 13.9375 0 11.6333 0 9.1V3L8 0L16 3V9.1C16 10.5167 15.7583 11.8792 15.275 13.1875C14.7917 14.4958 14.1 15.65 13.2 16.65L10 13.45C9.7 13.6333 9.37917 13.7708 9.0375 13.8625C8.69583 13.9542 8.35 14 8 14C6.9 14 5.95833 13.6083 5.175 12.825C4.39167 12.0417 4 11.1 4 10C4 8.9 4.39167 7.95833 5.175 7.175C5.95833 6.39167 6.9 6 8 6C9.1 6 10.0417 6.39167 10.825 7.175C11.6083 7.95833 12 8.9 12 10C12 10.3667 11.9542 10.7208 11.8625 11.0625C11.7708 11.4042 11.6333 11.7333 11.45 12.05L12.95 13.55C13.2833 12.8667 13.5417 12.15 13.725 11.4C13.9083 10.65 14 9.88333 14 9.1V4.375L8 2.125L2 4.375V9.1C2 11.1167 2.56667 12.95 3.7 14.6C4.83333 16.25 6.26667 17.35 8 17.9C8.43333 17.7667 8.84583 17.5958 9.2375 17.3875C9.62917 17.1792 10.0167 16.9333 10.4 16.65L11.8 18.05C11.25 18.5 10.6542 18.8917 10.0125 19.225C9.37083 19.5583 8.7 19.8167 8 20ZM8 12C8.55 12 9.02083 11.8042 9.4125 11.4125C9.80417 11.0208 10 10.55 10 10C10 9.45 9.80417 8.97917 9.4125 8.5875C9.02083 8.19583 8.55 8 8 8C7.45 8 6.97917 8.19583 6.5875 8.5875C6.19583 8.97917 6 9.45 6 10C6 10.55 6.19583 11.0208 6.5875 11.4125C6.97917 11.8042 7.45 12 8 12Z',
                  vbW: 16,
                  vbH: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _HelpButton(
                  label: 'محادثة',
                  iconPath:
                      'M4 12H12V10H4V12ZM4 9H16V7H4V9ZM4 6H16V4H4V6ZM0 20V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V14C20 14.55 19.8042 15.0208 19.4125 15.4125C19.0208 15.8042 18.55 16 18 16H4L0 20ZM3.15 14H18V2H2V15.125L3.15 14ZM2 14V2V14Z',
                  vbW: 20,
                  vbH: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _HelpButton(
                  label: 'الأسئلة',
                  iconPath:
                      'M12 13C12.2833 13 12.5292 12.8958 12.7375 12.6875C12.9458 12.4792 13.05 12.2333 13.05 11.95C13.05 11.6667 12.9458 11.4208 12.7375 11.2125C12.5292 11.0042 12.2833 10.9 12 10.9C11.7167 10.9 11.4708 11.0042 11.2625 11.2125C11.0542 11.4208 10.95 11.6667 10.95 11.95C10.95 12.2333 11.0542 12.4792 11.2625 12.6875C11.4708 12.8958 11.7167 13 12 13ZM11.25 9.8H12.75C12.75 9.31667 12.8 8.9625 12.9 8.7375C13 8.5125 13.2333 8.21667 13.6 7.85C14.1 7.35 14.4333 6.94583 14.6 6.6375C14.7667 6.32917 14.85 5.96667 14.85 5.55C14.85 4.8 14.5875 4.1875 14.0625 3.7125C13.5375 3.2375 12.85 3 12 3C11.3167 3 10.7208 3.19167 10.2125 3.575C9.70417 3.95833 9.35 4.46667 9.15 5.1L10.5 5.65C10.65 5.23333 10.8542 4.92083 11.1125 4.7125C11.3708 4.50417 11.6667 4.4 12 4.4C12.4 4.4 12.725 4.5125 12.975 4.7375C13.225 4.9625 13.35 5.26667 13.35 5.65C13.35 5.88333 13.2833 6.10417 13.15 6.3125C13.0167 6.52083 12.7833 6.78333 12.45 7.1C11.9 7.58333 11.5625 7.9625 11.4375 8.2375C11.3125 8.5125 11.25 9.03333 11.25 9.8ZM6 16C5.45 16 4.97917 15.8042 4.5875 15.4125C4.19583 15.0208 4 14.55 4 14V2C4 1.45 4.19583 0.979167 4.5875 0.5875C4.97917 0.195833 5.45 0 6 0H18C18.55 0 19.0208 0.195833 19.4125 0.5875C19.8042 0.979167 20 1.45 20 2V14C20 14.55 19.8042 15.0208 19.4125 15.4125C19.0208 15.8042 18.55 16 18 16H6ZM6 14H18V2H6V14ZM2 20C1.45 20 0.979167 19.8042 0.5875 19.4125C0.195833 19.0208 0 18.55 0 18V4H2V18H16V20H2ZM6 2V14V2Z',
                  vbW: 20,
                  vbH: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final double vbW;
  final double vbH;

  const _HelpButton({
    required this.label,
    required this.iconPath,
    required this.vbW,
    required this.vbH,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pathIcon(iconPath, vbW: vbW, vbH: vbH, w: vbW.w, h: vbH.h, color: _kIconBlue),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Get.offAll(() => const LoginScreen()),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _kDangerText.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: _kDangerText,
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                SizedBox(width: 8.w),
                _pathIcon(
                  'M2 18C1.45 18 0.979167 17.8042 0.5875 17.4125C0.195833 17.0208 0 16.55 0 16V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H9V2H2V16H9V18H2ZM13 14L11.625 12.55L14.175 10H6V8H14.175L11.625 5.45L13 4L18 9L13 14Z',
                  vbW: 18,
                  vbH: 18,
                  w: 18.w,
                  h: 18.h,
                  color: _kDangerText,
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final confirm = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
                content: const Text('هل أنت متأكد من أنك تريد حذف حسابك نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.', style: TextStyle(fontFamily: 'Cairo')),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('حذف نهائياً', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              final c = Get.find<ProfileController>();
              final success = await c.deleteAccount();
              if (success) {
                Get.offAll(() => const LoginScreen());
              } else {
                Get.snackbar('خطأ', 'حدث خطأ أثناء حذف الحساب');
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'حذف الحساب نهائياً',
              style: TextStyle(
                color: _kTextSecondary,
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
