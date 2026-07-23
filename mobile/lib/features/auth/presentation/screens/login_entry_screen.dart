import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart' as cp;
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'otp_screen.dart';


class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final hasText = _phoneController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

               
                const _SalaselLogo(),

                const SizedBox(height: 36),

                const _WelcomeSection(),

                const SizedBox(height: 32),

                _PhoneFieldSection(controller: _phoneController),

                const SizedBox(height: 24),

                
                _ContinueButton(
                  enabled: _hasText,
                  onPressed: _hasText
                      ? () {
                          Navigator.of(context).push(
                            PageRouteBuilder<void>(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      OtpScreen(
                                        phoneNumber: _phoneController.text,
                                      ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                            ),
                          );
                        }
                      : null,
                ),

                const SizedBox(height: 20),

            
                const _OrDivider(),

                const SizedBox(height: 20),

                
                const _WhatsAppButton(),

                const SizedBox(height: 48),

               
                const _FeatureRow(),

                const SizedBox(height: 32),

                const _FooterTerms(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _SalaselLogo extends StatelessWidget {
  const _SalaselLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/salasel_logo.png',
        width: 140,
        height: 94,
        fit: BoxFit.contain,
      ),
    );
  }
}


class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👋', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'أهلاً بك',
                style: AppTextStyles.welcomeTitle,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle – Centered Arabic text
        Text(
          'أدخل رقم هاتفك لتسجيل الدخول أو إنشاء حساب',
          style: AppTextStyles.welcomeSubtitle,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}


class _PhoneFieldSection extends StatelessWidget {
  const _PhoneFieldSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
       
        Text(
          'رقم الهاتف',
          style: AppTextStyles.fieldLabel,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        _PhoneInputField(controller: controller),
      ],
    );
  }
}


final cp.Country _initialCountry = cp.Country(
  phoneCode: '966',
  countryCode: 'SA',
  e164Sc: 966,
  geographic: true,
  level: 1,
  name: 'Saudi Arabia',
  example: '512345678',
  displayName: 'Saudi Arabia (SA) [+966]',
  displayNameNoCountryCode: 'Saudi Arabia',
  e164Key: '966-SA-0',
);

class _PhoneInputField extends StatefulWidget {
  const _PhoneInputField({required this.controller});

  final TextEditingController controller;

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  bool _isFocused = false;
  cp.Country _selectedCountry = _initialCountry;

  void _showCountryPicker() {
    cp.showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['SA', 'EG'], // Put Saudi and Egypt at top
      onSelect: (cp.Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      countryListTheme: cp.CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        backgroundColor: Colors.white,
        textStyle: AppTextStyles.fieldValue,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.70,
        searchTextStyle: AppTextStyles.fieldValue,
        inputDecoration: InputDecoration(
          hintText: 'ابحث عن دولة أو رمز الاتصال...',
          hintStyle: AppTextStyles.fieldHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
       
            _CountryCodeBox(
              country: _selectedCountry,
              onTap: _showCountryPicker,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: _isFocused ? AppColors.borderFocused : AppColors.border,
                    width: _isFocused ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: widget.controller,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 9,
                  decoration: InputDecoration(
                    hintText: '5X XXX XXXX',
                    hintStyle: AppTextStyles.fieldHint.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 16,
                    letterSpacing: 1.5,
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

/// The separate Country Code Box on the right side.
class _CountryCodeBox extends StatelessWidget {
  const _CountryCodeBox({
    required this.country,
    required this.onTap,
  });

  final cp.Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Directionality(
          // LTR flow inside the box: [Flag] -> [DialCode] -> [Arrow]
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Country Flag
              Text(
                country.flagEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              // Dial code text
              Text(
                '+${country.phoneCode}',
                style: AppTextStyles.dialCode.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              // Dropdown Arrow
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.disabled,
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              'متابعة',
              style: enabled
                  ? AppTextStyles.primaryButton
                  : AppTextStyles.primaryButtonDisabled,
            ),
          ),
        ),
      ),
    );
  }
}


class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو سجل دخولك عبر',
            style: AppTextStyles.dividerLabel,
            textDirection: TextDirection.rtl,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text (on the right in RTL)
                Text(
                  'تسجيل عبر واتساب',
                  style: AppTextStyles.whatsappButton.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                // WhatsApp icon (on the left in RTL)
                SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  static const _features = [
    _FeatureItem(
      icon: Icons.local_shipping_outlined,
      label: 'شبكة موردين\nسريعة',
    ),
    _FeatureItem(
      icon: Icons.add_circle_outline_rounded,
      label: 'طلب بالذكاء\nالاصطناعي',
    ),
    _FeatureItem(
      icon: Icons.verified_user_outlined,
      label: 'تسجيل آمن',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _features.map((f) => _FeatureCard(item: f)).toList(),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: AppTextStyles.featureLabel,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}



class _FooterTerms extends StatelessWidget {
  const _FooterTerms();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Line 1 – centered label
        Text(
          'بالمتابعة، أنت توافق على',
          style: AppTextStyles.footerBody,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 6),
        // Line 2 – centered links with underline
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'سياسة الخصوصية',
                  style: AppTextStyles.footerLink.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'و',
                  style: AppTextStyles.footerBody,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'شروط الاستخدام',
                  style: AppTextStyles.footerLink.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
