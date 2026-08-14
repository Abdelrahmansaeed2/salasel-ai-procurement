import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/network/api_client.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum OrderStatus { pending, accepted, shipped, delivered }

class OrderItem {
  final String name;
  final int quantity;
  final String unit;
  OrderItem({required this.name, required this.quantity, required this.unit});
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String supplierName;
  final String supplierLogo;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.supplierName,
    required this.supplierLogo,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
  });
}

// ─── Controller ───────────────────────────────────────────────────────────────

class OrdersController extends GetxController {
  final RxInt bottomNavIndex = 2.obs;
  final RxInt tabIndex = 0.obs; // 0 = active, 1 = history
  final RxString selectedFilter = 'الكل'.obs;
  final RxString dateFilter = 'الكل'.obs;
  final RxnDouble minPrice = RxnDouble();
  final RxnDouble maxPrice = RxnDouble();
  
  final RxString searchText = ''.obs;
  final RxBool showAiInsights = true.obs;
  final RxBool isLoading = true.obs;

  final List<String> filters = [
    'الكل',
    'قيد الانتظار',
    'مقبول',
    'تم الشحن',
    'في الطريق',
  ];

  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/merchants/me/recent-orders', queryParameters: {'take': 50});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        allOrders.value = data.map((json) {
          // Map backend status to local OrderStatus
          OrderStatus status = OrderStatus.pending;
          final String statusStr = json['status'] ?? 'Pending';
          if (statusStr == 'Pending') status = OrderStatus.pending;
          else if (statusStr == 'Accepted') status = OrderStatus.accepted;
          else if (statusStr == 'Shipped') status = OrderStatus.shipped;
          else if (statusStr == 'Completed') status = OrderStatus.delivered;

          return OrderModel(
            id: json['id']?.toString() ?? '',
            orderNumber: 'ORD-${json['id']}',
            supplierName: json['supplier'] ?? 'مورد',
            supplierLogo: '', // Need real logo if provided
            date: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
            status: status,
            items: [
              OrderItem(
                  name: json['itemsSummary']?.isNotEmpty == true ? json['itemsSummary'] : 'عناصر الطلب', 
                  quantity: 1, 
                  unit: ''), // We combine them in one line for the summary UI
            ],
            total: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderModel> get activeOrders =>
      allOrders.where((o) => o.status != OrderStatus.delivered).toList();

  List<OrderModel> get historyOrders =>
      allOrders.where((o) => o.status == OrderStatus.delivered).toList();

  List<OrderModel> get displayedOrders {
    final source = tabIndex.value == 0 ? activeOrders : historyOrders;
    final filter = selectedFilter.value;
    final query = searchText.value.trim();
    final dFilter = dateFilter.value;
    final pMin = minPrice.value;
    final pMax = maxPrice.value;
    final now = DateTime.now();

    return source.where((o) {
      final matchesFilter = filter == 'الكل' ||
          (filter == 'قيد الانتظار' && o.status == OrderStatus.pending) ||
          (filter == 'مقبول' && o.status == OrderStatus.accepted) ||
          (filter == 'تم الشحن' && o.status == OrderStatus.shipped) ||
          (filter == 'في الطريق' && o.status == OrderStatus.shipped);
      final matchesSearch = query.isEmpty ||
          o.orderNumber.contains(query) ||
          o.supplierName.contains(query);
          
      bool matchesDate = true;
      if (dFilter == 'آخر 7 أيام') {
        matchesDate = now.difference(o.date).inDays <= 7;
      } else if (dFilter == 'آخر 30 يوم') {
        matchesDate = now.difference(o.date).inDays <= 30;
      } else if (dFilter == 'هذا الشهر') {
        matchesDate = o.date.month == now.month && o.date.year == now.year;
      }

      bool matchesPrice = true;
      if (pMin != null && o.total < pMin) matchesPrice = false;
      if (pMax != null && o.total > pMax) matchesPrice = false;

      return matchesFilter && matchesSearch && matchesDate && matchesPrice;
    }).toList();
  }

  double get activeTotalAmount =>
      activeOrders.fold(0, (sum, o) => sum + o.total);

  void setTab(int i) => tabIndex.value = i;
  void setFilter(String f) => selectedFilter.value = f;
  void setDateFilter(String f) => dateFilter.value = f;
  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
  }
  void resetAdvancedFilters() {
    dateFilter.value = 'الكل';
    minPrice.value = null;
    maxPrice.value = null;
  }
  void setSearch(String s) => searchText.value = s;
  void dismissAi() => showAiInsights.value = false;

  void changeTab(int index) {
    AppNavigator.changeTab(index, currentTabIndex: 2);
  }

  String statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'وصل';
    }
  }

  Color statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.accepted:
        return const Color(0xFF2563EB);
      case OrderStatus.shipped:
        return const Color(0xFF10B981);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
    }
  }

  int stepIndex(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
    }
  }
}
