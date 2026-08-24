class InsightModel {
  final int productId;
  final String productName;
  final String reason;
  final int currentQty;
  final int reorderThreshold;
  final int? recommendedSupplierId;
  final String? recommendedSupplierName;
  final double? recommendedUnitPrice;
  final int? recommendedLeadTimeDays;

  InsightModel({
    required this.productId,
    required this.productName,
    required this.reason,
    required this.currentQty,
    required this.reorderThreshold,
    this.recommendedSupplierId,
    this.recommendedSupplierName,
    this.recommendedUnitPrice,
    this.recommendedLeadTimeDays,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      reason: json['reason'] ?? '',
      currentQty: json['currentQty'] ?? 0,
      reorderThreshold: json['reorderThreshold'] ?? 0,
      recommendedSupplierId: json['recommendedSupplierId'],
      recommendedSupplierName: json['recommendedSupplierName'],
      recommendedUnitPrice: (json['recommendedUnitPrice'] as num?)?.toDouble(),
      recommendedLeadTimeDays: json['recommendedLeadTimeDays'],
    );
  }
}
