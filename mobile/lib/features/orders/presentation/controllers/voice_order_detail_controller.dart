import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../data/models/order_detail_model.dart';

class VoiceOrderDetailController extends GetxController {
  final int orderId;
  final ApiClient _apiClient = ApiClient();

  final Rx<OrderDetailModel?> order = Rx<OrderDetailModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isConfirming = false.obs;
  final RxBool isCancelling = false.obs;
  final RxString error = ''.obs;

  VoiceOrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiClient.dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        order.value = OrderDetailModel.fromJson(response.data);
      } else {
        error.value = 'فشل في تحميل تفاصيل الطلب';
      }
    } catch (e) {
      error.value = 'حدث خطأ أثناء الاتصال بالخادم';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmOrder() async {
    if (isConfirming.value) return;
    try {
      isConfirming.value = true;
      // VoiceOrdersController is at /api/voice-orders (no /v1 prefix)
      final baseWithoutV1 = ApiClient.baseUrl.replaceAll('/v1', '');
      final response = await _apiClient.dio.put(
        '$baseWithoutV1/voice-orders/$orderId/confirm',
        options: Options(headers: _apiClient.dio.options.headers),
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          'تم التأكيد',
          'تم تأكيد الطلب وإرساله للمورد',
          backgroundColor: const Color(0xFF2563EB),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        // Refresh order to get updated status
        await fetchOrderDetails();
      } else {
        Get.snackbar('خطأ', 'فشل في تأكيد الطلب', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isConfirming.value = false;
    }
  }

  Future<void> cancelOrder() async {
    if (isCancelling.value) return;
    try {
      isCancelling.value = true;
      // VoiceOrdersController is at /api/voice-orders (no /v1 prefix)
      final baseWithoutV1 = ApiClient.baseUrl.replaceAll('/v1', '');
      final response = await _apiClient.dio.put(
        '$baseWithoutV1/voice-orders/$orderId/cancel',
        options: Options(headers: _apiClient.dio.options.headers),
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء الطلب',
          backgroundColor: const Color(0xFFBA1A1A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.back();
      } else {
        Get.snackbar('خطأ', 'فشل في إلغاء الطلب', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCancelling.value = false;
    }
  }
}

