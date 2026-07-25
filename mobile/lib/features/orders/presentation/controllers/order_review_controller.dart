import 'package:get/get.dart';

import '../../domain/order_review_models.dart';

class OrderReviewController extends GetxController {
  final RxList<ExtractedProduct> products = <ExtractedProduct>[
    const ExtractedProduct(
      name: 'مياه معدنية ٥٠٠ مل',
      quantity: 20,
      unitLabel: 'كرتون',
      unitPrice: 12.50,
    ),
    const ExtractedProduct(
      name: 'عصير برتقال طبيعي',
      quantity: 12,
      unitLabel: 'كرتون',
      unitPrice: 18.00,
      note: 'نكهة طبيعية',
    ),
  ].obs;

  final RxInt editingIndex = (-1).obs;

  final List<RiskAlert> riskAlerts = const [
    RiskAlert(
      title: 'لا تهديدات موجودة',
      subtitle: 'مورد موثوق ومُعتمد',
      level: RiskAlertLevel.safe,
    ),
    RiskAlert(
      title: 'تحقق من كمية العصير',
      subtitle: 'أعلى بـ ٢٠٪ من متوسط طلباتك',
      level: RiskAlertLevel.warning,
    ),
    RiskAlert(
      title: 'السعر ضمن النطاق المعتاد',
      subtitle: 'مطابق لمتوسط آخر ٣٠ يوماً',
      level: RiskAlertLevel.safe,
    ),
  ];

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
}
