class CustomerModel {
  String? id;
  String? name;
  String? lastName;
  String? document;
  String? phone;
  String? email;
  String? address;
  String? notes;

  CustomerModel({
    this.id,
    this.name,
    this.lastName,
    this.document,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  String get fullName => '${name ?? ''} ${lastName ?? ''}'.trim();

  CustomerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastName = json['lastName'];
    document = json['document'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['name'] = name;
    data['lastName'] = lastName;
    data['document'] = document;
    data['phone'] = phone;
    data['email'] = email;
    data['address'] = address;
    data['notes'] = notes;
    return data;
  }
}

