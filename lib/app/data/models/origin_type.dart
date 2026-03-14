class OriginType {
  final String? code;
  final String? description;

  OriginType({this.code, this.description});

  factory OriginType.fromJson(Map<String, dynamic> json) {
    return OriginType(code: json['code'], description: json['description']);
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'description': description};
  }
}
