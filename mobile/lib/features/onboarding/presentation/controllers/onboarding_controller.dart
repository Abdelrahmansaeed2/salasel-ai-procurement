import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static const int totalPages = 2;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void next() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      finish();
    }
  }

  void back() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Get.back();
    }
  }

  void onPageChanged(int index) => currentPage.value = index;

  void skip() => Get.back();

  void finish() => Get.back();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
