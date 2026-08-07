import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
import '../screens/order_success_screen.dart';
import '../screens/delivery_tracking_screen.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxString selectedPaymentMethod = 'CreditCard'.obs;
  final RxBool isProcessing = false.obs;

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> processPayment(String orderId) async {
    if (orderId.isEmpty) return;

    try {
      isProcessing.value = true;
      final response = await _apiClient.dio.post(
        '/orders/$orderId/payment',
        data: {
          'paymentMethod': selectedPaymentMethod.value,
          'paymentReference': 'REF-${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (response.statusCode == 200) {
        Get.off(() => DeliveryTrackingScreen(orderId: orderId));
      } else {
        Get.snackbar('خطأ', 'فشلت عملية الدفع',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء معالجة الدفع',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}
