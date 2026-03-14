class UserModel {
  final String? id;
  final String? username;
  final String? name;
  final String? secondName;
  final String? lastName;
  final String? secondLastName;
  final String? mobileNumber;
  final String? email;
  final bool isActive;
  final List<String> roles;

  UserModel({
    this.id,
    this.username,
    this.name,
    this.secondName,
    this.lastName,
    this.secondLastName,
    this.mobileNumber,
    this.email,
    this.isActive = true,
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      secondName: json['secondName'] ?? json['second_name'],
      lastName: json['lastName'] ?? json['last_name'],
      secondLastName: json['secondLastName'] ?? json['second_last_name'],
      mobileNumber: json['mobileNumber'] ?? json['mobile_number'],
      email: json['email'],
      isActive: json['active'] ?? json['isActive'] ?? true,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'secondName': secondName,
      'lastName': lastName,
      'secondLastName': secondLastName,
      'mobileNumber': mobileNumber,
      'email': email,
      'active': isActive,
      'roles': roles,
    };
  }

  String get fullName {
    final parts = [
      name,
      secondName,
      lastName,
      secondLastName,
    ].where((e) => e != null && e.isNotEmpty);
    return parts.join(' ');
  }
}
