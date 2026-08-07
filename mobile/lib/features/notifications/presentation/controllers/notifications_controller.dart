import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../data/models/notification_model.dart';

class NotificationsController extends GetxController {
  final RxInt bottomNavIndex = 3.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;

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

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('https://salasel.otlob-egy.online/api/v1/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        notifications.value =
            data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        Get.snackbar('خطأ', 'فشل في جلب الإشعارات');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'الكل') return notifications;
    // Map filters to backend event names if needed, for now just filter roughly by text
    // We can expand this logic based on EventName later.
    return notifications;
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 3);
  }
}
