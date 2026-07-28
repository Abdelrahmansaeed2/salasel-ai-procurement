import 'package:get/get.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';

/// مركز التنقل — كل الـ controllers بتستخدمه عشان مفيش circular imports
class AppNavigator {
  AppNavigator._();

  /// index 0 → الرئيسية
  /// index 1 → المخزون
  /// index 2 → الطلبات
  /// index 3 → حسابي
  static void changeTab(int index, {required int currentTabIndex}) {
    // لو نفس الشاشة — مفيش حاجة
    if (index == currentTabIndex) return;

    if (index == 0) {
      // الرئيسية — ارجع للخلف لأن كل الشاشات مفتوحة فوق HomeScreen
      Get.back();
    } else if (index == 1) {
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
    }
  }
}
