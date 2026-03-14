import 'package:restic_movil/app/data/models/order_combo_selection_model.dart';

class OrderDetailModel {
  final String? id;
  final String? productId;
  final String? productName;
  final String? productType;
  final double? unitPrice;
  final int? quantity;
  final double? subtotal;
  final String? observations;
  final String? status;
  final String? addedAt;
  final String? preparedAt;
  final String? servedAt;
  final List<OrderComboSelectionModel>? comboSelections;

  OrderDetailModel({
    this.id,
    this.productId,
    this.productName,
    this.productType,
    this.unitPrice,
    this.quantity,
    this.subtotal,
    this.observations,
    this.status,
    this.addedAt,
    this.preparedAt,
    this.servedAt,
    this.comboSelections,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productType: json['productType'],
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      observations: json['observations'],
      status: json['status'],
      addedAt: json['addedAt'],
      preparedAt: json['preparedAt'],
      servedAt: json['servedAt'],
      comboSelections: json['comboSelections'] != null
          ? (json['comboSelections'] as List)
                .map((i) => OrderComboSelectionModel.fromJson(i))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productType': productType,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'observations': observations,
      'status': status,
      'addedAt': addedAt,
      'preparedAt': preparedAt,
      'servedAt': servedAt,
      'comboSelections': comboSelections?.map((i) => i.toJson()).toList(),
    };
  }
}
