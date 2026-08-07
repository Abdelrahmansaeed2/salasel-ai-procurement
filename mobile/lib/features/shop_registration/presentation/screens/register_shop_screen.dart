import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/register_shop_controller.dart';
import '../theme/shop_registration_colors.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/registration_header.dart';
import '../widgets/registration_stepper.dart';
import '../widgets/select_field.dart';
import '../widgets/store_size_selector.dart';
import '../theme/shop_registration_icons.dart';
import '../widgets/wizard_footer.dart';
import 'registration_submitted_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterShopScreen extends StatelessWidget {
  const RegisterShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure a single persistent controller instance for the wizard
    final RegisterShopController controller = Get.isRegistered<RegisterShopController>()
        ? Get.find<RegisterShopController>()
        : Get.put(RegisterShopController(), permanent: true);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final step = controller.currentStep.value;
        final isReviewStep = step == 3;

        return PopScope(
          canPop: step == 1,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && step > 1) controller.previousStep();
          },
          child: Scaffold(
            backgroundColor: isReviewStep ? ShopRegColors.pageBackgroundGray : ShopRegColors.pageBackgroundPurple,
            appBar: RegistrationHeader(
              title: isReviewStep ? 'مراجعة البيانات' : 'تسجيل التجار في سلاسل',
              titleWeight: isReviewStep ? FontWeight.w400 : FontWeight.w500,
              onBack: step > 1 ? controller.previousStep : null,
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(step),
                  child: switch (step) {
                    1 => _StepOneShopInfo(controller: controller),
                    2 => _StepTwoBusinessLocation(controller: controller),
                    _ => _StepThreeReview(controller: controller),
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}


class _StepOneShopInfo extends StatelessWidget {
  const _StepOneShopInfo({required this.controller});

  final RegisterShopController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RegistrationStepper(currentStep: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroWelcomeSection(),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: ShopRegColors.primarySoft,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: FigmaIcon(ShopRegIcons.shop, size: 20.w, color: ShopRegColors.primary),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'معلومات المتجر (الخطوة 1 من 3)',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: ShopRegColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                LabeledTextField(
                  label: 'اسم المتجر',
                  hint: 'أدخل اسم المتجر',
                  icon: ShopRegIcons.shop,
                  controller: controller.shopNameController,
                ),
                SizedBox(height: 24.h),
                LabeledTextField(
                  label: 'اسم صاحب العمل',
                  hint: 'أدخل الاسم بالكامل',
                  icon: ShopRegIcons.person,
                  controller: controller.ownerNameController,
                ),
                SizedBox(height: 24.h),
                LabeledTextField(
                  label: 'رقم السجل التجاري',
                  hint: '1010XXXXXX',
                  icon: ShopRegIcons.idCard,
                  controller: controller.crNumberController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24.h),
                LabeledTextField(
                  label: 'رقم الهاتف',
                  hint: '5xxxxxxxx',
                  icon: ShopRegIcons.phone,
                  prefixText: '+966',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 24.h),
                Obx(() => SelectField(
                      label: 'الموقع',
                      value: controller.selectedCity.value,
                      placeholder: 'اختر المدينة',
                      options: RegisterShopController.cityOptions,
                      icon: ShopRegIcons.locationPin,
                      onChanged: (v) => controller.selectedCity.value = v,
                    )),
                SizedBox(height: 24.h),
                Obx(() => SelectField(
                      label: 'تصنيف المتجر',
                      value: controller.selectedCategory.value,
                      placeholder: 'اختر فئة المتجر',
                      options: RegisterShopController.categoryOptions,
                      onChanged: (v) => controller.selectedCategory.value = v,
                    )),
                Obx(() => AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: controller.selectedCategory.value != null
                          ? AiInsightCard(
                              key: ValueKey(controller.selectedCategory.value),
                              message:
                                  'لقد لاحظنا أنك تختار تصنيف "${controller.selectedCategory.value}"، المتاجر المشابهة في منطقتك تحقق مبيعات أعلى بنسبة 20% عند إضافة صور عالية الجودة للمنتجات الأساسية.',
                            )
                          : SizedBox.shrink(),
                    )),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تصنيف المتجر',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.textBody,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => StoreSizeSelector(
                      options: RegisterShopController.storeSizes,
                      selected: controller.storeSize.value,
                      onSelected: controller.selectStoreSize,
                    )),
                SizedBox(height: 24.h),
                WizardFooter(
                  continueLabel: 'متابعة',
                  onContinue: controller.nextStep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroWelcomeSection extends StatelessWidget {
  const _HeroWelcomeSection();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 192.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hero_illustration.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مرحبا بكم في سلاسل!',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'لنبدأ بتجهيز متجرك الإلكتروني الجديد في خطوات بسيطة.',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.9),
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
      ),
    );
  }
}




