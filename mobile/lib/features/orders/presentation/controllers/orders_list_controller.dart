import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../data/models/order_detail_model.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
import 'package:signalr_netcore/signalr_client.dart';

enum OrderStatus { pending, pendingPayment, accepted, shipped, delivered }

class OrderItem {
  final String name;
  final int quantity;
  final String unit;
  OrderItem({required this.name, required this.quantity, required this.unit});
}

enum ReturnStatus { pending, approved, rejected, escalated, refunded, closed }

class ReturnOrderModel {
  final String id;
  final String masterOrderId;
  final ReturnStatus status;
  final double requestedAmount;
  final double? approvedAmount;
  final DateTime date;
  
  ReturnOrderModel({
    required this.id,
    required this.masterOrderId,
    required this.status,
    required this.requestedAmount,
    this.approvedAmount,
    required this.date,
  });
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
  final RxInt bottomNavIndex = 3.obs;
  final RxInt tabIndex = 0.obs; // 0 = active, 1 = history, 2 = returns
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
  final RxList<ReturnOrderModel> returnsOrders = <ReturnOrderModel>[].obs;
  final ApiClient _apiClient = ApiClient();
  HubConnection? _hubConnection;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchReturns();
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) return;

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '${ApiClient.baseUrl.replaceAll('/api/', '')}/hubs/notifications', // e.g., https://salasel.otlob-egy.online/hubs/notifications
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _hubConnection?.on('OrderAccepted', _handleOrderUpdate);
      _hubConnection?.on('OrderShipped', _handleOrderUpdate);
      _hubConnection?.on('OrderDelivered', _handleOrderUpdate);
      _hubConnection?.on('OrderDeclined', _handleOrderUpdate);
      _hubConnection?.on('OrderCancelled', _handleOrderUpdate);
      _hubConnection?.on('OrderStatusChanged', _handleOrderUpdate);

      await _hubConnection?.start();
      
      // Tell the hub we are a merchant so it puts us in the right group
      final profileRes = await _apiClient.dio.get('/users/me');
      if (profileRes.statusCode == 200 && profileRes.data['shops'] != null) {
        final shops = profileRes.data['shops'] as List;
        if (shops.isNotEmpty) {
          final merchantId = shops.first['merchantID'];
          await _hubConnection?.invoke('JoinAsMerchant', args: [merchantId]);
          debugPrint('Joined SignalR as merchant $merchantId');
        }
      }
    } catch (e) {
      debugPrint('SignalR init error: $e');
    }
  }

  void _handleOrderUpdate(List<dynamic>? arguments) {
    debugPrint('SignalR Update received. Fetching latest orders...');
    fetchOrders();
  }

  @override
  void onClose() {
    _hubConnection?.stop();
    super.onClose();
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
          else if (statusStr == 'PendingPayment') status = OrderStatus.pendingPayment;
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

  Future<void> fetchReturns() async {
    try {
      final response = await _apiClient.dio.get('/returns');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        returnsOrders.value = data.map((json) {
          ReturnStatus st = ReturnStatus.pending;
          final str = json['status'] ?? 'Pending';
          if (str == 'Approved') st = ReturnStatus.approved;
          if (str == 'Rejected') st = ReturnStatus.rejected;
          if (str == 'Refunded') st = ReturnStatus.refunded;
          
          return ReturnOrderModel(
            id: json['id']?.toString() ?? '',
            masterOrderId: json['masterOrderId']?.toString() ?? '',
            status: st,
            requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0.0,
            approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
            date: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Failed to load returns: $e');
    }
  }

  Future<void> reorder(OrderModel order) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
        barrierDismissible: false,
      );

      final response = await _apiClient.dio.get('/orders/${order.id}');
      Get.back(); // close loading

      if (response.statusCode == 200) {
        final orderDetails = OrderDetailModel.fromJson(response.data);
        
        final cartCtrl = Get.put(CartController());
        cartCtrl.clearCart();

        for (var product in orderDetails.products) {
          final parts = product.requestedQuantity.trim().split(' ');
          final int quantity = parts.isNotEmpty ? (int.tryParse(parts.first) ?? 1) : 1;
          final String unit = parts.length > 1 ? parts.sublist(1).join(' ') : 'وحدة';
          
          cartCtrl.addItem(CartItem(
            productId: product.productId,
            name: product.productName,
            sku: '',
            unit: unit,
            imageUrl: '', 
            price: product.unitPrice,
            quantity: quantity,
          ));
        }

        Get.snackbar('نجاح', 'تمت إضافة عناصر الطلب إلى سلة التسوق',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        Get.to(() => const CartScreen());
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('خطأ', 'فشل في استرجاع تفاصيل الطلب لإعادة الطلب');
      debugPrint('Failed to reorder: $e');
    }
  }

  List<OrderModel> get activeOrders =>
      allOrders.where((o) => o.status != OrderStatus.delivered).toList();

  List<OrderModel> get historyOrders =>
      allOrders.where((o) => o.status == OrderStatus.delivered).toList();

  List<OrderModel> get displayedOrders {
    // displayedOrders is now only for tab 0 and 1. Tab 2 uses returnsOrders directly.
    final source = tabIndex.value == 0 ? activeOrders : historyOrders;
    final filter = selectedFilter.value;
    final query = searchText.value.trim();
    final dFilter = dateFilter.value;
    final pMin = minPrice.value;
    final pMax = maxPrice.value;
    final now = DateTime.now();

    return source.where((o) {
      final matchesFilter = filter == 'الكل' ||
          (filter == 'قيد الانتظار' && (o.status == OrderStatus.pending || o.status == OrderStatus.pendingPayment)) ||
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
      case OrderStatus.pendingPayment:
        return 'بانتظار الدفع';
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
      case OrderStatus.pendingPayment:
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
      case OrderStatus.pendingPayment:
        return 1;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
    }
  }
}
