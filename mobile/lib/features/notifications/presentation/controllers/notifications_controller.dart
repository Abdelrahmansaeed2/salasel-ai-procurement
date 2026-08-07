import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/notification_model.dart';

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

  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
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

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.put('/notifications/$id/read');
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updated = notifications[index];
        // Modify isRead if it's not final, or replace the object
        // Depending on NotificationModel implementation
        fetchNotifications(); // Reload to be safe
      }
    } catch (e) {
      // Ignore error for marking read
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'الكل') return notifications;
    // Basic filter by Title/Message text from payload
    return notifications.where((n) {
      final title = n.payload['title']?.toString() ?? '';
      final message = n.payload['message']?.toString() ?? '';
      return title.contains(selectedFilter.value) || message.contains(selectedFilter.value);
    }).toList();
  }

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 3);
  }
}