class _StepTwoBusinessLocation extends StatelessWidget {
  const _StepTwoBusinessLocation({required this.controller});

  final RegisterShopController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RegistrationStepper(currentStep: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _MapPickerSection(),
                SizedBox(height: 24.h),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: ShopRegColors.primarySoft,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: FigmaIcon(ShopRegIcons.businessBag, size: 20.w, color: ShopRegColors.primary),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'بيانات العمل (الخطوة 2 من 3)',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: ShopRegColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المحافظة والمدينة',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.textBody,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => SelectField(
                            value: controller.governorate.value,
                            placeholder: 'المحافظة',
                            options: RegisterShopController.governorateOptions,
                            onChanged: (v) => controller.governorate.value = v,
                          )),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Obx(() => SelectField(
                            value: controller.businessCity.value,
                            placeholder: 'المدينة',
                            options: RegisterShopController.businessCityOptions,
                            onChanged: (v) => controller.businessCity.value = v,
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                LabeledTextField(
                  label: 'العنوان بالتفصيل',
                  hint: 'مثال: حي النخيل، شارع الأمير تركي الأول، برج آيكون، الدور 4',
                  controller: controller.addressController,
                  maxLines: 5,
                  showInfoIcon: true,
                ),
                WizardFooter(
                  continueLabel: 'متابعة',
                  showBack: true,
                  onBack: controller.previousStep,
                  onContinue: controller.nextStep,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPickerSection extends StatefulWidget {
  const _MapPickerSection();

  @override
  State<_MapPickerSection> createState() => _MapPickerSectionState();
}

class _MapPickerSectionState extends State<_MapPickerSection> {
  bool _locating = false;
  final MapController _mapController = MapController();
  LatLng _center = LatLng(24.7136, 46.6753); // Riyadh default

  Future<void> _autoLocate() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      final newLoc = LatLng(position.latitude, position.longitude);
      _mapController.move(newLoc, 15.0);
      setState(() {
        _center = newLoc;
      });
      final controller = Get.find<RegisterShopController>();
      controller.locationLat.value = _center.latitude;
      controller.locationLng.value = _center.longitude;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 288.h,
        decoration: BoxDecoration(
          color: ShopRegColors.mapPlaceholder,
          border: Border.all(color: ShopRegColors.inputBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 13.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && position.center != null) {
                      _center = position.center!;
                      final controller = Get.find<RegisterShopController>();
                      controller.locationLat.value = _center.latitude;
                      controller.locationLng.value = _center.longitude;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.salasel.mobile',
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: FigmaIcon(ShopRegIcons.mapPinLarge, size: 40.w),
            ),
            Positioned(
              bottom: 16.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: InkWell(
                      onTap: _autoLocate,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تحديد الموقع تلقائياً',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: ShopRegColors.primary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _locating
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ShopRegColors.primary,
                                    ),
                                  )
                                : FigmaIcon(ShopRegIcons.gps, color: ShopRegColors.primary, size: 20.w),
                          ],
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
    );
  }
}


class _StepThreeReview extends StatelessWidget {
  const _StepThreeReview({required this.controller});

  final RegisterShopController controller;

  void _submitRegistration() async {
    final success = await controller.submitRegistration();
    if (!success) return;

    // Mark that the merchant has completed shop registration
    final storage = GetStorage();
    storage.write('shopRegistered', true);
    Get.off(() => const RegistrationSubmittedScreen(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'الخطوة الأخيرة',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: ShopRegColors.textMuted,
                ),
              ),
              Spacer(),
              Text(
                '3 من 3',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              height: 6.h,
              color: Color(0xFFECEEF0),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: 1,
                child: DecoratedBox(decoration: BoxDecoration(color: ShopRegColors.primary)),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/images/badge_icon.png',
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: ShopRegColors.primarySoft,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: ShopRegColors.primary, size: 20.w),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'ملخص البيانات',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: ShopRegColors.textDark2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'يرجى مراجعة كافة المعلومات المدخلة قبل إرسال الطلب لضمان سرعة المعالجة.',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        height: 1.55.h,
                        color: ShopRegColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _ReviewSection(
                title: 'بيانات المنشأة',
                icon: ShopRegIcons.shop,
                onEdit: () => controller.currentStep.value = 1,
                rows: [
                  _ReviewRow(value: controller.displayShopName, label: 'اسم المنشأة'),
                  _ReviewRow(value: controller.displayCategory, label: 'نوع النشاط'),
                  _ReviewRow(value: controller.displayCrNumber, label: 'السجل التجاري'),
                ],
              ),
          SizedBox(height: 16.h),
          _ReviewSection(
                title: 'موقع النشاط',
                icon: ShopRegIcons.locationPin,
                onEdit: () => controller.currentStep.value = 2,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/map_bg.png',
                    height: 96.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 96.h,
                      color: ShopRegColors.mapPlaceholder,
                      child: Icon(Icons.map_outlined, color: ShopRegColors.textMuted),
                    ),
                  ),
                ),
                rows: [
                  _ReviewRow(value: controller.displayAddress, label: 'العنوان'),
                  _ReviewRow(value: controller.displayGovernorate, label: 'المحافظة'),
                  _ReviewRow(value: controller.displayBusinessCity, label: 'المدينة'),
                  _ReviewRow(value: controller.displayStoreSize, label: 'حجم المتجر'),
                ],
              ),
          SizedBox(height: 16.h),
          _ReviewSection(
                title: 'بيانات المالك',
                icon: ShopRegIcons.person,
                onEdit: () => controller.currentStep.value = 1,
                rows: [
                  _ReviewRow(value: controller.displayOwnerName, label: 'الاسم الكامل'),
                  _ReviewRow(value: controller.displayOwnerId, label: 'رقم الهوية'),
                  _ReviewRow(
                    value: controller.displayOwnerPhone,
                    label: 'رقم الجوال',
                    valueLtr: true,
                  ),
                ],
              ),
          SizedBox(height: 16.h),
          Obx(() => _TermsRow(
                checked: controller.agreedToTerms.value,
                onChanged: (v) => controller.agreedToTerms.value = v ?? false,
              )),
          SizedBox(height: 16.h),
          Obx(() => WizardFooter(
                continueLabel: 'إرسال الطلب',
                continueEnabled: controller.agreedToTerms.value,
                showBack: true,
                onBack: controller.previousStep,
                onContinue: _submitRegistration,
              )),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.rows,
    required this.onEdit,
    this.leading,
  });

  final String title;
  final String icon;
  final List<_ReviewRow> rows;
  final VoidCallback onEdit;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ShopRegColors.divider)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    FigmaIcon(icon, size: 18.w, color: ShopRegColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: ShopRegColors.textDark2,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: FigmaIcon(ShopRegIcons.editPencil, size: 11.w, color: ShopRegColors.primary),
                  label: Text(
                    'تعديل',
                    style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ShopRegColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                if (leading != null) ...[
                  SizedBox(width: double.infinity, child: leading),
                  SizedBox(height: 16.h),
                ],
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) SizedBox(height: 16.h),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.value, required this.label, this.valueLtr = false});

  final String value;
  final String label;
  final bool valueLtr;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: ShopRegColors.textMuted,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: valueLtr ? TextAlign.left : TextAlign.right,
            textDirection: valueLtr ? TextDirection.ltr : TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: ShopRegColors.textDark2,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: checked,
          onChanged: onChanged,
          activeColor: ShopRegColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: GoogleFonts.cairo(fontSize: 12.sp, height: 1.9.h, color: ShopRegColors.textMuted),
                children: [
                  TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'الشروط والأحكام',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' وأقر بصحة البيانات المدخلة أعلاه كجزء من عملية التسجيل كتاجر معتمد.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
