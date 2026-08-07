import 'package:get/get.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/network/api_client.dart';
import '../data/models/home_models.dart';

class QuickStat {
  final String label;
  final String value;
  QuickStat({required this.label, required this.value});
}

class RecentOrder {
  final String emoji;
  final String supplier;
  final String items;
  final String status;
  final bool isDelivered;
  final String time;
  RecentOrder({
    required this.emoji,
    required this.supplier,
    required this.items,
    required this.status,
    required this.isDelivered,
    required this.time,
  });
}

class HomeController extends GetxController {
  final RxInt bottomNavIndex = 0.obs;

  final Rx<DashboardStatsModel?> dashboardStats = Rx<DashboardStatsModel?>(null);
  final RxList<AiAlertModel> aiAlerts = <AiAlertModel>[].obs;
  final RxList<RecentOrder> recentOrders = <RecentOrder>[].obs;
  
  final RxBool isLoading = true.obs;
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      
      // 1. Fetch Dashboard Stats
      final statsResponse = await _apiClient.dio.get('/merchants/me/dashboard');
      if (statsResponse.statusCode == 200) {
        dashboardStats.value = DashboardStatsModel.fromJson(statsResponse.data);
      }

      // 2. Fetch User's Primary Shop to get the merchantId
      final shopsResponse = await _apiClient.dio.get('/merchants/me/shops');
      int? merchantId;
      if (shopsResponse.statusCode == 200) {
        final List<dynamic> shops = shopsResponse.data;
        if (shops.isNotEmpty) {
          merchantId = shops.first['merchantID'];
        }
      }

      // 3. Fetch AI Alerts (Using dynamic merchantId)
      if (merchantId != null) {
        final aiResponse = await _apiClient.dio.get(
          '/ai/predictions/out-of-stock',
          queryParameters: {'merchantId': merchantId},
        );
        if (aiResponse.statusCode == 200) {
          final List<dynamic> data = aiResponse.data;
          aiAlerts.value = data.map((json) => AiAlertModel.fromJson(json)).toList();
        }
      }

      // 4. Fetch Recent Orders
      final ordersResponse = await _apiClient.dio.get(
        '/merchants/me/recent-orders',
        queryParameters: {'take': 5},
      );
      if (ordersResponse.statusCode == 200) {
        final List<dynamic> ordersData = ordersResponse.data;
        recentOrders.value = ordersData.map((json) => RecentOrder(
          emoji: '📦',
          supplier: json['supplierName'] ?? 'مورد',
          items: 'طلب رقم #${json['orderId'] ?? ''}',
          status: json['status'] ?? 'جديد',
          isDelivered: json['status'] == 'Completed',
          time: 'الآن',
        )).toList();
      }

    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل بيانات لوحة القيادة');
    } finally {
      isLoading.value = false;
    }
  }

  List<QuickStat> get quickStats {
    if (dashboardStats.value == null) return [];
    return [
      QuickStat(label: 'تنبيه نقص المخزون', value: aiAlerts.length.toString()),
      QuickStat(label: 'طلبات قيد التوصيل', value: dashboardStats.value!.activeDeliveries.toString()),
      QuickStat(label: 'بانتظار الاعتماد', value: dashboardStats.value!.pendingApprovals.toString()),
    ];
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 0);
  }
}
