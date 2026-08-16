class InventoryItemModel {
  final int inventoryId;
  final int? productId; // nullable for custom items
  final String productName;
  final String sku;
  final String category;
  final double currentQty;
  final double maxQty;
  final double reorderThreshold;
  final String status;
  final String unitOfMeasure;
  final String imageUrl;
  final bool isCustom;
  final String? customBarcode;
  final double costPrice;

  InventoryItemModel({
    required this.inventoryId,
    this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    required this.currentQty,
    required this.maxQty,
    required this.reorderThreshold,
    required this.status,
    required this.unitOfMeasure,
    required this.imageUrl,
    this.isCustom = false,
    this.customBarcode,
    this.costPrice = 0.0,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      inventoryId: json['inventoryID'] ?? json['inventoryId'] ?? 0,
      productId: json['productId'],
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      category: json['categoryName'] ?? json['category'] ?? 'عام',
      currentQty: (json['currentQty'] as num?)?.toDouble() ?? 0.0,
      maxQty: (json['maxQty'] as num?)?.toDouble() ?? 100.0,
      reorderThreshold: (json['reorderThreshold'] as num?)?.toDouble() ?? 10.0,
      status: json['status'] ?? 'متوفر',
      unitOfMeasure: json['unit'] ?? json['unitOfMeasure'] ?? 'قطعة',
      imageUrl: json['imageUrl'] ?? '',
      isCustom: json['isCustom'] ?? false,
      customBarcode: json['customBarcode'],
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
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
