class DashboardStatsModel {
  final double totalGmv;
  final int totalOrders;
  final int pendingApprovals;
  final int activeDeliveries;

  DashboardStatsModel({
    required this.totalGmv,
    required this.totalOrders,
    required this.pendingApprovals,
    required this.activeDeliveries,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalGmv: (json['totalGmv'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      pendingApprovals: json['pendingApprovals'] as int? ?? 0,
      activeDeliveries: json['activeDeliveries'] as int? ?? 0,
    );
  }
}

class AiAlertModel {
  final int productId;
  final String productName;
  final int currentQty;
  final int reorderThreshold;

  AiAlertModel({
    required this.productId,
    required this.productName,
    required this.currentQty,
    required this.reorderThreshold,
  });

  factory AiAlertModel.fromJson(Map<String, dynamic> json) {
    return AiAlertModel(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      currentQty: json['currentQty'] as int? ?? 0,
      reorderThreshold: json['reorderThreshold'] as int? ?? 0,
    );
  }
}
