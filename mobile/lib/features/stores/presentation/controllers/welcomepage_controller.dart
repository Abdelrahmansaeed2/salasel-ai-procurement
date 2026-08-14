import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../../../features/orders/presentation/screens/orders_screen.dart';

class ShopModel {
  final int id;
  final String name;
  final String category;
  final String city;
  final bool isVerified;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.isVerified,
    required this.createdAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['merchantID'] ?? 0,
      name: json['shopName'] ?? 'متجر',
      category: json['category'] ?? 'عام',
      city: json['businessCity'] ?? 'مجهول',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class WelcomePageController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  RxInt currentIndex = 0.obs;
  RxString userName = 'تاجر'.obs;
  RxList<ShopModel> shops = <ShopModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final profileRes = await _apiClient.dio.get('/merchants/me');
      if (profileRes.statusCode == 200) {
        userName.value = profileRes.data['fullName'] ?? 'تاجر';
      }

      final shopsRes = await _apiClient.dio.get('/merchants/me/shops');
      if (shopsRes.statusCode == 200) {
        final List<dynamic> data = shopsRes.data;
        shops.value = data.map((j) => ShopModel.fromJson(j)).toList();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل بيانات المتاجر');
    } finally {
      isLoading.value = false;
    }
  }

  void setIndex(int index) {
    if (index == 0) {
      // Do nothing, already here
      currentIndex.value = 0;
    } else {
      Get.snackbar('مقفل مؤقتاً', 'ستُفتح هذه الميزة عند اكتمال توثيق السجل التجاري');
    }
  }
}
