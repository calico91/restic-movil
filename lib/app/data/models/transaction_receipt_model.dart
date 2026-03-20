class TransactionReceiptModel {
  final String? transactionNumber;
  final String? issuedAt;
  final FiscalDataReceipt? fiscalData;
  final String? shiftId;
  final String? cashierId;
  final String? orderId;
  final int? orderNumber;
  final String? originType;
  final List<String>? tableNames;
  final String? customerId;
  final String? customerName;
  final String? waiterId;
  final String? waiterName;
  final List<TransactionItemModel>? items;
  final double? subtotal;
  final double? tipAmount;
  final double? totalAmount;
  final double? totalPaid;
  final double? change;
  final List<PaymentDetailModel>? paymentDetails;
  final String? observations;

  TransactionReceiptModel({
    this.transactionNumber,
    this.issuedAt,
    this.fiscalData,
    this.shiftId,
    this.cashierId,
    this.orderId,
    this.orderNumber,
    this.originType,
    this.tableNames,
    this.customerId,
    this.customerName,
    this.waiterId,
    this.waiterName,
    this.items,
    this.subtotal,
    this.tipAmount,
    this.totalAmount,
    this.totalPaid,
    this.change,
    this.paymentDetails,
    this.observations,
  });

  factory TransactionReceiptModel.fromJson(Map<String, dynamic> json) {
    return TransactionReceiptModel(
      transactionNumber: json['transactionNumber'],
      issuedAt: json['issuedAt'],
      fiscalData: json['fiscalData'] != null
          ? FiscalDataReceipt.fromJson(json['fiscalData'])
          : null,
      shiftId: json['shiftId'],
      cashierId: json['cashierId'],
      orderId: json['orderId'],
      orderNumber: json['orderNumber'],
      originType: json['originType'],
      tableNames: json['tableNames'] != null
          ? List<String>.from(json['tableNames'])
          : null,
      customerId: json['customerId'],
      customerName: json['customerName'],
      waiterId: json['waiterId'],
      waiterName: json['waiterName'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => TransactionItemModel.fromJson(i))
              .toList()
          : null,
      subtotal: json['subtotal']?.toDouble(),
      tipAmount: json['tipAmount']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      totalPaid: json['totalPaid']?.toDouble(),
      change: json['change']?.toDouble(),
      paymentDetails: json['paymentDetails'] != null
          ? (json['paymentDetails'] as List)
              .map((i) => PaymentDetailModel.fromJson(i))
              .toList()
          : null,
      observations: json['observations'],
    );
  }
}

class FiscalDataReceipt {
  final String? businessName;
  final String? taxId;
  final String? taxIdDigit;
  final String? address;
  final String? city;
  final String? department;
  final String? dianResolution;
  final String? resolutionStartDate;
  final String? resolutionEndDate;
  final String? invoicePrefix;
  final int? resolutionNumberFrom;
  final int? resolutionNumberTo;
  final String? taxRegime;
  final String? email;
  final String? phone;
  final String? website;

  FiscalDataReceipt({
    this.businessName,
    this.taxId,
    this.taxIdDigit,
    this.address,
    this.city,
    this.department,
    this.dianResolution,
    this.resolutionStartDate,
    this.resolutionEndDate,
    this.invoicePrefix,
    this.resolutionNumberFrom,
    this.resolutionNumberTo,
    this.taxRegime,
    this.email,
    this.phone,
    this.website,
  });

  factory FiscalDataReceipt.fromJson(Map<String, dynamic> json) {
    return FiscalDataReceipt(
      businessName: json['businessName'],
      taxId: json['taxId'],
      taxIdDigit: json['taxIdDigit'],
      address: json['address'],
      city: json['city'],
      department: json['department'],
      dianResolution: json['dianResolution'],
      resolutionStartDate: json['resolutionStartDate'],
      resolutionEndDate: json['resolutionEndDate'],
      invoicePrefix: json['invoicePrefix'],
      resolutionNumberFrom: json['resolutionNumberFrom'],
      resolutionNumberTo: json['resolutionNumberTo'],
      taxRegime: json['taxRegime'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
    );
  }
}

class TransactionItemModel {
  final String? detailId;
  final String? productId;
  final String? productName;
  final String? productType;
  final int? quantity;
  final double? unitPrice;
  final double? subtotal;
  final String? observations;
  final List<dynamic>? comboSelections;

  TransactionItemModel({
    this.detailId,
    this.productId,
    this.productName,
    this.productType,
    this.quantity,
    this.unitPrice,
    this.subtotal,
    this.observations,
    this.comboSelections,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      detailId: json['detailId'],
      productId: json['productId'],
      productName: json['productName'],
      productType: json['productType'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice']?.toDouble(),
      subtotal: json['subtotal']?.toDouble(),
      observations: json['observations'],
      comboSelections: json['comboSelections'],
    );
  }
}

class PaymentDetailModel {
  final String? id;
  final String? paymentMethod;
  final String? paymentMethodDescription;
  final double? amount;
  final String? currency;

  PaymentDetailModel({
    this.id,
    this.paymentMethod,
    this.paymentMethodDescription,
    this.amount,
    this.currency,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      paymentMethodDescription: json['paymentMethodDescription'],
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
    );
  }
}
