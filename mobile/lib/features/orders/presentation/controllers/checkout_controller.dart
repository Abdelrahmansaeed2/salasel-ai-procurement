import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTokeniseType.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkApms.dart';
import '../../../../../core/network/api_client.dart';
import '../screens/receipt_success_screen.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxString selectedPaymentMethod = 'credit_card'.obs;
  final RxBool isProcessing = false.obs;

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> processPayment(String orderId) async {
    if (orderId.isEmpty) return;

    try {
      isProcessing.value = true;

      if (selectedPaymentMethod.value == 'credit_card') {
        // 1. Create Payment Intent
        final baseWithoutV1 = ApiClient.baseUrl.replaceAll('/v1', '');
        final intentResponse = await _apiClient.dio.post('$baseWithoutV1/payments/create-intent/$orderId');
        
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
              billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
                address: AddressCollectionMode.never,
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
      } else if (selectedPaymentMethod.value == 'paytabs_installments') {
        var billingDetails = BillingDetails(
            "Customer Name", "email@example.com", "+201000000000",
            "Cairo", "eg", "Cairo", "Cairo", "12345");
        
        var configuration = PaymentSdkConfigurationDetails(
            profileId: "154061",
            serverKey: "S9J9WJHHJW-J9LBJJ2KM6-BRZNHGHNHR",
            clientKey: "C7K2G9-V6BM6P-B266MK-KPDNBQ",
            cartId: orderId,
            cartDescription: "Salasel Order $orderId",
            merchantName: "Salasel Test",
            screentTitle: "الدفع بالتقسيط",
            amount: 100.0, // Hardcoded for test
            showBillingInfo: false,
            forceShippingInfo: false,
            currencyCode: "EGP",
            merchantCountryCode: "EG",
            billingDetails: billingDetails,
            alternativePaymentMethods: [PaymentSdkAPms.VALU] // Trigger ValU specifically
        );

        FlutterPaytabsBridge.startAlternativePaymentMethod(configuration, (event) {
          isProcessing.value = false;
          if (event["status"] == "success") {
            Get.off(() => ReceiptSuccessScreen(orderId: orderId));
          } else if (event["status"] == "error") {
            Get.snackbar('خطأ', 'فشلت عملية الدفع بالتقسيط: ${event["message"]}',
                backgroundColor: Colors.red, colorText: Colors.white);
          } else if (event["status"] == "event") {
            // Cancelled
          }
        });
        
        // Return early because the callback handles completion
        return;
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
