import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../screens/login_screen.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ApiClient _apiClient = ApiClient();

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

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: Replace with real endpoint
      /*
      final response = await _apiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await _apiClient.saveToken(token);
      */

      await Future.delayed(const Duration(seconds: 1));

      if (!GetUtils.isEmail(email)) {
        errorMessage.value = 'الرجاء إدخال بريد إلكتروني صحيح';
        return;
      }
      if (password.length < 6) {
        errorMessage.value = 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
        return;
      }

      debugPrint('Registered: $name <$email>');
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 350),
      );
    } catch (e) {
      errorMessage.value = 'حدث خطأ في الاتصال بالخادم';
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
