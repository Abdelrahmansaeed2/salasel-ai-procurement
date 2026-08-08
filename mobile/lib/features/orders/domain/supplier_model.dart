class SupplierModel {
  final int supplierId;
  final String companyName;
  final double reliabilityScore;
  final String paymentTerms;

  SupplierModel({
    required this.supplierId,
    required this.companyName,
    required this.reliabilityScore,
    required this.paymentTerms,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierId: json['supplierID'] ?? 0,
      companyName: json['companyName'] ?? '',
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      paymentTerms: json['paymentTerms'] ?? '',
    );
  }
}
