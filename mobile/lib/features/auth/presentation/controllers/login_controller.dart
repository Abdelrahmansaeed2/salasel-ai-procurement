import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/stores/presentation/screens/welcomepage_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../core/network/api_client.dart';
import '../screens/register_screen.dart';
import '../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  static const String welcomeEmail = 'welcome@salasel.com';
  static const String welcomePassword = '123456';
  static const String homeEmail = 'home@salasel.com';
  static const String homePassword = '123456';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final AuthRepository _authRepository = AuthRepository();

  RxBool hasText = false.obs;
  RxBool isFocused = false.obs;
  RxBool isLoading = false.obs;
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

  Future<void> submitLogin() async {
    if (!hasText.value || isLoading.value) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authResponse = await _authRepository.login(email, password);
      
      if (authResponse.isSetupCompleted) {
        Get.offAll(
          () => HomeScreen(),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 350),
        );
      } else {
        Get.offAll(
          () => StoresScreen(),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 350),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.off(
      () => const RegisterScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
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
