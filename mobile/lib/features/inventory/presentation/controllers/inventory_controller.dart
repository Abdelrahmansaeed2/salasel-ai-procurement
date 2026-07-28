import 'package:get/get.dart';
import '../../../../../core/navigation/app_navigator.dart';

class InventoryProduct {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String unit;
  final int currentStock;
  final int maxStock;
  final String status;
  final String imageUrl;

  InventoryProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.unit,
    required this.currentStock,
    required this.maxStock,
    required this.status,
    required this.imageUrl,
  });

  double get stockPercentage => currentStock / maxStock;
}

class InventoryController extends GetxController {
  final RxInt bottomNavIndex = 1.obs;
  
  final List<String> filters = ['الكل', 'بقالة', 'حبوب', 'منظفات', 'حلويات'];
  final RxString selectedFilter = 'الكل'.obs;

  final RxBool showAiInsights = false.obs;
  final RxString searchText = ''.obs;

  final List<InventoryProduct> products = [
    InventoryProduct(
      id: '1',
      name: 'أرز الشعلان 10 كجم',
      category: 'حبوب', 
      sku: 'WTR-001',
      unit: 'كرتون',
      currentStock: 8,
      maxStock: 100,
      status: 'منخفض جداً',
      imageUrl: 'assets/images/rice.jpg',
    ),
    InventoryProduct(
      id: '2',
      name: 'سكر الأسرة 5 كجم',
      category: 'بقالة',
      sku: 'SGR-004',
      unit: 'طرد',
      currentStock: 5,
      maxStock: 40,
      status: 'منخفض',
      imageUrl: 'assets/images/sugar.jpg',
    ),
    InventoryProduct(
      id: '3',
      name: 'حليب نادك',
      category: 'ألبان',
      sku: 'MLK-005',
      unit: 'علبة',
      currentStock: 45,
      maxStock: 80,
      status: 'متوفر',
      imageUrl: 'assets/images/milk.jpg',
    ),
    InventoryProduct(
      id: '4',
      name: 'مسحوق غسيل تايد',
      category: 'منظفات',
      sku: 'SOP-011',
      unit: 'علبة',
      currentStock: 130,
      maxStock: 150,
      status: 'مرتفع',
      imageUrl: 'assets/images/tide.jpg',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Show AI insights after a short delay to simulate it popping up
    Future.delayed(const Duration(milliseconds: 600), () {
      showAiInsights.value = true;
    });
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

  List<InventoryProduct> get filteredProducts {
    final query = searchText.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return products.where((p) {
      final matchesFilter = filter == 'الكل' || p.category == filter;
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }
  
  void dismissAiInsights() {
    showAiInsights.value = false;
  }
}
