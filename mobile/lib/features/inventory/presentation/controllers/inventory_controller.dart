import 'package:get/get.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/network/api_client.dart';
import '../../data/models/inventory_models.dart';

class InventoryController extends GetxController {
  final RxInt bottomNavIndex = 1.obs;
  
  final List<String> filters = ['الكل', 'بقالة', 'حبوب', 'منظفات', 'حلويات'];
  final RxString selectedFilter = 'الكل'.obs;

  final RxBool showAiInsights = false.obs;
  final RxString searchText = ''.obs;
  final RxBool isLoading = true.obs;

  final RxList<InventoryItemModel> products = <InventoryItemModel>[].obs;
  final RxList<AiRecommendationModel> aiRecommendations = <AiRecommendationModel>[].obs;
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    try {
      isLoading.value = true;
      
      // 1. Fetch User's Primary Shop to get the merchantId
      final shopsResponse = await _apiClient.dio.get('/merchants/me/shops');
      int? merchantId;
      if (shopsResponse.statusCode == 200) {
        final List<dynamic> shops = shopsResponse.data;
        if (shops.isNotEmpty) {
          merchantId = shops.first['merchantID'];
        }
      }

      if (merchantId == null) {
        throw Exception('No shop found');
      }

      // 2. Fetch Inventory
      final invResponse = await _apiClient.dio.get(
        '/inventory',
        queryParameters: {'merchantId': merchantId},
      );

      if (invResponse.statusCode == 200) {
        final Map<String, dynamic> data = invResponse.data;
        final List<dynamic> items = data['items'] ?? [];
        products.value = items.map((json) => InventoryItemModel.fromJson(json)).toList();
      }

      // 3. Fetch AI Recommendations
      final aiResponse = await _apiClient.dio.get(
        '/ai/recommendations',
        queryParameters: {'merchantId': merchantId},
      );

      if (aiResponse.statusCode == 200) {
        final List<dynamic> data = aiResponse.data;
        aiRecommendations.value = data.map((json) => AiRecommendationModel.fromJson(json)).toList();
        
        if (aiRecommendations.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 600), () {
            showAiInsights.value = true;
          });
        }
      }

    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المخزون');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(int inventoryId, int currentQty, int delta) async {
    final newQty = currentQty + delta;
    if (newQty < 0) return;

    try {
      final response = await _apiClient.dio.put(
        '/inventory/$inventoryId/quantity',
        data: {'quantity': newQty},
      );

      if (response.statusCode == 200) {
        // Optimistically update UI
        final index = products.indexWhere((p) => p.inventoryId == inventoryId);
        if (index != -1) {
          final p = products[index];
          products[index] = InventoryItemModel(
            inventoryId: p.inventoryId,
            productId: p.productId,
            productName: p.productName,
            sku: p.sku,
            category: p.category,
            currentQty: newQty,
            maxQty: p.maxQty,
            reorderThreshold: p.reorderThreshold,
            status: p.status,
            unitOfMeasure: p.unitOfMeasure,
            imageUrl: p.imageUrl,
          );
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث الكمية');
    }
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 1);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSearchText(String text) {
    searchText.value = text;
  }

  List<InventoryItemModel> get filteredProducts {
    final query = searchText.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return products.where((p) {
      final matchesFilter = filter == 'الكل' || p.category == filter;
      final matchesSearch = query.isEmpty ||
          p.productName.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }
  
  void dismissAiInsights() {
    showAiInsights.value = false;
  }

  int get highStockCount => products.where((p) => p.status != 'منخفض جداً' && p.status != 'منخفض' && p.status != 'متوفر').length;
  int get goodStockCount => products.where((p) => p.status == 'متوفر').length;
  int get lowStockCount => products.where((p) => p.status == 'منخفض').length;
  int get criticalStockCount => products.where((p) => p.status == 'منخفض جداً').length;
}
