import 'package:get/get.dart';
import '../../../../../core/network/api_client.dart';
import '../../data/models/order_detail_model.dart';

class VoiceOrderDetailController extends GetxController {
  final int orderId;
  final ApiClient _apiClient = ApiClient();

  final Rx<OrderDetailModel?> order = Rx<OrderDetailModel?>(null);
  final RxBool isLoading = true.obs;
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
}
