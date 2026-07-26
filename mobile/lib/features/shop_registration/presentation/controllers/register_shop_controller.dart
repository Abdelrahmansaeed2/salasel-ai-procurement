import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  final Rx<String?> governorate = Rx<String?>('الجيزة');
  final Rx<String?> businessCity = Rx<String?>('مصر');

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
  String get displayOwnerPhone =>
      phoneController.text.isNotEmpty ? '+966 ${phoneController.text}' : '+966 5X XXX XXXX';

  void selectStoreSize(String size) => storeSize.value = size;

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    crNumberController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
