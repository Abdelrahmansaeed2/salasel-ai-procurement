import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// مركز التنقل — كل الـ controllers بتستخدمه عشان مفيش circular imports
class AppNavigator {
  AppNavigator._();

  /// index 0 → الرئيسية
  /// index 1 → المخزون
  /// index 2 → الطلبات
  /// index 3 → حسابي
  static void changeTab(int index, {required int currentTabIndex}) {
    if (index == currentTabIndex) {
      Get.until((route) => route.isFirst);
      if (index == 0) return;
    } else {
      Get.until((route) => route.isFirst);
    }

    if (index == 1) {
      Get.to(
        () => const InventoryScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      );
    } else if (index == 2) {
      Get.to(
        () => const OrdersScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      );
    } else if (index == 3) {
      Get.to(
        () => const ProfileScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 200),
      );
    }
  }
}