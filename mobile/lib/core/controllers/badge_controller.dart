import 'package:get/get.dart';
import '../network/api_client.dart';

class BadgeController extends GetxController {
  final RxInt inventoryBadge = 0.obs;
  final RxInt ordersBadge = 0.obs;
  
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    fetchBadges();
  }

  Future<void> fetchBadges() async {
    try {
      // 1. Fetch Orders Badge (Pending Approvals)
      final statsResponse = await _apiClient.dio.get('/merchants/me/dashboard');
      if (statsResponse.statusCode == 200) {
        ordersBadge.value = statsResponse.data['pendingApprovals'] ?? 0;
      }

      // 2. Fetch Inventory Badge (Out of stock alerts)
      final shopsResponse = await _apiClient.dio.get('/merchants/me/shops');
      if (shopsResponse.statusCode == 200) {
        final List<dynamic> shops = shopsResponse.data;
        if (shops.isNotEmpty) {
          final merchantId = shops.first['merchantID'];
          final aiResponse = await _apiClient.dio.get(
            '/ai/predictions/out-of-stock',
            queryParameters: {'merchantId': merchantId},
          );
          if (aiResponse.statusCode == 200) {
            final List<dynamic> alerts = aiResponse.data;
            inventoryBadge.value = alerts.length;
          }
        }
      }
    } catch (e) {
      // Silently fail for badges
    }
  }
}
