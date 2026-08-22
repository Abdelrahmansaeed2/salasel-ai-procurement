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
      final response = await apiClient.dio.get('https://salasel.otlob-egy.online/api/v1/suppliers/$supplierId');
      if (response.statusCode == 200) {
        recommendedSupplier.value = SupplierModel.fromJson(response.data);
      }
    } catch (e) {
      Get.log('Failed to fetch supplier details: $e');
      // Fallback for missing supplier in database (e.g. out of sync with vector DB)
      recommendedSupplier.value = SupplierModel(
        supplierId: int.tryParse(supplierId) ?? 0,
        companyName: 'مورد غير معروف (ID: $supplierId)',
        reliabilityScore: 0.85,
        paymentTerms: '',
      );
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

  Future<int?> submitOrder() async {
    if (currentResponse == null) return null;
    isSubmitting.value = true;
    try {
      final ApiClient apiClient = ApiClient();
      
      // Submit the Order (this creates the AI_Draft in the real backend)
      final payload = {
        'merchantId': int.tryParse(currentResponse!.merchantId) ?? 1,
        'voiceLogId': null,
        'totalOrderCost': currentResponse!.totalOrderCost,
        'splits': [
          {
            'supplierId': int.tryParse(currentResponse!.splits.first.supplierId) ?? 0,
            'productId': products.first.productId ?? 1,
            'quantityOrdered': products.first.quantity,
            'subTotalCost': products.first.total,
          }
        ],
      };
      // Map all products to splits correctly for the demo
      if (products.length > 1) {
        payload['splits'] = products.map((p) => {
          'supplierId': int.tryParse(currentResponse!.splits.first.supplierId) ?? 0, // Fallback to first supplier
          'productId': p.productId ?? 1,
          'quantityOrdered': p.quantity,
          'subTotalCost': p.total,
        }).toList();
      }

      final response = await apiClient.dio.post('/orders/execute', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'] as int?; // Ensure .NET returns { Id: ... } and Dio parses it
      }
      return null;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تأكيد الطلب.');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
