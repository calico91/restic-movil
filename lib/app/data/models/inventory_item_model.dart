class InventoryItemModel {
  final String? id;
  final String? name;
  final String? unit;
  final double? currentStock;
  final double? minStock;
  final bool? active;
  final String? stockStatus;

  InventoryItemModel({
    this.id,
    this.name,
    this.unit,
    this.currentStock,
    this.minStock,
    this.active,
    this.stockStatus,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      currentStock: (json['currentStock'] as num?)?.toDouble(),
      minStock: (json['minStock'] as num?)?.toDouble(),
      active: json['active'],
      stockStatus: json['stockStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'currentStock': currentStock,
      'minStock': minStock,
      'active': active,
      'stockStatus': stockStatus,
    };
  }
}
