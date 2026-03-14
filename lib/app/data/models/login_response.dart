class LoginResponse {
  final List<Branch>? branches;
  final String? id;
  final String? mobileNumber;
  final String? name;
  final List<UserRole>? roles;
  final String? token;

  LoginResponse({
    this.branches,
    this.id,
    this.mobileNumber,
    this.name,
    this.roles,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      branches: json['branches'] != null
          ? (json['branches'] as List).map((i) => Branch.fromJson(i)).toList()
          : null,
      id: json['id'],
      mobileNumber: json['mobile_number'],
      name: json['name'],
      roles: json['roles'] != null
          ? (json['roles'] as List).map((i) => UserRole.fromJson(i)).toList()
          : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branches': branches?.map((e) => e.toJson()).toList(),
      'id': id,
      'mobile_number': mobileNumber,
      'name': name,
      'roles': roles?.map((e) => e.toJson()).toList(),
      'token': token,
    };
  }
}

class Branch {
  final String? id;
  final String? name;

  Branch({this.id, this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class UserRole {
  final int? id;
  final String? name;

  UserRole({this.id, this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
