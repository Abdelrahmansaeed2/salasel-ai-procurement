import 'package:get/get.dart';
import '../../../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../../../features/orders/presentation/screens/orders_screen.dart';

class WelcomePageController extends GetxController {
  RxInt currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
    if (index == 1) {
      Get.to(() => const InventoryScreen(), transition: Transition.fadeIn);
      currentIndex.value = 0;
    } else if (index == 2) {
      Get.to(() => const OrdersScreen(), transition: Transition.fadeIn);
      currentIndex.value = 0;
    }
  }
}
