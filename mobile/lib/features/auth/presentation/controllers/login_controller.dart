import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart' as cp;
import '../screens/otp_screen.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  
  RxBool hasText = false.obs;
  RxBool isFocused = false.obs;
  
  final Rx<cp.Country> selectedCountry = cp.Country(
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
  ).obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final textExists = phoneController.text.trim().isNotEmpty;
    if (textExists != hasText.value) {
      hasText.value = textExists;
    }
  }

  void setFocus(bool focused) {
    isFocused.value = focused;
  }

  void updateCountry(cp.Country country) {
    selectedCountry.value = country;
  }

  void submitLogin() {
    if (hasText.value) {
      Get.to(
        () => OtpScreen(phoneNumber: phoneController.text),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 350),
      );
    }
  }

  @override
  void onClose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    super.onClose();
  }
}
