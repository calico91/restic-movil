class StockMovementModel {
  final String? id;
  final String? inventoryItemId;
  final String? inventoryItemName;
  final String? type;
  final double? quantity;
  final String? referenceOrderId;
  final int? referenceOrderNumber;
  final String? notes;
  final String? createdById;
  final String? createdByName;
  final DateTime? createdAt;
  final bool? manual;

  StockMovementModel({
    this.id,
    this.inventoryItemId,
    this.inventoryItemName,
    this.type,
    this.quantity,
    this.referenceOrderId,
    this.referenceOrderNumber,
    this.notes,
    this.createdById,
    this.createdByName,
    this.createdAt,
    this.manual,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'],
      inventoryItemId: json['inventoryItemId'],
      inventoryItemName: json['inventoryItemName'],
      type: json['type'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      referenceOrderId: json['referenceOrderId'],
      referenceOrderNumber: json['referenceOrderNumber'],
      notes: json['notes'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      manual: json['manual'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'inventoryItemName': inventoryItemName,
      'type': type,
      'quantity': quantity,
      'referenceOrderId': referenceOrderId,
      'referenceOrderNumber': referenceOrderNumber,
      'notes': notes,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt?.toIso8601String(),
      'manual': manual,
    };
  }
}
