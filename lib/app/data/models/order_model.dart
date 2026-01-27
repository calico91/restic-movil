import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';

class OrderModel {
  final String? id;
  final String? openingDate;
  final int? orderNumber;
  final String? status;
  final String? originType;
  final List<TableModel>? tables;
  final String? observations;
  final double? total;
  final List<OrderDetailModel>? details;

  OrderModel({
    this.id,
    this.orderNumber,
    this.openingDate,
    this.status,
    this.originType,
    this.tables,
    this.observations,
    this.total,
    this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      openingDate: json['openingDate'],
      status: json['status'],
      orderNumber: json['orderNumber'],
      originType: json['originType'],
      tables: json['tables'] != null
          ? (json['tables'] as List).map((i) => TableModel.fromJson(i)).toList()
          : null,
      observations: json['observations'],
      total: (json['total'] as num?)?.toDouble(),
      details: json['details'] != null
          ? (json['details'] as List)
              .map((i) => OrderDetailModel.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'openingDate': openingDate,
      'status': status,
      'originType': originType,
      'tables': tables?.map((i) => i.toJson()).toList(),
      'observations': observations,
      'total': total,
      'details': details?.map((i) => i.toJson()).toList(),
    };
  }
}
