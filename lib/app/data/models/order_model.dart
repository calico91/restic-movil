import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';

class OrderModel {
  final String? id;
  final String? openingDate;
  final String? closingDate;
  final int? orderNumber;
  final String? status;
  final String? originType;
  final List<TableModel>? tables;
  final String? customerId;
  final String? customerName;
  final String? observations;
  final double? total;
  final List<OrderDetailModel>? details;
  final String? transactionId;

  OrderModel({
    this.id,
    this.orderNumber,
    this.openingDate,
    this.closingDate,
    this.status,
    this.originType,
    this.tables,
    this.customerId,
    this.customerName,
    this.observations,
    this.total,
    this.details,
    this.transactionId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      openingDate: json['openingDate'],
      closingDate: json['closingDate'],
      status: json['status'],
      orderNumber: json['orderNumber'],
      originType: json['originType'],
      tables: json['tables'] != null
          ? (json['tables'] as List).map((i) => TableModel.fromJson(i)).toList()
          : null,
      customerId: json['customerId'],
      customerName: json['customerName'],
      observations: json['observations'],
      total: (json['total'] as num?)?.toDouble(),
      details: json['details'] != null
          ? (json['details'] as List)
                .map((i) => OrderDetailModel.fromJson(i))
                .toList()
          : null,
      transactionId: json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'closingDate': closingDate,
      'openingDate': openingDate,
      'status': status,
      'originType': originType,
      'tables': tables?.map((i) => i.toJson()).toList(),
      'customerId': customerId,
      'customerName': customerName,
      'observations': observations,
      'total': total,
      'details': details?.map((i) => i.toJson()).toList(),
      'transactionId': transactionId,
    };
  }
}
