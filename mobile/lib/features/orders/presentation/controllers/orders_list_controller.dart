import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/navigation/app_navigator.dart';

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
  final RxString searchText = ''.obs;
  final RxBool showAiInsights = true.obs;

  final List<String> filters = [
    'الكل',
    'قيد الانتظار',
    'مقبول',
    'تم الشحن',
    'في الطريق',
  ];

  final List<OrderModel> allOrders = [
    OrderModel(
      id: '1',
      orderNumber: 'ORD-4828',
      supplierName: 'شركة البدر',
      supplierLogo: '',
      date: DateTime(2023, 10, 23),
      status: OrderStatus.accepted,
      items: [
        OrderItem(name: 'مياه معدنية 500مل', quantity: 20, unit: 'كرتون'),
        OrderItem(name: 'عصير برتقال', quantity: 12, unit: 'كرتون'),
      ],
      total: 612.00,
    ),
    OrderModel(
      id: '2',
      orderNumber: 'ORD-82941',
      supplierName: 'شركة المراعي',
      supplierLogo: '',
      date: DateTime(2023, 10, 24),
      status: OrderStatus.shipped,
      items: [
        OrderItem(name: 'حليب كامل الدسم', quantity: 30, unit: 'كرتون'),
      ],
      total: 318.00,
    ),
    OrderModel(
      id: '3',
      orderNumber: 'ORD-31045',
      supplierName: 'مؤسسة النور',
      supplierLogo: '',
      date: DateTime(2023, 10, 20),
      status: OrderStatus.pending,
      items: [
        OrderItem(name: 'سكر أبيض 1 كجم', quantity: 50, unit: 'كيس'),
        OrderItem(name: 'أرز بسمتي', quantity: 10, unit: 'كيس'),
      ],
      total: 450.00,
    ),
    OrderModel(
      id: '4',
      orderNumber: 'ORD-29100',
      supplierName: 'التوزيع الذهبي',
      supplierLogo: '',
      date: DateTime(2023, 10, 15),
      status: OrderStatus.delivered,
      items: [
        OrderItem(name: 'مسحوق غسيل تايد', quantity: 24, unit: 'علبة'),
      ],
      total: 840.00,
    ),
  ];

  List<OrderModel> get activeOrders =>
      allOrders.where((o) => o.status != OrderStatus.delivered).toList();

  List<OrderModel> get historyOrders =>
      allOrders.where((o) => o.status == OrderStatus.delivered).toList();

  List<OrderModel> get displayedOrders {
    final source = tabIndex.value == 0 ? activeOrders : historyOrders;
    final filter = selectedFilter.value;
    final query = searchText.value.trim();

    return source.where((o) {
      final matchesFilter = filter == 'الكل' ||
          (filter == 'قيد الانتظار' && o.status == OrderStatus.pending) ||
          (filter == 'مقبول' && o.status == OrderStatus.accepted) ||
          (filter == 'تم الشحن' && o.status == OrderStatus.shipped) ||
          (filter == 'في الطريق' && o.status == OrderStatus.shipped);
      final matchesSearch = query.isEmpty ||
          o.orderNumber.contains(query) ||
          o.supplierName.contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  double get activeTotalAmount =>
      activeOrders.fold(0, (sum, o) => sum + o.total);

  void setTab(int i) => tabIndex.value = i;
  void setFilter(String f) => selectedFilter.value = f;
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

  /// Returns the active step index (0-based) for the progress stepper.
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
