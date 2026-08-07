import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../screens/login_screen.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  RxBool hasText = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_onTextChanged);
    emailController.addListener(_onTextChanged);
    passwordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final textExists = nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
    if (textExists != hasText.value) {
      hasText.value = textExists;
    }
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  Future<void> submitRegister() async {
    if (!hasText.value || isLoading.value) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'الرجاء إدخال بريد إلكتروني صحيح';
      return;
    }
    if (password.length < 6) {
      errorMessage.value = 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authRepository.register(
        fullName: name,
        email: email,
        password: password,
      );

      Get.snackbar(
        'نجاح',
        'تم تسجيل الحساب بنجاح. الرجاء تسجيل الدخول.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint('Registered: $name <$email>');
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 350),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.off(
      () => const LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void onClose() {
    nameController.removeListener(_onTextChanged);
    emailController.removeListener(_onTextChanged);
    passwordController.removeListener(_onTextChanged);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
