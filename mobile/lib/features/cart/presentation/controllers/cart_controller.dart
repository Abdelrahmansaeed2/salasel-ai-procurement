import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../orders/presentation/screens/checkout_screen.dart';
import 'package:flutter/material.dart';

class CartItem {
  final int productId;
  final String name;
  final String sku;
  final String unit;
  final String imageUrl;
  final double price; // Mocked or fetched
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.unit,
    required this.imageUrl,
    this.price = 100.0,
    this.quantity = 1,
  });
}

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final items = <CartItem>[].obs;
  final isProcessing = false.obs;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartItem newItem) {
    final index = items.indexWhere((item) => item.productId == newItem.productId);
    if (index >= 0) {
      items[index].quantity += newItem.quantity;
      items.refresh();
    } else {
      items.add(newItem);
    }
  }

  void removeItem(int productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      items[index].quantity = newQuantity;
      items.refresh();
    }
  }

  void clearCart() {
    items.clear();
  }

  Future<void> checkout() async {
    if (items.isEmpty) return;
    
    try {
      isProcessing.value = true;
      
      final payload = {
        'items': items.map((i) => {
          'productId': i.productId,
          'quantity': i.quantity
        }).toList()
      };

      final response = await _apiClient.dio.post('/orders/manual', data: payload);
      
      if (response.statusCode == 200) {
        final orderId = response.data['id'].toString();
        final supplierName = response.data['supplierName'] ?? 'مورد غير معروف';
        final itemsNames = items.map((i) => i.name).join('، ');
        
        Get.off(() => CheckoutScreen(
          orderId: orderId,
          totalAmount: '${subtotal.toStringAsFixed(0)} جنيه',
          supplierName: supplierName,
          itemsSummary: itemsNames,
          merchantName: 'تاجر', // Would come from auth state
          merchantAddress: 'عنوان التوصيل الافتراضي',
          merchantCity: 'الرياض',
        ));
        
        clearCart();
      } else {
        Get.snackbar('خطأ', 'فشل إنشاء الطلب', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Checkout Error: $e');
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}
