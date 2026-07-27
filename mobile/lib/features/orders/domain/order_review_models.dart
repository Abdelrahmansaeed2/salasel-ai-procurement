class ExtractedProduct {
  final String name;
  final int quantity;
  final String unitLabel;
  final double unitPrice;
  final String? note;

  ExtractedProduct({
    required this.name,
    required this.quantity,
    required this.unitLabel,
    required this.unitPrice,
    this.note,
  });

  double get total => quantity * unitPrice;

  ExtractedProduct copyWith({int? quantity}) => ExtractedProduct(
        name: name,
        quantity: quantity ?? this.quantity,
        unitLabel: unitLabel,
        unitPrice: unitPrice,
        note: note,
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

enum RiskAlertLevel { safe, warning }
