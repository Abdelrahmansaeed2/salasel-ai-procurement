import 'package:get/get.dart';

import '../../../../core/navigation/app_navigator.dart';

class NotificationsController extends GetxController {
  final RxInt bottomNavIndex = 3.obs;

  final List<String> filters = const [
    'الكل',
    'الطلبات',
    'الذكاء الاصطناعي',
    'المخزون',
    'التوصيل',
    'المدفوعات',
    'النظام',
  ];

  final RxString selectedFilter = 'الكل'.obs;

  void setFilter(String filter) => selectedFilter.value = filter;

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 3);
  }
}
