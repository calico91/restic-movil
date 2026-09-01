class ProductSalesReportResponse {
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final DateTime? generatedAt;
  final int? totalTransactions;
  final int? totalProducts;
  final int? totalUnitsSold;
  final double? totalRevenue;
  final List<ProductSalesSummary>? products;

  ProductSalesReportResponse({
    this.startDateTime,
    this.endDateTime,
    this.generatedAt,
    this.totalTransactions,
    this.totalProducts,
    this.totalUnitsSold,
    this.totalRevenue,
    this.products,
  });

  factory ProductSalesReportResponse.fromJson(Map<String, dynamic> json) {
    return ProductSalesReportResponse(
      startDateTime: _parseDateTime(json['startDateTime']),
      endDateTime: _parseDateTime(json['endDateTime']),
      generatedAt: _parseDateTime(json['generatedAt']),
      totalTransactions: json['totalTransactions'] is int
          ? json['totalTransactions'] as int
          : (json['totalTransactions'] is String
              ? int.tryParse(json['totalTransactions'] as String)
              : null),
      totalProducts: json['totalProducts'] is int
          ? json['totalProducts'] as int
          : (json['totalProducts'] is String
              ? int.tryParse(json['totalProducts'] as String)
              : null),
      totalUnitsSold: json['totalUnitsSold'] is int
          ? json['totalUnitsSold'] as int
          : (json['totalUnitsSold'] is String
              ? int.tryParse(json['totalUnitsSold'] as String)
              : null),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      products: json['products'] != null
          ? (json['products'] as List)
              .map((i) => ProductSalesSummary.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class ProductSalesSummary {
  final String? productId;
  final String? productName;
  final String? productType;
  final String? categoryName;
  final String? subcategoryName;
  final int? timesSold;
  final int? totalQuantity;
  final double? totalRevenue;
  final double? percentage;
  final List<ProductSaleEvent>? events;

  ProductSalesSummary({
    this.productId,
    this.productName,
    this.productType,
    this.categoryName,
    this.subcategoryName,
    this.timesSold,
    this.totalQuantity,
    this.totalRevenue,
    this.percentage,
    this.events,
  });

  factory ProductSalesSummary.fromJson(Map<String, dynamic> json) {
    return ProductSalesSummary(
      productId: json['productId']?.toString(),
      productName: json['productName'],
      productType: json['productType'],
      categoryName: json['categoryName'],
      subcategoryName: json['subcategoryName'],
      timesSold: json['timesSold'] is int
          ? json['timesSold'] as int
          : (json['timesSold'] != null
              ? int.tryParse(json['timesSold'].toString())
              : null),
      totalQuantity: json['totalQuantity'] is int
          ? json['totalQuantity'] as int
          : (json['totalQuantity'] != null
              ? int.tryParse(json['totalQuantity'].toString())
              : null),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      events: json['events'] != null
          ? (json['events'] as List)
              .map((i) => ProductSaleEvent.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class ProductSaleEvent {
  final int? orderNumber;
  final DateTime? soldAt;
  final int? quantity;
  final double? unitPrice;
  final double? subtotal;

  ProductSaleEvent({
    this.orderNumber,
    this.soldAt,
    this.quantity,
    this.unitPrice,
    this.subtotal,
  });

  factory ProductSaleEvent.fromJson(Map<String, dynamic> json) {
    return ProductSaleEvent(
      orderNumber: json['orderNumber'] is int
          ? json['orderNumber'] as int
          : (json['orderNumber'] != null
              ? int.tryParse(json['orderNumber'].toString())
              : null),
      soldAt: _parseDateTime(json['soldAt']),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : (json['quantity'] != null
              ? int.tryParse(json['quantity'].toString())
              : null),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  if (value is List) {
    final parts = value.map((e) => (e as num).toInt()).toList();
    if (parts.length >= 3) {
      final base = DateTime(parts[0], parts[1], parts[2]);
      if (parts.length >= 4) base.add(Duration(hours: parts[3]));
      if (parts.length >= 5) base.add(Duration(minutes: parts[4]));
      if (parts.length >= 6) base.add(Duration(seconds: parts[5]));
      return base;
    }
  }
  return null;
}
