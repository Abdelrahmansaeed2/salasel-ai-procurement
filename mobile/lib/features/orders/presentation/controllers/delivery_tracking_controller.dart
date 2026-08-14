import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/network/api_client.dart';
import '../screens/receipt_success_screen.dart';

class DeliveryTrackingController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final String orderId;

  DeliveryTrackingController({required this.orderId});
  
  final RxBool isLoading = true.obs;
  final RxBool isConfirming = false.obs;

  final Rxn<DateTime> acceptedAt = Rxn<DateTime>();
  final Rxn<DateTime> shippedAt = Rxn<DateTime>();
  final Rxn<DateTime> deliveredAt = Rxn<DateTime>();
  final Rxn<DateTime> receiptConfirmedAt = Rxn<DateTime>();

  final RxString driverName = ''.obs;
  final RxString driverPhone = ''.obs;
  final RxString estimatedDeliveryTime = ''.obs;
  final RxString supplierName = ''.obs;
  final RxString supplierStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTracking();
  }

  Future<void> fetchTracking() async {
    try {
      isLoading.value = true;
      final numericId = orderId.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _apiClient.dio.get('/orders/$numericId/tracking');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['acceptedAt'] != null) acceptedAt.value = DateTime.parse(data['acceptedAt']);
        if (data['shippedAt'] != null) shippedAt.value = DateTime.parse(data['shippedAt']);
        if (data['deliveredAt'] != null) deliveredAt.value = DateTime.parse(data['deliveredAt']);
        if (data['receiptConfirmedAt'] != null) receiptConfirmedAt.value = DateTime.parse(data['receiptConfirmedAt']);

        driverName.value = data['driverName'] ?? '';
        driverPhone.value = data['driverPhone'] ?? '';
        estimatedDeliveryTime.value = data['estimatedDeliveryTime'] ?? '';
        
        if (data['suppliers'] != null && data['suppliers'] is List && (data['suppliers'] as List).isNotEmpty) {
          final firstSupplier = data['suppliers'][0];
          supplierName.value = firstSupplier['name'] ?? 'المورد';
          supplierStatus.value = firstSupplier['status'] ?? 'جاري التوصيل';
        } else {
          supplierName.value = 'المورد';
          supplierStatus.value = 'جاري التوصيل';
        }
      }
    } catch (e) {
      debugPrint('Error fetching tracking: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmReceipt() async {
    try {
      isConfirming.value = true;
      final numericId = orderId.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _apiClient.dio.post('/orders/$numericId/confirm-receipt');
      if (response.statusCode == 200) {
        Get.offAll(() => ReceiptSuccessScreen(orderId: orderId));
      } else {
        Get.snackbar('خطأ', 'فشل تأكيد الاستلام');
      }
    } catch (e) {
      debugPrint('Error confirming receipt: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء التأكيد');
    } finally {
      isConfirming.value = false;
    }
  }

  int get currentStep {
    if (receiptConfirmedAt.value != null || deliveredAt.value != null) return 3;
    if (shippedAt.value != null) return 2;
    if (acceptedAt.value != null) return 1;
    return 0;
  }

  Future<void> callDriver() async {
    final phone = driverPhone.value.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) return;
    
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('خطأ', 'لا يمكن فتح تطبيق الاتصال');
    }
  }

  Future<void> whatsappDriver() async {
    final phone = driverPhone.value.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) return;

    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('خطأ', 'لا يمكن فتح واتساب');
    }
  }
}
