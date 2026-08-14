import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/network/api_client.dart';

class VerificationStep {
  final String title;
  final String subtitle;
  final VerificationStepStatus status;

  VerificationStep({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

enum VerificationStepStatus { done, pending, upcoming }

class ProfileController extends GetxController {
  final RxInt bottomNavIndex = 3.obs;

  final RxBool businessHoursEnabled = true.obs;

  final ApiClient _apiClient = ApiClient();
  final RxBool isLoading = true.obs;

  final RxString storeName = ''.obs;
  final RxString storeLocation = ''.obs;
  final RxString storeCategory = ''.obs;
  final RxString commercialRegisterNumber = ''.obs;
  final RxString storeAddress = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString email = ''.obs;
  final RxString ownerName = ''.obs;

  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;

  final RxString verificationStatus = 'NotSubmitted'.obs;

  final RxList<VerificationStep> verificationSteps = <VerificationStep>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  int? currentShopId;

  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      // Fetch user profile (email, phone, name)
      final userResp = await _apiClient.dio.get('/merchants/me');
      if (userResp.statusCode == 200) {
        email.value = userResp.data['email'] ?? '';
        ownerName.value = userResp.data['fullName'] ?? '';
      }

      // Fetch shops
      final shopsResp = await _apiClient.dio.get('/merchants/me/shops');
      if (shopsResp.statusCode == 200 && (shopsResp.data as List).isNotEmpty) {
        final shop = shopsResp.data[0];
        currentShopId = shop['merchantID'];
        storeName.value = shop['shopName'] ?? '';
        storeLocation.value = '${shop['businessCity'] ?? ''}، ${shop['governorate'] ?? ''}';
        storeCategory.value = shop['category'] ?? '';
        commercialRegisterNumber.value = shop['crNumber'] ?? '';
        storeAddress.value = shop['address'] ?? '';
        phoneNumber.value = shop['contactPhone'] ?? '';

        final latStr = shop['locationLat'];
        final lngStr = shop['locationLng'];
        if (latStr != null && latStr.toString().isNotEmpty) {
          lat.value = double.tryParse(latStr.toString()) ?? 0.0;
        }
        if (lngStr != null && lngStr.toString().isNotEmpty) {
          lng.value = double.tryParse(lngStr.toString()) ?? 0.0;
        }

        verificationStatus.value = shop['verificationStatus'] ?? 'NotSubmitted';

        final isVerified = shop['isVerified'] == true;
        
        verificationSteps.value = [
          VerificationStep(
            title: 'تأكيد رقم الهاتف',
            subtitle: phoneNumber.value.isNotEmpty ? 'تم التحقق' : 'قيد الانتظار',
            status: phoneNumber.value.isNotEmpty ? VerificationStepStatus.done : VerificationStepStatus.pending,
          ),
          VerificationStep(
            title: 'السجل التجاري (CR)',
            subtitle: isVerified ? 'تم التحقق' : 'قيد التدقيق من قبل الفريق المختص',
            status: isVerified ? VerificationStepStatus.done : VerificationStepStatus.pending,
          ),
          VerificationStep(
            title: 'توثيق المنشأة',
            subtitle: isVerified ? 'مكتمل' : 'مرحلة قادمة',
            status: isVerified ? VerificationStepStatus.done : VerificationStepStatus.upcoming,
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? newShopName,
    String? newAddress,
    String? newPhone,
  }) async {
    if (currentShopId == null) return false;
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.put('/merchants/me/shops/$currentShopId', data: {
        'shopName': newShopName ?? storeName.value,
        'address': newAddress ?? storeAddress.value,
        'contactPhone': newPhone ?? phoneNumber.value,
      });

      if (response.statusCode == 200) {
        // Refresh local data
        await fetchProfileData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBusinessHours() {
    businessHoursEnabled.value = !businessHoursEnabled.value;
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 3);
  }

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.delete('/users/me');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
