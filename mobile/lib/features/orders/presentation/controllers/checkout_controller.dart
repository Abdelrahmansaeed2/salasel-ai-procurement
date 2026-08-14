import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../../core/network/api_client.dart';
import '../screens/receipt_success_screen.dart';

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

      if (selectedPaymentMethod.value == 'CreditCard') {
        // 1. Create Payment Intent
        final intentResponse = await _apiClient.dio.post('/payments/create-intent/$orderId');
        
        if (intentResponse.statusCode == 200) {
          final clientSecret = intentResponse.data['clientSecret'];

          // 2. Initialize Payment Sheet
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Salasel AI Procurement',
              appearance: const PaymentSheetAppearance(
                colors: PaymentSheetAppearanceColors(
                  primary: Color(0xFF004AC6),
                ),
              ),
            ),
          );

          // 3. Present Payment Sheet
          await Stripe.instance.presentPaymentSheet();
          
          // Payment successful! Webhook will update backend.
          Get.off(() => ReceiptSuccessScreen(orderId: orderId));
        } else {
          Get.snackbar('خطأ', 'تعذر تهيئة الدفع عبر البطاقة',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        // Cash on Delivery
        final response = await _apiClient.dio.post(
          '/orders/$orderId/payment',
          data: {
            'paymentMethod': 'CashOnDelivery',
            'paymentReference': 'REF-${DateTime.now().millisecondsSinceEpoch}',
          },
        );

        if (response.statusCode == 200) {
          Get.off(() => ReceiptSuccessScreen(orderId: orderId));
        } else {
          Get.snackbar('خطأ', 'فشلت عملية الدفع',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      if (e is StripeException) {
        debugPrint('Stripe error: ${e.error.localizedMessage}');
        Get.snackbar('خطأ', 'تم إلغاء أو فشل الدفع عبر البطاقة',
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        debugPrint('Checkout error: $e');
        Get.snackbar('خطأ', 'حدث خطأ أثناء معالجة الدفع',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isProcessing.value = false;
    }
  }
}

