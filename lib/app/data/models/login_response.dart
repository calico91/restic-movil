class LoginResponse {
  final List<Branch>? branches;
  final String? id;
  final String? mobileNumber;
  final List<String>? modules;
  final String? name;
  final List<String>? roles;
  final String? token;
  final bool? mustChangePassword;

  LoginResponse({
    this.branches,
    this.id,
    this.mobileNumber,
    this.modules,
    this.name,
    this.roles,
    this.token,
    this.mustChangePassword,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      branches: json['branches'] != null
          ? (json['branches'] as List).map((i) => Branch.fromJson(i)).toList()
          : null,
      id: json['id'],
      mobileNumber: json['mobile_number'],
      modules: json['modules'] != null ? List<String>.from(json['modules']) : null,
      name: json['name'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      token: json['token'],
      mustChangePassword: json['must_change_password'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branches': branches?.map((e) => e.toJson()).toList(),
      'id': id,
      'mobile_number': mobileNumber,
      'modules': modules,
      'name': name,
      'roles': roles,
      'token': token,
      'must_change_password': mustChangePassword,
    };
  }
}

class Branch {
  final String? id;
  final String? name;
  final bool waiterViewOwnOrdersOnly;

  Branch({this.id, this.name, this.waiterViewOwnOrdersOnly = false});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      waiterViewOwnOrdersOnly: json['waiterViewOwnOrdersOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'waiterViewOwnOrdersOnly': waiterViewOwnOrdersOnly,
    };
  }
}
