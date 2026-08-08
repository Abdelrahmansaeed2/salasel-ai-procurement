class OrderDetailProductModel {
  final String supplierName;
  final String productName;
  final String requestedQuantity;
  final String detectedQuantity;
  final double unitPrice;

  OrderDetailProductModel({
    required this.supplierName,
    required this.productName,
    required this.requestedQuantity,
    required this.detectedQuantity,
    required this.unitPrice,
  });

  factory OrderDetailProductModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailProductModel(
      supplierName: json['supplierName'] ?? '',
      productName: json['productName'] ?? '',
      requestedQuantity: json['requestedQuantity'] ?? '',
      detectedQuantity: json['detectedQuantity'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderDetailAiInsightsModel {
  final String language;
  final String processingTime;
  final String confidence;

  OrderDetailAiInsightsModel({
    required this.language,
    required this.processingTime,
    required this.confidence,
  });

  factory OrderDetailAiInsightsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailAiInsightsModel(
      language: json['language'] ?? '',
      processingTime: json['processingTime'] ?? '',
      confidence: json['confidence'] ?? '',
    );
  }
}

class OrderDetailModel {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final double deliveryFee;
  final double tax;
  final DateTime orderDate;
  final String status;
  final String transcript;
  final OrderDetailAiInsightsModel? aiInsights;
  final List<OrderDetailProductModel> products;

  OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.deliveryFee,
    required this.tax,
    required this.orderDate,
    required this.status,
    required this.transcript,
    this.aiInsights,
    required this.products,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : DateTime.now(),
      status: json['status'] ?? '',
      transcript: json['transcript'] ?? '',
      aiInsights: json['aiInsights'] != null ? OrderDetailAiInsightsModel.fromJson(json['aiInsights']) : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => OrderDetailProductModel.fromJson(p))
              .toList() ??
          [],
    );
  }
}
