class InventoryItemModel {
  final int inventoryId;
  final int productId;
  final String productName;
  final String sku;
  final String category;
  final int currentQty;
  final int maxQty;
  final int reorderThreshold;
  final String status;
  final String unitOfMeasure;
  final String imageUrl;

  InventoryItemModel({
    required this.inventoryId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    required this.currentQty,
    required this.maxQty,
    required this.reorderThreshold,
    required this.status,
    required this.unitOfMeasure,
    required this.imageUrl,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      inventoryId: json['inventoryId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? 'عام',
      currentQty: json['currentQty'] ?? 0,
      maxQty: json['maxQty'] ?? 100,
      reorderThreshold: json['reorderThreshold'] ?? 10,
      status: json['status'] ?? 'متوفر',
      unitOfMeasure: json['unitOfMeasure'] ?? 'قطعة',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  double get stockPercentage => maxQty > 0 ? currentQty / maxQty : 0;
}

class AiRecommendationModel {
  final int productId;
  final String productName;
  final String reason;
  final int currentQty;
  final int reorderThreshold;
  final String recommendedSupplierName;
  final double recommendedUnitPrice;
  final int recommendedLeadTimeDays;

  AiRecommendationModel({
    required this.productId,
    required this.productName,
    required this.reason,
    required this.currentQty,
    required this.reorderThreshold,
    required this.recommendedSupplierName,
    required this.recommendedUnitPrice,
    required this.recommendedLeadTimeDays,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      reason: json['reason'] ?? '',
      currentQty: json['currentQty'] ?? 0,
      reorderThreshold: json['reorderThreshold'] ?? 0,
      recommendedSupplierName: json['recommendedSupplierName'] ?? '',
      recommendedUnitPrice: (json['recommendedUnitPrice'] as num?)?.toDouble() ?? 0.0,
      recommendedLeadTimeDays: json['recommendedLeadTimeDays'] ?? 0,
    );
  }
}
