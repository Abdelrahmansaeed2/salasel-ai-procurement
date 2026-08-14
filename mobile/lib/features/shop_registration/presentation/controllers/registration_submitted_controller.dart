import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';

class RegistrationSubmittedController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxBool isLoading = true.obs;
  final RxString submissionDate = ''.obs;
  final RxString verificationStatus = 'Pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShopStatus();
  }

  Future<void> fetchShopStatus() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/merchants/me/shops');
      
      if (response.statusCode == 200) {
        final List<dynamic> shops = response.data ?? [];
        if (shops.isNotEmpty) {
          final shop = shops.first;
          
          final String rawDate = shop['createdAt'] ?? '';
          if (rawDate.isNotEmpty) {
            final DateTime parsedDate = DateTime.parse(rawDate).toLocal();
            // Format to Arabic date, e.g. 28 يونيو 2024
            submissionDate.value = DateFormat('d MMMM yyyy', 'ar').format(parsedDate);
          }
          
          verificationStatus.value = shop['verificationStatus'] ?? 'Pending';
        }
      }
    } catch (e) {
      // Keep defaults if failed
    } finally {
      isLoading.value = false;
    }
  }
}
