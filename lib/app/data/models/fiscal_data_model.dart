class FiscalDataModel {
  final String? id;
  final String businessName;
  final String taxId;
  final String? taxIdDigit;
  final String address;
  final String city;
  final String? department;
  final String dianResolution;
  final String? resolutionStartDate;
  final String? resolutionEndDate;
  final String? invoicePrefix;
  final int? resolutionNumberFrom;
  final int? resolutionNumberTo;
  final String taxRegime;
  final String email;
  final String? phone;
  final String? website;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  FiscalDataModel({
    this.id,
    required this.businessName,
    required this.taxId,
    this.taxIdDigit,
    required this.address,
    required this.city,
    this.department,
    required this.dianResolution,
    this.resolutionStartDate,
    this.resolutionEndDate,
    this.invoicePrefix,
    this.resolutionNumberFrom,
    this.resolutionNumberTo,
    required this.taxRegime,
    required this.email,
    this.phone,
    this.website,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory FiscalDataModel.fromJson(Map<String, dynamic> json) {
    return FiscalDataModel(
      id: json['id'] as String?,
      businessName: json['businessName'] as String? ?? '',
      taxId: json['taxId'] as String? ?? '',
      taxIdDigit: json['taxIdDigit'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      department: json['department'] as String?,
      dianResolution: json['dianResolution'] as String? ?? '',
      resolutionStartDate: json['resolutionStartDate'] as String?,
      resolutionEndDate: json['resolutionEndDate'] as String?,
      invoicePrefix: json['invoicePrefix'] as String?,
      resolutionNumberFrom: json['resolutionNumberFrom'] as int?,
      resolutionNumberTo: json['resolutionNumberTo'] as int?,
      taxRegime: json['taxRegime'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      active: json['active'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'businessName': businessName,
      'address': address,
      'city': city,
      'dianResolution': dianResolution,
      'taxRegime': taxRegime,
      'email': email,
    };

    if (taxId.isNotEmpty) data['taxId'] = taxId;
    if (taxIdDigit != null) data['taxIdDigit'] = taxIdDigit;
    if (department != null) data['department'] = department;
    if (resolutionStartDate != null) {
      data['resolutionStartDate'] = resolutionStartDate;
    }
    if (resolutionEndDate != null) {
      data['resolutionEndDate'] = resolutionEndDate;
    }
    if (invoicePrefix != null) data['invoicePrefix'] = invoicePrefix;
    if (resolutionNumberFrom != null) {
      data['resolutionNumberFrom'] = resolutionNumberFrom;
    }
    if (resolutionNumberTo != null) {
      data['resolutionNumberTo'] = resolutionNumberTo;
    }
    if (phone != null) data['phone'] = phone;
    if (website != null) data['website'] = website;

    return data;
  }
}
