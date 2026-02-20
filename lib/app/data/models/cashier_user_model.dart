class CashierUser {
  final String id;
  final String username;
  final String name;
  final String? secondName;
  final String lastName;
  final String? secondLastName;
  final String? mobileNumber;
  final String email;
  final bool active;
  final List<String> roles;

  CashierUser({
    required this.id,
    required this.username,
    required this.name,
    this.secondName,
    required this.lastName,
    this.secondLastName,
    this.mobileNumber,
    required this.email,
    required this.active,
    required this.roles,
  });

  factory CashierUser.fromJson(Map<String, dynamic> json) {
    return CashierUser(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      secondName: json['secondName'],
      lastName: json['lastName'],
      secondLastName: json['secondLastName'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      active: json['active'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  String get fullName => '$name $lastName';
}
