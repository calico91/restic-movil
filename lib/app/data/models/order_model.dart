import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/models/order_surcharge_model.dart';

class OrderModel {
  final String? id;
  final String? openingDate;
  final String? closingDate;
  final int? orderNumber;
  final String? status;
  final OriginType? originType;
  final List<TableModel>? tables;
  final CustomerModel? customer;
  final String? observations;
  final double? total;
  final double? surchargesTotal;
  final List<OrderDetailModel>? details;
  final List<OrderSurchargeModel>? surcharges;
  final String? transactionId;

  OrderModel({
    this.id,
    this.orderNumber,
    this.openingDate,
    this.closingDate,
    this.status,
    this.originType,
    this.tables,
    this.customer,
    this.observations,
    this.total,
    this.surchargesTotal,
    this.details,
    this.surcharges,
    this.transactionId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      openingDate: json['openingDate'],
      closingDate: json['closingDate'],
      status: json['status'],
      orderNumber: json['orderNumber'],
      originType: json['originType'] != null
          ? OriginType.fromJson(json['originType'])
          : null,
      tables: json['tables'] != null
          ? (json['tables'] as List).map((i) => TableModel.fromJson(i)).toList()
          : null,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      observations: json['observations'],
      total: (json['total'] as num?)?.toDouble(),
      surchargesTotal: (json['surchargesTotal'] as num?)?.toDouble(),
      details: json['details'] != null
          ? (json['details'] as List)
                .map((i) => OrderDetailModel.fromJson(i))
                .toList()
          : null,
      surcharges: json['surcharges'] != null
          ? (json['surcharges'] as List)
                .map((i) => OrderSurchargeModel.fromJson(i))
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
      'originType': originType?.toJson(),
      'tables': tables?.map((i) => i.toJson()).toList(),
      'customer': customer?.toJson(),
      'observations': observations,
      'total': total,
      'surchargesTotal': surchargesTotal,
      'details': details?.map((i) => i.toJson()).toList(),
      'surcharges': surcharges?.map((i) => i.toJson()).toList(),
      'transactionId': transactionId,
    };
  }
}
