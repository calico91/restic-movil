class PaymentMethodModel {
  String? id;
  String? method;
  String? displayName;
  bool? active;
  int? displayOrder;

  PaymentMethodModel({
    this.id,
    this.method,
    this.displayName,
    this.active,
    this.displayOrder,
  });

  PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    method = json['method'];
    displayName = json['displayName'];
    active = json['active'];
    displayOrder = json['displayOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['method'] = method;
    data['displayName'] = displayName;
    data['active'] = active;
    data['displayOrder'] = displayOrder;
    return data;
  }

  // Helpers backward compatibility si en algun lado se usa code o description aun
  String? get code => method;
  String? get description => displayName;
}
