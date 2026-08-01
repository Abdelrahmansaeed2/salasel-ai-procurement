import 'package:get/get.dart';

import '../../../../core/navigation/app_navigator.dart';

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

  final String storeName = 'بقالة أحمد';
  final String storeLocation = 'القاهرة، مصر';
  final String storeCategory = 'أغذية ومشروبات';
  final String commercialRegisterNumber = '1010******45';
  final String storeAddress = 'شارع المعز، القاهرة';
  final String phoneNumber = '966 50 *** 4567';
  final String email = 'contact@ahmedshop.com';

  final List<VerificationStep> verificationSteps = [
    VerificationStep(
      title: 'تأكيد رقم الهاتف',
      subtitle: 'تم التحقق في 12 أكتوبر 2023',
      status: VerificationStepStatus.done,
    ),
    VerificationStep(
      title: 'السجل التجاري (CR)',
      subtitle: 'قيد التدقيق من قبل الفريق المختص',
      status: VerificationStepStatus.pending,
    ),
    VerificationStep(
      title: 'توثيق المنشأة',
      subtitle: 'مرحلة قادمة',
      status: VerificationStepStatus.upcoming,
    ),
  ];

  void toggleBusinessHours() {
    businessHoursEnabled.value = !businessHoursEnabled.value;
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 3);
  }
}
