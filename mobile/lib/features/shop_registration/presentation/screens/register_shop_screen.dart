import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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

class RegisterShopScreen extends StatelessWidget {
  const RegisterShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterShopController());

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
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
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
          const RegistrationStepper(currentStep: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroWelcomeSection(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ShopRegColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const FigmaIcon(ShopRegIcons.shop, size: 20, color: ShopRegColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'معلومات المتجر (الخطوة 1 من 3)',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ShopRegColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'اسم المتجر',
                  hint: 'أدخل اسم المتجر',
                  icon: ShopRegIcons.shop,
                  controller: controller.shopNameController,
                ),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: 'اسم صاحب العمل',
                  hint: 'أدخل الاسم بالكامل',
                  icon: ShopRegIcons.person,
                  controller: controller.ownerNameController,
                ),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: 'رقم السجل التجاري',
                  hint: '1010XXXXXX',
                  icon: ShopRegIcons.idCard,
                  controller: controller.crNumberController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: 'رقم الهاتف',
                  hint: '5xxxxxxxx',
                  icon: ShopRegIcons.phone,
                  prefixText: '+966',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Obx(() => SelectField(
                      label: 'الموقع',
                      value: controller.selectedCity.value,
                      placeholder: 'اختر المدينة',
                      options: RegisterShopController.cityOptions,
                      icon: ShopRegIcons.locationPin,
                      onChanged: (v) => controller.selectedCity.value = v,
                    )),
                const SizedBox(height: 24),
                Obx(() => SelectField(
                      label: 'تصنيف المتجر',
                      value: controller.selectedCategory.value,
                      placeholder: 'اختر فئة المتجر',
                      options: RegisterShopController.categoryOptions,
                      onChanged: (v) => controller.selectedCategory.value = v,
                    )),
                Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: controller.selectedCategory.value != null
                          ? AiInsightCard(
                              key: ValueKey(controller.selectedCategory.value),
                              message:
                                  'لقد لاحظنا أنك تختار تصنيف "${controller.selectedCategory.value}"، المتاجر المشابهة في منطقتك تحقق مبيعات أعلى بنسبة 20% عند إضافة صور عالية الجودة للمنتجات الأساسية.',
                            )
                          : const SizedBox.shrink(),
                    )),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تصنيف المتجر',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.textBody,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => StoreSizeSelector(
                      options: RegisterShopController.storeSizes,
                      selected: controller.storeSize.value,
                      onSelected: controller.selectStoreSize,
                    )),
                const SizedBox(height: 24),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 192,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hero_illustration.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لنبدأ بتجهيز متجرك الإلكتروني الجديد في خطوات بسيطة.',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
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
          const RegistrationStepper(currentStep: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _MapPickerSection(),
                const SizedBox(height: 24),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ShopRegColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FigmaIcon(ShopRegIcons.businessBag, size: 20, color: ShopRegColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'بيانات العمل (الخطوة 2 من 3)',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ShopRegColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المحافظة والمدينة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.textBody,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                    const SizedBox(width: 8),
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
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
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

  Future<void> _autoLocate() async {
    setState(() => _locating = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _locating = false);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 288,
        decoration: BoxDecoration(
          color: ShopRegColors.mapPlaceholder,
          border: Border.all(color: ShopRegColors.inputBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/map_bg.png', fit: BoxFit.cover),
            ),
            const FigmaIcon(ShopRegIcons.mapPinLarge, size: 40),
            Positioned(
              bottom: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: InkWell(
                      onTap: _autoLocate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تحديد الموقع تلقائياً',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ShopRegColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _locating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ShopRegColors.primary,
                                    ),
                                  )
                                : const FigmaIcon(ShopRegIcons.gps, color: ShopRegColors.primary, size: 20),
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

  void _showSubmittedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تم إرسال الطلب بنجاح',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'سنقوم بمراجعة بياناتك والتواصل معك قريباً.',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).maybePop();
              },
              child: Text('تم', style: GoogleFonts.cairo(color: ShopRegColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'الخطوة الأخيرة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ShopRegColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '4 من 4',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ShopRegColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 6,
              color: const Color(0xFFECEEF0),
              child: const FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: 1,
                child: DecoratedBox(decoration: BoxDecoration(color: ShopRegColors.primary)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/badge_icon.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ShopRegColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: ShopRegColors.primary, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'ملخص البيانات',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ShopRegColors.textDark2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يرجى مراجعة كافة المعلومات المدخلة قبل إرسال الطلب لضمان سرعة المعالجة.',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.55,
                        color: ShopRegColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _ReviewSection(
                title: 'موقع النشاط',
                icon: ShopRegIcons.locationPin,
                onEdit: () => controller.currentStep.value = 2,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/map_bg.png',
                    height: 96,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 96,
                      color: ShopRegColors.mapPlaceholder,
                      child: const Icon(Icons.map_outlined, color: ShopRegColors.textMuted),
                    ),
                  ),
                ),
                rows: [
                  _ReviewRow(value: controller.displayAddress, label: 'العنوان'),
                ],
              ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Obx(() => _TermsRow(
                checked: controller.agreedToTerms.value,
                onChanged: (v) => controller.agreedToTerms.value = v ?? false,
              )),
          const SizedBox(height: 16),
          Obx(() => WizardFooter(
                continueLabel: 'إرسال الطلب',
                continueEnabled: controller.agreedToTerms.value,
                showBack: true,
                onBack: controller.previousStep,
                onContinue: () => _showSubmittedDialog(context),
              )),
          const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ShopRegColors.divider)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    FigmaIcon(icon, size: 18, color: ShopRegColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ShopRegColors.textDark2,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const FigmaIcon(ShopRegIcons.editPencil, size: 11, color: ShopRegColors.primary),
                  label: Text(
                    'تعديل',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500, color: ShopRegColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                if (leading != null) ...[
                  SizedBox(width: double.infinity, child: leading),
                  const SizedBox(height: 16),
                ],
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ShopRegColors.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: valueLtr ? TextAlign.left : TextAlign.right,
            textDirection: valueLtr ? TextDirection.ltr : TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 15,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: GoogleFonts.cairo(fontSize: 12, height: 1.9, color: ShopRegColors.textMuted),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'الشروط والأحكام',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: ShopRegColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' وأقر بصحة البيانات المدخلة أعلاه كجزء من عملية التسجيل كتاجر معتمد.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
