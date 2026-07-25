import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/stores/presentation/screens/welcomepage_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';

class LoginController extends GetxController {
  static const String welcomeEmail = 'welcome@salasel.com';
  static const String welcomePassword = '123456';
  static const String homeEmail = 'home@salasel.com';
  static const String homePassword = '123456';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool hasText = false.obs;
  RxBool isFocused = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onTextChanged);
    passwordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final textExists = emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty;
    if (textExists != hasText.value) {
      hasText.value = textExists;
    }
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  void setFocus(bool focused) {
    isFocused.value = focused;
  }

  void submitLogin() {
    if (!hasText.value) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email == welcomeEmail && password == welcomePassword) {
      Get.offAll(
        () => const StoresScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 350),
      );
    } else if (email == homeEmail && password == homePassword) {
      Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 350),
      );
    } else {
      errorMessage.value = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
  }

  @override
  void onClose() {
    emailController.removeListener(_onTextChanged);
    passwordController.removeListener(_onTextChanged);
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
