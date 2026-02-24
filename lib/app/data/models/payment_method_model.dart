class PaymentMethodModel {
  String? code;
  String? description;

  PaymentMethodModel({this.code, this.description});

  PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['description'] = description;
    return data;
  }
}
