class AiOrderResponse {
  final String merchantId;
  final double totalOrderCost;
  final List<AiOrderSplit> splits;
  final List<String> unresolved;
  final String? sessionId;

  AiOrderResponse({
    required this.merchantId,
    required this.totalOrderCost,
    required this.splits,
    required this.unresolved,
    this.sessionId,
  });

  factory AiOrderResponse.fromJson(Map<String, dynamic> json) {
    return AiOrderResponse(
      merchantId: json['merchant_id'] ?? '',
      totalOrderCost: (json['total_order_cost'] as num?)?.toDouble() ?? 0.0,
      splits: (json['splits'] as List<dynamic>?)
              ?.map((e) => AiOrderSplit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unresolved: (json['unresolved'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'total_order_cost': totalOrderCost,
      'splits': splits.map((e) => e.toJson()).toList(),
      'unresolved': unresolved,
      'session_id': sessionId,
    };
  }
}

class AiOrderSplit {
  final String supplierId;
  final List<AiOrderItem> items;
  final double subTotalCost;
  final int deliveryTimeDays;

  AiOrderSplit({
    required this.supplierId,
    required this.items,
    required this.subTotalCost,
    required this.deliveryTimeDays,
  });

  factory AiOrderSplit.fromJson(Map<String, dynamic> json) {
    return AiOrderSplit(
      supplierId: json['supplier_id'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AiOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subTotalCost: (json['sub_total_cost'] as num?)?.toDouble() ?? 0.0,
      deliveryTimeDays: json['delivery_time_days'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'items': items.map((e) => e.toJson()).toList(),
      'sub_total_cost': subTotalCost,
      'delivery_time_days': deliveryTimeDays,
    };
  }
}

class AiOrderItem {
  final String productId;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double subTotal;

  AiOrderItem({
    required this.productId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subTotal,
  });

  factory AiOrderItem.fromJson(Map<String, dynamic> json) {
    return AiOrderItem(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['sub_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'sub_total': subTotal,
    };
  }
}
