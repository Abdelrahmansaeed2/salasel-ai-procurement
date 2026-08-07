import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';

class RegisterShopController extends GetxController {
  static const List<String> storeSizes = ['كبير', 'متوسط', 'صغير'];
  static const List<String> cityOptions = ['الرياض', 'جدة', 'الدمام', 'مكة المكرمة'];
  static const List<String> categoryOptions = ['بقالة', 'مطاعم ومقاهي', 'أزياء وملابس', 'إلكترونيات'];
  static const List<String> governorateOptions = ['الجيزة', 'القاهرة', 'الإسكندرية'];
  static const List<String> businessCityOptions = ['مصر', 'السعودية', 'الإمارات'];

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final crNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final Rx<String?> selectedCity = Rx<String?>(null);
  final Rx<String?> selectedCategory = Rx<String?>(null);
  final RxString storeSize = 'صغير'.obs;
  void selectStoreSize(String size) => storeSize.value = size;

  final Rx<String?> governorate = Rx<String?>('الجيزة');
  final Rx<String?> businessCity = Rx<String?>('مصر');
  
  final RxDouble locationLat = 24.7136.obs;
  final RxDouble locationLng = 46.6753.obs;

  final RxBool agreedToTerms = false.obs;

  static const int totalSteps = 3;
  final RxInt currentStep = 1.obs;

  void nextStep() {
    if (currentStep.value < totalSteps) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  String get displayShopName =>
      shopNameController.text.isNotEmpty ? shopNameController.text : 'متجر الأناقة الحديثة';
  String get displayCategory => selectedCategory.value ?? 'تجارة التجزئة';
  String get displayCrNumber =>
      crNumberController.text.isNotEmpty ? crNumberController.text : '1010XXXX99';
  String get displayAddress =>
      addressController.text.isNotEmpty ? addressController.text : 'الرياض، حي الملقا';
  String get displayOwnerName =>
      ownerNameController.text.isNotEmpty ? ownerNameController.text : 'أحمد بن فهد بن محمد';
  String get displayOwnerId => '109XXXX882';
  String get displayGovernorate => governorate.value ?? 'الجيزة';
  String get displayBusinessCity => businessCity.value ?? 'مصر';
  String get displayStoreSize => storeSize.value;
  String get displayOwnerPhone =>
      phoneController.text.isNotEmpty ? '+966 ${phoneController.text}' : '+966 5X XXX XXXX';

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    crNumberController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<bool> submitRegistration() async {
    try {
      final apiClient = ApiClient();
      await apiClient.dio.post('/merchants/register-shop', data: {
        "shopName": shopNameController.text,
        "ownerName": ownerNameController.text,
        "crNumber": crNumberController.text,
        "ownerIdentityNumber": "0000000000", // Dummy to bypass UI requirement
        "contactPhone": phoneController.text,
        "category": selectedCategory.value ?? "Retail",
        "storeSize": storeSize.value,
        "governorate": governorate.value ?? "N/A",
        "businessCity": businessCity.value ?? "N/A",
        "address": addressController.text,
        "locationLat": locationLat.value,
        "locationLng": locationLng.value
      });
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل المتجر: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }
}
