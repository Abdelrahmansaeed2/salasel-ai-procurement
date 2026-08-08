class ExtractedProduct {
  final int? productId;
  final String name;
  final int quantity;
  final String unitLabel;
  final double unitPrice;
  final String? note;

  ExtractedProduct({
    this.productId,
    required this.name,
    required this.quantity,
    required this.unitLabel,
    required this.unitPrice,
    this.note,
  });

  double get total => quantity * unitPrice;

  ExtractedProduct copyWith({
    int? productId,
    String? name,
    int? quantity,
    String? unitLabel,
    double? unitPrice,
    String? note,
  }) =>
      ExtractedProduct(
        productId: productId ?? this.productId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unitLabel: unitLabel ?? this.unitLabel,
        unitPrice: unitPrice ?? this.unitPrice,
        note: note ?? this.note,
      );
}

class RiskAlert {
  final String title;
  final String subtitle;
  final RiskAlertLevel level;

  RiskAlert({
    required this.title,
    required this.subtitle,
    required this.level,
  });
}

enum RiskAlertLevel { safe, warning, danger }
