import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/ai_order_response.dart';
import '../../domain/order_review_models.dart';
import '../../domain/supplier_model.dart';

class OrderReviewController extends GetxController {
  final RxList<ExtractedProduct> products = <ExtractedProduct>[].obs;
  final RxInt editingIndex = (-1).obs;
  final RxList<RiskAlert> riskAlerts = <RiskAlert>[].obs;
  final RxBool isSubmitting = false.obs;

  AiOrderResponse? currentResponse;

  final RxString transcript = ''.obs;
  final Rxn<SupplierModel> recommendedSupplier = Rxn<SupplierModel>();

  void setInitialData(AiOrderResponse response) {
    currentResponse = response;
    products.clear();
    transcript.value = response.transcript ?? 'لا يوجد نص متاح';
    
    for (final split in response.splits) {
      for (final item in split.items) {
        products.add(ExtractedProduct(
          productId: int.tryParse(item.productId),
          name: item.name,
          quantity: item.quantity,
          unitLabel: item.unit,
          unitPrice: item.unitPrice,
        ));
      }
    }
    
    if (response.splits.isNotEmpty) {
      _fetchSupplierDetails(response.splits.first.supplierId);
    }

    // Map dynamic risk alerts from backend
    if (response.riskAlerts.isNotEmpty) {
      riskAlerts.value = response.riskAlerts.map((ra) {
        RiskAlertLevel level;
        if (ra.level.toLowerCase() == 'warning') {
          level = RiskAlertLevel.warning;
        } else if (ra.level.toLowerCase() == 'danger') {
          level = RiskAlertLevel.danger;
        } else {
          level = RiskAlertLevel.safe;
        }
        return RiskAlert(
          title: ra.title,
          subtitle: ra.subtitle,
          level: level,
        );
      }).toList();
    } else {
      riskAlerts.value = [];
    }
  }

  Future<void> _fetchSupplierDetails(String supplierId) async {
    try {
      final ApiClient apiClient = ApiClient();
      final response = await apiClient.dio.get('https://salasel.otlob-egy.online/api/Suppliers/$supplierId');
      if (response.statusCode == 200) {
        recommendedSupplier.value = SupplierModel.fromJson(response.data);
      }
    } catch (e) {
      Get.log('Failed to fetch supplier details: $e');
    }
  }

  double get totalAmount =>
      products.fold(0, (sum, product) => sum + product.total);

  void toggleEdit(int index) {
    editingIndex.value = editingIndex.value == index ? -1 : index;
  }

  void increment(int index) {
    products[index] = products[index].copyWith(
      quantity: products[index].quantity + 1,
    );
  }

  void decrement(int index) {
    final current = products[index];
    if (current.quantity <= 1) return;
    products[index] = current.copyWith(quantity: current.quantity - 1);
  }

  Future<bool> submitOrder() async {
    if (currentResponse == null) return false;
    isSubmitting.value = true;
    try {
      final ApiClient apiClient = ApiClient();
      
      // Submit the RFQ (this creates the draft/RFQ in the real backend)
      // Map the current modified products back into the payload
      // For now we will just submit a standard RFQ structure or assume the AI handles the draft
      final payload = {
        'merchantId': int.tryParse(currentResponse!.merchantId) ?? 1,
        'expectedDeliveryDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'items': products.map((p) => {
          'productId': p.productId ?? 1, // Use actual retrieved productId, fallback to 1 only if null
          'quantity': p.quantity,
          'targetPrice': p.unitPrice,
        }).toList(),
      };

      final response = await apiClient.dio.post('/orders/rfqs', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تأكيد الطلب.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
