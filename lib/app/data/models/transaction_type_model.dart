class TransactionTypeModel {
  String? code;
  String? description;

  TransactionTypeModel({this.code, this.description});

  TransactionTypeModel.fromJson(Map<String, dynamic> json) {
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
